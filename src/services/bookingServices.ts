import { PrismaClient } from "@prisma/client";
import redisClient from "../config/redis.ts";

const prisma = new PrismaClient();
const CACHE_KEY_VEHICLES_PAGE_1 = "vehicles:page:1";
const CACHE_TTL = 300;
const calculateDays = (start: Date, end: Date): number => {
    const diff = end.getTime() - start.getTime();
    const days = Math.ceil(diff / (1000 * 60 * 60 * 24));
    return days === 0 ? 1 : days; 
};

const invalidateVehicleCache = async () => {
    try {
        await redisClient.del(CACHE_KEY_VEHICLES_PAGE_1);
        console.log("🧹 CACHE INVALIDATED: Đã xóa cache danh sách xe");
    } catch (err) {
        console.error("❌ Lỗi khi xóa cache Redis:", err);
    }
};

export const createBooking = async(userId: string, data: any) => {
    const { vehicle_id, start_datetime, end_datetime, pickup_location_id, dropoff_location_id } = data;

    const start = new Date(start_datetime);
    const end = new Date(end_datetime);

    if (isNaN(start.getTime()) || isNaN(end.getTime())) {
        throw new Error("Ngày bắt đầu hoặc kết thúc không hợp lệ");
    }
    return prisma.$transaction(async (tx) => {
        const vehicle = await tx.vehicles.findUnique({
            where: {id: vehicle_id}
        })
        if (!vehicle || !vehicle.price_per_day) {
            throw new Error("Xe không tồn tại hoặc không có giá");
        }

        const existingBooking = await tx.bookings.findFirst({
            where: {
                vehicle_id: vehicle_id,
                status: { in: ['confirmed', 'pending'] },
                OR: [
                { start_datetime: { lte: start_datetime },end_datetime: { gte: start_datetime } },
                { start_datetime: { lte: end_datetime }, end_datetime: { gte: end_datetime } },
                { start_datetime: { gte: start_datetime }, end_datetime: { lte: end_datetime } }
                ],
            },
        });
        if (existingBooking) {
            throw new Error("Xe đã được đặt trong khoảng thời gian này.");
        }

        const days = calculateDays(start, end);
        const totalPrice = days * parseFloat(vehicle.price_per_day.toString());

        const newBooking = await tx.bookings.create({
            data: {
                user_id: userId,
                vehicle_id: vehicle_id,
                start_datetime: start,
                end_datetime: end,
                total_price: totalPrice,
                status: 'pending', 
                pickup_location_id: pickup_location_id,
                dropoff_location_id: dropoff_location_id,
            },
        });

        await invalidateVehicleCache();

        return newBooking;
    })
}

export const getBookings = async (user: { id: string; role: string }, page: number = 1, limit: number = 10) => {
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
  if (user.role !== "admin") {
    whereClause.user_id = user.id;
  }

  const [bookings, total] = await prisma.$transaction([
    prisma.bookings.findMany({
      where: whereClause,
    //   include: {
    //     vehicles: true,
    //     locations_bookings_pickup_location_idTolocations: true,
    //     locations_bookings_dropoff_location_idTolocations: true,
    //   },
      skip,
      take: limit,
      orderBy: { created_at: "desc" },
    }),
    prisma.bookings.count({ where: whereClause }),
  ]);

  const totalPages = Math.ceil(total / limit);
  const result = {
    data: bookings,
    pagination: {
      totalItems: total,
      currentPage: page,
      totalPages,
      limit,
    },
  };

  await redisClient.setEx(cacheKey, CACHE_TTL, JSON.stringify(result));

  return result;
};

export const getBookingDetails = async (user: { id: string; role: string }, bookingId: number) => {
  
    const cacheKey = `booking:detail:${bookingId}`;
    const cachedData = await redisClient.get(cacheKey);
    if (cachedData) {
        const cachedBooking = JSON.parse(cachedData);
        if (user.role === 'admin' || cachedBooking.user_id === user.id) {
            return cachedBooking;
        }else{
            throw new Error("Không tìm thấy booking hoặc bạn không có quyền xem.");
        }
    }

    const whereClause: any = {
        id: bookingId,
    };

    if (user.role !== "admin") {
        whereClause.user_id = user.id;
    }
    
    const booking = await prisma.bookings.findFirstOrThrow({
        where: whereClause,
        include: {
        vehicles: true,
        locations_bookings_pickup_location_idTolocations: true,
        locations_bookings_dropoff_location_idTolocations: true,
        users: { 
            select: { id: true, name: true, email: true }
        }
        },
    });

    await redisClient.setEx(cacheKey, CACHE_TTL, JSON.stringify(booking));

    return booking;
};

export const cancelBooking = async (user: { id: string; role: string }, bookingId: number) => {
    const cacheKey = `booking:detail:${bookingId}`;
    const cachedData = await redisClient.get(cacheKey);

    if (cachedData) {
        const cachedBooking = JSON.parse(cachedData);
        if (user.role !== "admin" && cachedBooking.user_id !== user.id) {
        throw new Error("Không tìm thấy booking hoặc bạn không có quyền xem.");
        }
    }

    const whereClause: any = { id: bookingId };
    if (user.role !== "admin") {
        whereClause.user_id = user.id;
    }

    const booking = await prisma.bookings.findFirst({
        where: whereClause,
    });

    if (!booking) {
        throw new Error("Không tìm thấy booking hoặc bạn không có quyền hủy.");
    }

    if (booking.status === "completed" || booking.status === "cancelled") {
        throw new Error("Không thể hủy booking đã hoàn thành hoặc đã bị hủy.");
    }

    const updatedBooking = await prisma.bookings.update({
        where: { id: bookingId },
        data: { status: "cancelled" },
    });

    await redisClient.del(cacheKey);
    await invalidateVehicleCache();

    return updatedBooking;
};

export const confirmBooking = async (user: { id: string; role: string }, bookingId: number) => {
  const booking = await prisma.bookings.findUnique({
    where: { id: bookingId },
  });

  if (!booking) {
    throw new Error("Booking không tìm thấy");
  }

  if (booking.status !== "pending") {
    throw new Error("Chỉ có thể xác nhận các booking đang ở trạng thái 'pending'");
  }

  const updated = await prisma.bookings.update({
    where: { id: bookingId },
    data: {
      status: "confirmed",
      confirmed_by: user.id,
      confirmed_at: new Date(),
    },
  });

  
  await invalidateVehicleCache();
  return updated;
};

export const pickupBooking = async(user: {id: string, role: string}, bookingId: number, deposit_amount: number, payment_method: string) => {
  const booking = await prisma.bookings.findUnique({
    where: { id: bookingId },
    include: { vehicles: true },
  });

  if (!booking) {
    throw new Error("Không tìm thấy booking");
  }

  if (booking.status !== "confirmed") {
    throw new Error(`Chỉ có thể pickup khi booking đang ở trạng thái 'confirmed' (hiện tại: ${booking.status})`);
  }

  const total = Number(booking.total_price);
  const minDeposit = Math.ceil(total * 0.4); 

  if (deposit_amount < minDeposit) {
    throw new Error(
      `Tiền cọc tối thiểu là 40% tổng giá (${minDeposit.toLocaleString()} VND)`
    );
  }

  const allowedMethods = ["cash", "bank_transfer"];
  if (!allowedMethods.includes(payment_method)) {
    throw new Error("Phương thức thanh toán không hợp lệ (cash | bank_transfer)");
  }

  await prisma.payments.create({
    data: {
      booking_id: booking.id,
      provider: payment_method,
      amount: deposit_amount,
      currency: "VND",
      status: "paid",
      type: "deposit",
      paid_at: new Date(),
    },
  });

  const updatedBooking = await prisma.bookings.update({
    where: { id: bookingId },
    data: {
      status: "picked_up",
      updated_at: new Date(),
    },
  });

  await invalidateVehicleCache();

  return updatedBooking;
}

export const returnBooking = async(user: {id: string, role: string}, bookingId: number, extra_fee: number = 0) => {
   const booking = await prisma.bookings.findUnique({
    where: { id: bookingId },
    include: { vehicles: true, payments: true },
  });

  if (!booking) throw new Error("Không tìm thấy booking");
  if (booking.status !== "picked_up")
    throw new Error(
      `Chỉ có thể trả xe khi booking đang ở trạng thái 'picked_up' (hiện tại: ${booking.status})`
    );

  const now = new Date();
  const plannedEnd = booking.end_datetime;
  const totalPrice = Number(booking.total_price ?? 0);

  const deposit = booking.payments
    .filter((p) => p.type === "deposit" && p.status === "paid")
    .reduce((sum, p) => sum + Number(p.amount ?? 0), 0);

  let lateDays = 0;
  if (now > plannedEnd) {
    lateDays = calculateDays(plannedEnd, now);
  }

  const dailyRate = Number(booking.vehicles?.price_per_day ?? 0);
  const lateFee = lateDays * dailyRate;
  const surcharge = Number(extra_fee ?? 0) + lateFee;

  const totalDue = totalPrice + surcharge - deposit;

  let newPayment = null;
  if (totalDue > 0) {
    newPayment = await prisma.payments.create({
      data: {
        booking_id: booking.id,
        user_id: booking.user_id,
        provider: "cash",
        amount: totalDue,
        currency: "VND",
        status: "pending", 
        type: "final",
      },
    });
  }

  const updatedBooking = await prisma.bookings.update({
    where: { id: bookingId },
    data: {
      status: "returned",
      surcharge_amount: surcharge,
      confirmed_by: user.id,
      confirmed_at: now,
      updated_at: now,
    },
  });

  if (booking.vehicle_id) {
    await prisma.vehicles.update({
      where: { id: booking.vehicle_id },
      data: { status: "available" },
    });
  }

  await invalidateVehicleCache();

  return {
    booking: updatedBooking,
    newPayment,
    lateDays,
    lateFee,
    surcharge,
    deposit,
    totalDue: totalDue > 0 ? totalDue : 0,
  };
};