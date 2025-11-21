import { PrismaClient } from "@prisma/client";
import redisClient from "../config/redis.ts";
import { Decimal } from "@prisma/client/runtime/client";
import { notifyAdmin } from "../../utils/socket.util.ts";
import { v4 as uuidv4 } from 'uuid';
import { generateInvoicePDF } from "../../utils/pdfGenerator.ts";
import minioClient from "../config/minio.ts";
const prisma = new PrismaClient();

/* -------------------- CONSTANTS -------------------- */
const CACHE_TTL = 300;
const CACHE_KEY_VEHICLES_PAGE_1 = "vehicles:page:1";

const BUFFER_HOURS = 4;      // Khoảng nghỉ bắt buộc giữa 2 chuyến
const EXTENSION_HOURS = 4;   // Gói gia hạn cứng 4 tiếng
const MIN_NOTICE_HOURS = 4;  // Phải báo trước 4 tiếng mới được gia hạn

const BUFFER_MS = BUFFER_HOURS * 60 * 60 * 1000;
const EXTENSION_MS = EXTENSION_HOURS * 60 * 60 * 1000;
const MIN_NOTICE_MS = MIN_NOTICE_HOURS * 60 * 60 * 1000;

/* -------------------- UTILITIES -------------------- */
const invalidateVehicleCache = async () => {
  try {
    await redisClient.del(CACHE_KEY_VEHICLES_PAGE_1);
    console.log("🧹 CACHE INVALIDATED: Đã xóa cache danh sách xe");
  } catch (err) {
    console.error("❌ Lỗi khi xóa cache Redis:", err);
  }
};

const invalidateBookingCaches = async (bookingId?: number, userId?: string) => {
  try {
    if (bookingId) await redisClient.del(`booking:detail:${bookingId}`);
    await redisClient.del("bookings:admin:page:1");
    if (userId) await redisClient.del(`bookings:user:${userId}:page:1`);
  } catch (err) { console.error(err); }
};

/* -------------------- CREATE BOOKING SERVICE -------------------- */

export const createBooking = async (userId: string, data: any) => {
  const {vehicle_id, rental_package_id, start_datetime, end_datetime, pickup_location_id, dropoff_location_id, } = data;

  const start = new Date(start_datetime);
  const end = new Date(end_datetime);
  const now = new Date();

  if (isNaN(start.getTime()) || isNaN(end.getTime())) {
    throw new Error("Thời gian không hợp lệ");
  }
  
  if (start >= end) {
    throw new Error("Thời gian kết thúc phải sau thời gian bắt đầu");
  }

  if (start < now) {
    throw new Error("Thời gian nhận xe không thể ở trong quá khứ");
  }

  const timeUntilPickup = start.getTime() - now.getTime();
  if (timeUntilPickup < BUFFER_MS) {
      throw new Error(`Vui lòng đặt xe trước ít nhất ${BUFFER_HOURS} tiếng để chúng tôi chuẩn bị xe.`);
  }

  return prisma.$transaction(async (tx) => {
    const locationsCount = await tx.locations.count({
        where: { id: { in: [pickup_location_id, dropoff_location_id] } }
    });
    if (locationsCount < 2) { 
         if (pickup_location_id === dropoff_location_id) {
             if (locationsCount < 1) throw new Error("Địa điểm không tồn tại");
         } else {
             if (locationsCount < 2) throw new Error("Địa điểm nhận hoặc trả xe không tồn tại");
         }
    }

    const vehicle = await tx.vehicles.findUnique({
      where: { id: vehicle_id },
      include: { vehicle_type: true } 
    });

    if (!vehicle) throw new Error("Xe không tồn tại");
    if (vehicle.status !== "available") throw new Error("Xe đang bảo trì hoặc không sẵn sàng");

    const rentalPackage = await tx.rental_packages.findUnique({
        where: { id: rental_package_id }
    });

    if (!rentalPackage) throw new Error("Gói thuê không tồn tại");
    
    if (rentalPackage.vehicle_type_id !== vehicle.vehicle_type_id) {
        throw new Error("Gói thuê không áp dụng cho loại xe này");
    }

    const checkStart = new Date(start.getTime() - BUFFER_MS); 
    const checkEnd = new Date(end.getTime() + BUFFER_MS);

    const conflictBooking = await tx.bookings.findFirst({
      where: {
        vehicle_id,
        status: { in: ["confirmed", "rented", "pending"] }, 
        AND: [
          { start_datetime: { lt: checkEnd } },    
          { end_datetime: { gt: checkStart } }     
        ]
      },
    });

    if (conflictBooking) {
       const conflictEnd = new Date(conflictBooking.end_datetime.getTime() + BUFFER_MS);
       if (start < conflictEnd && start >= conflictBooking.start_datetime) {
           throw new Error(`Xe chưa sẵn sàng. Vui lòng chọn thời gian sau ${conflictEnd.toLocaleString('vi-VN')}.`);
       }
       throw new Error("Xe đã bị trùng lịch trong khoảng thời gian này.");
    }
    
    const durationMs = end.getTime() - start.getTime();
    const durationHoursReal = durationMs / (1000 * 60 * 60);

    const packageDuration = rentalPackage.duration_hours; 
    const basePrice = Number(rentalPackage.price);
    
    let totalPrice = basePrice;
    let totalSurcharges = 0;

    if (durationHoursReal > packageDuration) {
        const rawExtraHours = durationHoursReal - packageDuration; 
        const extraHours = Math.ceil(rawExtraHours); 
        const pricePerHour = basePrice / packageDuration;     

        const surchargeAmount = Math.round(extraHours * pricePerHour); 

        totalSurcharges = surchargeAmount;
        totalPrice = basePrice + surchargeAmount;
    }

    const newBooking = await tx.bookings.create({
      data: {
        user_id: userId,
        vehicle_id,
        rental_package_id,
        start_datetime: start,
        end_datetime: end,
        pickup_location_id,
        dropoff_location_id,
        
        base_price: basePrice,           
        total_surcharges: totalSurcharges, 
        total_price: totalPrice,        
        
        booking_deposit_paid: 0,
        status: "pending",
        
        late_fee: 0,
        cleaning_fee: 0,
        compensation_fee: 0,
        other_surcharges: 0,
      },
    });


    await invalidateVehicleCache();
    await invalidateBookingCaches(newBooking.id, userId);

    notifyAdmin('BOOKING', { id: newBooking.id });

    return newBooking;
  });
};

/* -------------------- GET BOOKINGS -------------------- */
export const getBookings = async (
  user: { id: string; role: string },
  page: number = 1,
  limit: number = 10
) => {
  const skip = (page - 1) * limit;
  const cacheKey =
    user.role === "admin"
      ? `bookings:admin:page:${page}`
      : `bookings:user:${user.id}:page:${page}`;

  const cachedData = await redisClient.get(cacheKey);
  if (cachedData) {

      return JSON.parse(cachedData);
  }

  const whereClause: any = {};
  if (user.role !== "admin") whereClause.user_id = user.id;

  const [bookings, total] = await prisma.$transaction([
    prisma.bookings.findMany({
      where: whereClause,
      include: {
        users: { select: { id: true, name: true, email: true, phone: true } },
        
        rental_package: true, 

        vehicles: {
            include: {
                vehicle_type: true 
            }
        },
        
        locations_bookings_pickup_location_idTolocations: true,
        locations_bookings_dropoff_location_idTolocations: true,
      },
      skip,
      take: limit,
      orderBy: { created_at: "desc" },
    }),
    prisma.bookings.count({ where: whereClause }),
  ]);

  const bookingsWithImages = await Promise.all(
      bookings.map(async (booking) => {
          if (booking.vehicles && booking.vehicles.images) {
              const imageUrls = await Promise.all(
                  booking.vehicles.images.map(async (img) => {
                      try { return await getPresignedUrl(img); } catch { return null; }
                  })
              );
              (booking.vehicles as any).imageUrls = imageUrls.filter(u => u !== null);
          }
          return booking;
      })
  );

  const result = {
    data: bookingsWithImages,
    pagination: {
      totalItems: total,
      currentPage: page,
      totalPages: Math.ceil(total / limit),
      limit,
    },
  };

  // 5. Set Cache
  await redisClient.setEx(cacheKey, CACHE_TTL, JSON.stringify(result));
  return result;
};

/* -------------------- GET BOOKING DETAIL -------------------- */
export const getBookingDetails = async (
  user: { id: string; role: string },
  bookingId: number
) => {
  const cacheKey = `booking:detail:${bookingId}`;
  
  // 1. Check Cache
  const cachedData = await redisClient.get(cacheKey);
  if (cachedData) {
    const cachedBooking = JSON.parse(cachedData);
    // Kiểm tra quyền sở hữu ngay cả khi lấy từ cache
    if (user.role === "admin" || cachedBooking.user_id === user.id)
      return cachedBooking;
    throw new Error("Bạn không có quyền xem booking này.");
  }

  // 2. Build Query
  const whereClause: any = { id: bookingId };
  if (user.role !== "admin") whereClause.user_id = user.id;

  // 3. Find DB
  const booking = await prisma.bookings.findFirstOrThrow({
    where: whereClause,
    include: {
      // Thông tin chi tiết cần thiết cho màn hình Detail
      rental_package: true, // Gói thuê
      
      vehicles: {
          include: {
              vehicle_type: true // Loại xe, số ghế
          }
      },
      
      locations_bookings_pickup_location_idTolocations: true,
      locations_bookings_dropoff_location_idTolocations: true,
      
      payments: true, 
      invoices: true, 
      
      users: { select: { id: true, name: true, email: true, phone: true } },
    },
  });

  if (booking.vehicles && booking.vehicles.images) {
      const imageUrls = await Promise.all(
          booking.vehicles.images.map(async (img) => {
              try { return await getPresignedUrl(img); } catch { return null; }
          })
      );
      (booking.vehicles as any).imageUrls = imageUrls.filter(u => u !== null);
  }

  await redisClient.setEx(cacheKey, CACHE_TTL, JSON.stringify(booking));
  return booking;
};

/* -------------------- CANCEL BOOKING -------------------- */
export const cancelBooking = async (
  user: { id: string; role: string },
  bookingId: number
) => {
  const whereClause: any = { id: bookingId };
  
  if (user.role !== "admin") {
    whereClause.user_id = user.id;
  }

  const result = await prisma.$transaction(async (tx) => {
    const booking = await tx.bookings.findFirst({ where: whereClause });
    
    if (!booking) throw new Error("Booking không tồn tại hoặc không có quyền.");
    if (["completed", "cancelled", "rented"].includes(booking.status || "")) {
      throw new Error("Không thể hủy đơn ở trạng thái này.");
    }

    if (user.role !== "admin") {
      if (new Date(booking.start_datetime) <= new Date()) {
        throw new Error("Xe đã chạy, không thể hủy.");
      }
    }

    const updatedBooking = await tx.bookings.update({
      where: { id: bookingId },
      data: { status: "cancelled" },
    });

    await tx.logs.create({
      data: {
        action: "CANCEL_BOOKING",
        user_id: user.id,
        object_id: String(bookingId), 
        object_type: "bookings"       
      }
    });

    return updatedBooking;
  });

  await invalidateVehicleCache(); 
  await invalidateBookingCaches(bookingId, user.id);

  notifyAdmin('BOOKING', { id: bookingId });
  

  return result;
};

export const pickupBooking = async (
  user: { id: string; role: string },
  bookingId: number,
  securityDepositReceived: number, 
  paymentMethod: string
) => {
  const booking = await prisma.bookings.findUnique({
    where: { id: bookingId },
    include: { 
        vehicles: { include: { vehicle_type: true } }, 
        users: true 
    },
  });

  if (!booking) throw new Error("Không tìm thấy booking");
  if (booking.status !== "confirmed")
    throw new Error(`Chỉ được nhận xe khi booking đã xác nhận (Trạng thái hiện tại: ${booking.status})`);

  const requiredDeposit = Number(booking.vehicles?.vehicle_type?.deposit_amount || 0);
  
  if (securityDepositReceived < requiredDeposit) {
      throw new Error(`Tiền cọc thế chấp không đủ. Loại xe này yêu cầu cọc tối thiểu: ${requiredDeposit.toLocaleString()} VND`);
  }


  const totalRentalPrice = Number(booking.total_price);
  const baseRentalAmount = Number(booking.base_price || 0);
  const surchargesAmount = totalRentalPrice - baseRentalAmount;
  const TAX_RATE = 0.08;
  const taxAmount = Math.round(baseRentalAmount * TAX_RATE);  
  const rentalTotalWithTax = Math.round(baseRentalAmount + taxAmount);  

  const remainingRentalFee = rentalTotalWithTax;

  const now = new Date(); 
  const scheduledStart = new Date(booking.start_datetime);
  const diffMinutes = (now.getTime() - scheduledStart.getTime()) / (1000 * 60);

  let newStartDatetime = scheduledStart;

  if (Math.abs(diffMinutes) <= 60) {
      newStartDatetime = now; 
  }

  const result = await prisma.$transaction(async (tx) => {
    let newInvoice = null;
    if (remainingRentalFee > 0) {
        const invoiceNum = `INV-RENT-${Date.now()}`;
        const rentalPayment = await tx.payments.create({
            data: {
                booking_id: booking.id,
                user_id: booking.user_id,
                provider: paymentMethod,
                amount: remainingRentalFee,
                currency: "VND",
                status: "successful", 
                type: "RENTAL_FEE",   
                paid_at: now,
            }
        });
        
        newInvoice = await tx.invoices.create({
            data: {
                invoice_number: invoiceNum,
                booking_id: booking.id,
                payment_id: rentalPayment.id,
                user_id: booking.user_id,
                base_amount: baseRentalAmount,
                surcharges_amount: surchargesAmount > 0 ? surchargesAmount : 0, 
                tax_rate: TAX_RATE,                      
                tax_amount: taxAmount,
                total_amount: Math.round(baseRentalAmount + surchargesAmount + taxAmount),
                issued_by: user.id,
                notes: "Thanh toán phần tiền thuê (bao gồm VAT) khi nhận xe"
            }
        });
    }

    const depositPayment = await tx.payments.create({
        data: {
            booking_id: booking.id,
            user_id: booking.user_id,
            provider: paymentMethod,
            amount: securityDepositReceived,
            currency: "VND",
            status: "successful",
            type: "RENTAL_DEPOSIT", 
            paid_at: now,
        }
    });

    const updatedBooking = await tx.bookings.update({
        where: { id: bookingId },
        data: {
            status: "rented", 
            actual_start_datetime: now,
            start_datetime: newStartDatetime,            
            rental_deposit_paid: securityDepositReceived,
         
            updated_at: now,
        }
    });
    
    return { updatedBooking, depositPayment, newInvoice };
  });

  await invalidateBookingCaches(bookingId, booking.user_id);

  return result;
};

export const extendBookingService = async (
  user: { id: string; role: string },
  bookingId: number
) => {
  const booking = await prisma.bookings.findUnique({
    where: { id: bookingId },
    include: { rental_package: true }, 
  });

  if (!booking) throw new Error("Không tìm thấy booking");
  if (user.role !== "admin" && booking.user_id !== user.id) {
    throw new Error("Bạn không có quyền gia hạn booking này");
  }
  if (booking.status !== "rented" && booking.status !== "confirmed") {
    throw new Error("Chỉ có thể gia hạn khi đang thuê xe hoặc đã xác nhận");
  }
  if (booking.original_end_datetime) {
    throw new Error("Bạn chỉ được phép gia hạn tối đa 1 lần.");
  }

  const now = new Date();
  const currentEndTime = new Date(booking.end_datetime);
  const timeUntilExpiry = currentEndTime.getTime() - now.getTime();

  if (timeUntilExpiry < MIN_NOTICE_MS) { 
    throw new Error(
      `Yêu cầu bị từ chối. Phải gia hạn trước giờ trả xe ít nhất ${MIN_NOTICE_HOURS} tiếng.`
    );
  }

  const newEndTime = new Date(currentEndTime.getTime() + EXTENSION_MS); 

  const checkStart = currentEndTime; 
  const checkEnd = new Date(newEndTime.getTime() + BUFFER_MS); 

  const conflictBooking = await prisma.bookings.findFirst({
    where: {
      vehicle_id: booking.vehicle_id,
      id: { not: bookingId }, 
      status: { in: ["confirmed", "rented", "pending"] },
      AND: [
        { start_datetime: { lt: checkEnd } },
        { end_datetime: { gt: checkStart } }
      ]
    },
  });

  if (conflictBooking) {
    throw new Error("Không thể gia hạn do xe đã trùng lịch với khách khác.");
  }

  if (!booking.rental_package) throw new Error("Dữ liệu gói thuê bị lỗi");

  const basePrice = Number(booking.rental_package.price);
  const baseDuration = booking.rental_package.duration_hours;
  const hourlyRate = basePrice / baseDuration;

  const rentalCostForExtension = hourlyRate * EXTENSION_HOURS;
  const serviceFeeForExtension = basePrice * 0.10;
  
  const totalExtensionCost = Math.round(rentalCostForExtension + serviceFeeForExtension);

  const result = await prisma.$transaction(async (tx) => {
    const updatedBooking = await tx.bookings.update({
      where: { id: bookingId },
      data: {
        original_end_datetime: currentEndTime, 
        end_datetime: newEndTime,               

        extension_fee: totalExtensionCost, 

        total_surcharges: { increment: totalExtensionCost }, 
        
        total_price: { increment: totalExtensionCost },      
        
        updated_at: now,
      },
    });
    return updatedBooking;
  });
  
  await redisClient.del(`booking:detail:${bookingId}`);
  await redisClient.del(CACHE_KEY_VEHICLES_PAGE_1); 

  notifyAdmin('BOOKING', { id: bookingId });
  notifyAdmin('INVOICE');
  
  return result;
};

/* -------------------- RETURN BOOKING -------------------- */

export const returnBookingService = async (
  user: { id: string; role: string },
  bookingId: number,
  extras: { 
      cleaning_fee: number; 
      damage_fee: number; 
      other_fee: number; 
      compensation_fee: number; 
      note: string 
  }
) => {
  const booking = await prisma.bookings.findUnique({
    where: { id: bookingId },
    include: { rental_package: true, payments: true, vehicles: true, users: true }, 
  });

  if (!booking) throw new Error("Không tìm thấy booking");
  if (booking.status !== "rented" && booking.status !== "confirmed") { 
      throw new Error(`Trạng thái booking không hợp lệ để trả xe (${booking.status})`);
  }

  const now = new Date();
  const scheduledEnd = new Date(booking.end_datetime); 
  
  let lateFee = 0;
  let lateHours = 0;
  
  if (now > scheduledEnd) {
      const diffMs = now.getTime() - scheduledEnd.getTime();
      lateHours = diffMs / (1000 * 60 * 60); 
      const packagePrice = Number(booking.base_price); 
      
      if (lateHours <= 1) {
          lateFee = 0;
      } else if (lateHours <= 4) {
          lateFee = packagePrice * 0.20;
      } else if (lateHours <= 8) {
          lateFee = packagePrice * 0.50;
      } else {
          lateFee = packagePrice * 1.0;
      }
      lateFee = Math.round(lateFee);
  }

  let conflictWarning = null;
  if (lateHours > 0) {
      const nextBooking = await prisma.bookings.findFirst({
          where: {
              vehicle_id: booking.vehicle_id,
              status: { in: ["confirmed", "pending"] },
              start_datetime: { lt: now }
          }
      });
      if (nextBooking) {
          conflictWarning = "⚠️ CẢNH BÁO: Trả muộn đã ảnh hưởng đến khách hàng kế tiếp!";
          if (extras.compensation_fee <= 0) {
              throw new Error("Phát hiện trùng lịch! Vui lòng nhập chi phí đền bù cho khách sau.");
          }
      }
  }

  const compensationFee = extras.compensation_fee;
  const cleaningFee = extras.cleaning_fee;
  const damageFee = extras.damage_fee; 
  const otherFee = extras.other_fee;    

  const totalSurcharges = lateFee + compensationFee + cleaningFee + damageFee + otherFee;
  
  const rentalDeposit = Number(booking.rental_deposit_paid || 0); 
  const totalRentalPrice = Number(booking.total_price);
  
  const paidAmount = booking.payments
      .filter(p => p.type === 'RENTAL_FEE' || p.type === 'BOOKING_DEPOSIT')
      .reduce((sum, p) => sum + Number(p.amount), 0);
      
  const unpaidRentalFee = Math.max(0, totalRentalPrice - paidAmount); 

  const TAX_RATE = 0.08;
  const extraRentalFeeBeforeTax = unpaidRentalFee; 
  const extraRentalTax = Math.round(extraRentalFeeBeforeTax * TAX_RATE);
  const extraRentalTotalWithTax = Math.round(extraRentalFeeBeforeTax + extraRentalTax);

  const totalLiability = extraRentalTotalWithTax + totalSurcharges;
  let amountToRefund = 0;
  let amountToCollect = 0;

  if (rentalDeposit >= totalLiability) {
      amountToRefund = rentalDeposit - totalLiability;
  } else {
      amountToCollect = totalLiability - rentalDeposit;
  }

  const transactionResult = await prisma.$transaction(async (tx) => {
      const updatedBooking = await tx.bookings.update({
          where: { id: bookingId },
          data: {
              status: "completed", 
              actual_end_datetime: now,
              
              late_fee: lateFee,
              compensation_fee: compensationFee,
              cleaning_fee: cleaningFee,
              other_surcharges: damageFee + otherFee,
              
              total_surcharges: lateFee + compensationFee + cleaningFee + damageFee + otherFee,
              total_price: new Decimal(booking.base_price).plus(totalSurcharges),
              
              updated_at: now,
          }
      });

      let finalPayment = null;
      const invoiceNumber = `INV-RET-${Date.now()}`;

      if (amountToRefund > 0) {
          finalPayment = await tx.payments.create({
              data: {
                  booking_id: bookingId,
                  user_id: booking.user_id,
                  amount: amountToRefund,
                  provider: "cash", 
                  status: "successful",
                  type: "REFUND", 
                  currency: "VND",
                  paid_at: now
              }
          });
      } else if (amountToCollect > 0) {
          finalPayment = await tx.payments.create({
              data: {
                  booking_id: bookingId,
                  user_id: booking.user_id,
                  amount: amountToCollect,
                  provider: "cash",
                  status: "successful",
                  type: "SURCHARGE",
                  currency: "VND",
                  paid_at: now
              }
          });
          
          await tx.invoices.create({
              data: {
                  invoice_number: invoiceNumber,
                  booking_id: bookingId,
                  user_id: booking.user_id,
                  payment_id: finalPayment.id,
                  base_amount: extraRentalFeeBeforeTax,         
                  surcharges_amount: totalSurcharges,           
                  tax_rate: TAX_RATE,
                  tax_amount: extraRentalTax,
                  total_amount: Math.round(extraRentalFeeBeforeTax + totalSurcharges + extraRentalTax),
                  issued_by: user.id, 
                  notes: `Thu thêm khi trả xe. ${extras.note}`
              }
          });
      }

        if (finalPayment) {
          const createdInvoice = await tx.invoices.findFirst({
            where: { booking_id: bookingId },
            orderBy: { id: 'desc' }
          });

          if (createdInvoice) {
              try {
                  const pdfData = {
                      invoice: createdInvoice,
                      user: { 
                          name: booking.users?.name ?? 'N/A', 
                          email: booking.users?.email ?? 'N/A',
                          phone: booking.users?.phone ?? 'N/A'
                      },
                      vehicle: {
                        title: booking.vehicles?.title ?? 'Xe',
                        plate_number: booking.vehicles?.plate_number ?? 'N/A',
                        brand: booking.vehicles?.brand ?? ''
                      },
                      booking: {
                        start_datetime: booking.start_datetime,
                        end_datetime: booking.end_datetime,
                        actual_end_datetime: now, // hoặc updatedBooking.actual_end_datetime
                        late_fee: lateFee,
                        cleaning_fee: cleaningFee,
                        compensation_fee: compensationFee,
                        damage_fee: damageFee,
                        other_fee: otherFee,
                        total_surcharges: totalSurcharges
                      }
                  };
                  const pdfBuffer = await generateInvoicePDF(pdfData);
                  const pdfName = `invoices/${createdInvoice.invoice_number}.pdf`;

                  await minioClient.putObject(
                    process.env.MINIO_BUCKET_NAME || 'rentcar',
                    pdfName,
                    pdfBuffer,
                    pdfBuffer.length,
                    { "Content-Type": "application/pdf" }
                  );

                  await prisma.invoices.update({
                    where: { id: createdInvoice.id },
                    data: { pdf_url: pdfName } 
                  });

              } catch (err) {
                  console.error("⚠️ Lỗi tạo PDF:", err);
              }
          }
        }
      
      if (booking.vehicle_id) {
          await tx.vehicles.update({
              where: { id: booking.vehicle_id },
              data: { status: "available" } 
          });
      }
      
      return { 
          warning: conflictWarning,
          financial_breakdown: {
              deposit_held: rentalDeposit,     
              total_surcharges: totalSurcharges,
              refund_amount: amountToRefund,   
              collect_amount: amountToCollect, 
              details: {
                  late_hours: lateHours.toFixed(1),
                  late_fee: lateFee,
                  compensation_fee: compensationFee,
                  cleaning_fee: cleaningFee,
                  damage_fee: damageFee,
                  other_fee: otherFee
              }
          }
      };
  });


  await invalidateBookingCaches(bookingId, booking.user_id); 
  await invalidateVehicleCache();

  notifyAdmin('BOOKING', { id: bookingId });
  if (amountToCollect > 0) {
    notifyAdmin('INVOICE');
  }
  
  const fullUpdatedBooking = await getBookingDetails(user, bookingId);

  return {
      booking: fullUpdatedBooking, 
      warning: transactionResult.warning,
      financial_breakdown: transactionResult.financial_breakdown
  };
};

