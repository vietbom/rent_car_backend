import { PrismaClient, type bookings, type invoices, type users, type vehicles } from "@prisma/client";
import PDFDocument from 'pdfkit';
import minioClient from "../config/minio.ts";
import redisClient from "../config/redis.ts";
import { generateInvoicePDF } from "../../utils/pdfGenerator.ts";
import { notifyAdmin } from "../../utils/socket.util.ts";

const prisma = new PrismaClient();
const DEPOSIT_AMOUNT = 500000;
const BUCKET_NAME = "rentcar";

export const createPaymentUrlService = async (userId: string, bookingId: number) => {
  const booking = await prisma.bookings.findUnique({
    where: { id: bookingId },
  });

  if (!booking) throw new Error("Booking không tồn tại");
  if (booking.user_id !== userId) throw new Error("Bạn không có quyền thanh toán booking này");
  if (booking.status !== "pending") throw new Error("Booking không ở trạng thái chờ thanh toán");

  const now = new Date();
  const createdTime = new Date(booking.created_at!); 
  const diffMinutes = (now.getTime() - createdTime.getTime()) / (1000 * 60);
  
  if (diffMinutes > 30) {
      await prisma.bookings.update({ where: { id: bookingId }, data: { status: "cancelled" } });
      throw new Error("Đơn đặt xe đã hết hạn thanh toán (quá 30 phút).");
  }
  const mockUrl = `https://sandbox.vnpay.vn/paymentv2/vpcpay.html?amount=${DEPOSIT_AMOUNT}&orderInfo=Booking_${bookingId}`;
  
  return mockUrl;
};

export const processPaymentWebhookService = async (data: { bookingId: number, transactionId: string, responseCode: string }) => {
    const { bookingId, transactionId, responseCode } = data;

    if (responseCode !== '00') {
        throw new Error("Giao dịch thanh toán thất bại");
    }

    return prisma.$transaction(async (tx) => {
        const booking = await tx.bookings.findUnique({ where: { id: bookingId } });
        if (!booking) throw new Error("Booking không tồn tại");
        
        if (booking.status === "confirmed") return booking;

        if (booking.status === "cancelled") throw new Error("Booking đã bị hủy trước đó (do quá hạn)");

        const updatedBooking = await tx.bookings.update({
            where: { id: bookingId },
            data: {
                status: "confirmed",        
                booking_deposit_paid: DEPOSIT_AMOUNT, 
                confirmed_at: new Date(),
            }
        });

        // 3. Tạo bản ghi thanh toán
        await tx.payments.create({
            data: {
                booking_id: bookingId,
                user_id: booking.user_id,
                amount: DEPOSIT_AMOUNT,
                provider: "VNPAY_MOCK", 
                provider_payment_id: transactionId,
                status: "successful",
                type: "BOOKING_DEPOSIT", 
                paid_at: new Date(),
                currency: "VND"
            }
        });

        await redisClient.del(`booking:detail:${bookingId}`);
        await redisClient.del("bookings:admin:page:1");

        return updatedBooking;
    });
}

function generateInvoiceNumber(): string {
  const now = new Date();
  const yyyy = now.getFullYear().toString();
  const mm = String(now.getMonth() + 1).padStart(2, "0");
  const dd = String(now.getDate()).padStart(2, "0");
  const rand = Math.floor(1000 + Math.random() * 9000);
  return `INV-${yyyy}${mm}${dd}-${rand}`;
}

export const confirmPayment = async (paymentId: string, needInvoice: boolean = true) => {
  const payment = await prisma.payments.findUnique({
    where: { id: Number(paymentId) },
    include: {
      bookings: { 
          include: { 
              users: true, 
              vehicles: true,
          } 
      },
    },
  });

  if (!payment) throw new Error("Không tìm thấy thanh toán");
  if (payment.status === "successful" || payment.status === "paid") throw new Error("Thanh toán này đã được xác nhận trước đó");

  const booking = payment.bookings;
  if (!booking) throw new Error("Thanh toán không gắn với booking hợp lệ");
  
  if (booking.status !== "returned" && booking.status !== "completed") {
      throw new Error("Chỉ xác nhận thanh toán cuối cùng khi xe đã được trả");
  }

  const now = new Date(); 
  let updatedPayment = null;
  let createdInvoice = null;

  await prisma.$transaction(async (tx) => {
    updatedPayment = await tx.payments.update({
      where: { id: payment.id },
      data: {
        status: "successful", 
        paid_at: now,
      },
    });

    if (needInvoice) {
      const TAX_RATE = 0.08;
      let baseAmount = 0;
      let taxAmount = 0;
      let totalAmount = Number(payment.amount ?? 0); 

      if (payment.type === "RENTAL_FEE") {
        baseAmount = Math.round(totalAmount / (1 + TAX_RATE));
        taxAmount = Math.round(totalAmount - baseAmount);
      } else {
        baseAmount = totalAmount;
        taxAmount = 0;
      }

      createdInvoice = await tx.invoices.create({
        data: {
          invoice_number: generateInvoiceNumber(),
          booking_id: booking.id,
          payment_id: payment.id,
          user_id: booking.user_id,
          base_amount: baseAmount,
          surcharges_amount: 0,
          tax_rate: TAX_RATE,
          tax_amount: taxAmount,
          total_amount: Math.round(baseAmount + taxAmount),
          issued_by: booking.confirmed_by ?? null, 
          issued_at: now
        },
      });
    }

    await tx.bookings.update({
      where: { id: booking.id },
      data: {
        status: "completed",
        updated_at: now,
      },
    });

  });

  let finalInvoice = createdInvoice;

  if (createdInvoice && needInvoice && booking.vehicles && booking.users) {
    try {
      console.log("📄 Đang tạo PDF hóa đơn...");

      const pdfData = {
          invoice: createdInvoice,
          user: { 
              name: booking.users.name, 
              email: booking.users.email,
              phone: booking.users.phone // Thêm phone nếu cần
          },
          vehicle: { 
              title: booking.vehicles.title, 
              plate_number: booking.vehicles.plate_number 
          }
      };

      // 1. Tạo Buffer PDF (sẽ dùng font tiếng Việt)
      const pdfBuffer = await generateInvoicePDF(pdfData);
      
      // 2. Upload lên MinIO
      const pdfObjectName = `invoices/${createdInvoice.invoice_number}.pdf`;
      const bucketName = process.env.MINIO_BUCKET_NAME || 'rentcar'; // Đảm bảo biến này đúng
      
      await minioClient.putObject(
        bucketName,
        pdfObjectName,
        pdfBuffer,
        pdfBuffer.length,
        { "Content-Type": "application/pdf" }
      );
      console.log("✅ Upload PDF lên MinIO thành công");

      // 3. Tạo Presigned URL (Link xem được)
      // Lưu ý: expiry (giây) - ví dụ 7 ngày = 604800
      const presignedUrl = await minioClient.presignedGetObject(
        bucketName,
        pdfObjectName,
        7 * 24 * 60 * 60 
      );

      // 4. Cập nhật DB với link PDF
      finalInvoice = await prisma.invoices.update({
        where: { id: createdInvoice.id },
        data: { pdf_url: presignedUrl }, 
      });
      
    } catch (error: any) {
      // Log lỗi chi tiết để debug
      console.error("⚠️ Lỗi xuất/upload PDF:", error);
      // Không throw error ở đây để không làm fail cả request xác nhận thanh toán
    }
  } else {
      if (needInvoice && !createdInvoice) console.warn("⚠️ Invoice record không được tạo trong Transaction.");
  }
  
  await redisClient.del(`booking:detail:${booking.id}`);
  await redisClient.del("bookings:admin:page:1");

  notifyAdmin('BOOKING'); 
  notifyAdmin('INVOICE');

  return { payment: updatedPayment, invoice: finalInvoice };

};

const refreshInvoiceUrl = async (pdfPathOrUrl: string | null) => {
    if (!pdfPathOrUrl) return null;
    try {
        if (pdfPathOrUrl.startsWith("http")) {
            return pdfPathOrUrl; 
        }

        return await minioClient.presignedGetObject(BUCKET_NAME, pdfPathOrUrl, 24 * 60 * 60); 
    } catch (error) {
        console.error("MinIO Error:", error);
        return null;
    }
};

export const getInvoices = async (
  filters: { user_id?: string; booking_id?: number; phone?: string; invoice_number?: string },
  page: number = 1,
  limit: number = 10
) => {
  const skip = (page - 1) * limit;
  const where: any = {};

  if (filters.user_id) where.user_id = filters.user_id;
  if (filters.booking_id !== undefined) where.booking_id = filters.booking_id;
  if (filters.invoice_number) where.invoice_number = { contains: filters.invoice_number, mode: 'insensitive' };
  
  if (filters.phone) {
      where.users = {
          phone: { contains: filters.phone, mode: 'insensitive' } 
      };
  }

  const [invoices, total] = await prisma.$transaction([
      prisma.invoices.findMany({
        where,
        include: {
          bookings: {
              include: {
                  vehicles: { select: { title: true, plate_number: true } }
              }
          },
          users: { select: { id: true, name: true, email: true, phone: true } },
          payments: { select: { provider: true, status: true, paid_at: true } },
        },
        orderBy: { issued_at: "desc" },
        take: limit,
        skip,
      }),
      prisma.invoices.count({ where })
  ]);

  const invoicesWithUrls = await Promise.all(
      invoices.map(async (inv) => {
          const signedUrl = await refreshInvoiceUrl(inv.pdf_url);
          return { ...inv, pdf_url: signedUrl };
      })
  );

  const totalPages = Math.ceil(total / limit);

  return {
      invoices: invoicesWithUrls,
      pagination: {
          totalItems: total,
          currentPage: page,
          totalPages,
          limit,
          hasNextPage: page < totalPages
      }
  };
};

export const getInvoiceById = async (id: number) => {
  const invoice = await prisma.invoices.findUnique({
    where: { id },
    include: {
      bookings: {
          include: {
              vehicles: { include: { vehicle_type: true } }, 
              locations_bookings_pickup_location_idTolocations: true, 
          }
      },
      payments: true,
      users: { select: { id: true, name: true, email: true, phone: true, is_verified: true } },
    },
  });

  if (!invoice) return null;

  const signedUrl = await refreshInvoiceUrl(invoice.pdf_url);
  
  return { ...invoice, pdf_url: signedUrl };
};