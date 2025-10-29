import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

function generateInvoiceNumber(): string {
  const now = new Date();
  const yyyy = now.getFullYear().toString();
  const mm = String(now.getMonth() + 1).padStart(2, "0");
  const rand = Math.floor(1000 + Math.random() * 9000);
  return `INV-${yyyy}${mm}-${rand}`;
}

export const confirmPayment = async (paymentId: string, needInvoice: boolean = true) => {
  const payment = await prisma.payments.findUnique({
    where: { id: Number(paymentId) },
    include: {
      bookings: { include: { users: true } },
    },
  });

  if (!payment) throw new Error("Không tìm thấy thanh toán");
  if (payment.status === "paid") throw new Error("Thanh toán này đã được xác nhận");

  const booking = payment.bookings;
  if (!booking) throw new Error("Thanh toán không gắn với booking hợp lệ");
  if (booking.status !== "returned")
    throw new Error("Chỉ xác nhận thanh toán sau khi xe đã được trả");

  const updatedPayment = await prisma.payments.update({
    where: { id: payment.id },
    data: {
      status: "paid",
      paid_at: new Date(),
    },
  });

  let invoice = null;
  if (needInvoice) {
    const taxRate = 0.1;
    const baseAmount = Number(updatedPayment.amount ?? 0);
    const total = baseAmount + baseAmount * taxRate;

    invoice = await prisma.invoices.create({
      data: {
        invoice_number: generateInvoiceNumber(),
        booking_id: booking.id,
        payment_id: updatedPayment.id,
        user_id: booking.user_id,
        amount: baseAmount,
        tax_rate: taxRate * 100, 
        total_amount: total,
        issued_by: booking.confirmed_by ?? null,
      },
    });
  }

  await prisma.logs.create({
    data: {
      user_id: booking.confirmed_by ?? null,
      action: "CONFIRM_PAYMENT",
      object_type: "Payment",
      object_id: paymentId.toString(),
      meta: { amount: payment.amount, invoice: !!invoice },
    },
  });

  await prisma.bookings.update({
    where: { id: booking.id },
    data: {
      status: "completed", 
      updated_at: new Date(),
    },
  });

  return { payment: updatedPayment, invoice };
};
