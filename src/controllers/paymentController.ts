import type { Request, Response } from "express";
import { confirmPayment, createPaymentUrlService, getInvoiceById, getInvoices, processPaymentWebhookService } from "../services/paymentService.ts";
import { PrismaClient } from "@prisma/client";
import { notifyAdmin } from "../../utils/socket.util.ts";

const prisma = new PrismaClient();

// 1. API Tạo Link Thanh toán (Khách hàng gọi cái này)
export const createPaymentUrlHandler = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;
    const { bookingId } = req.body; // Gửi lên { "bookingId": 123 }

    if (!bookingId) return res.status(400).json({ message: "Thiếu bookingId" });

    const paymentUrl = await createPaymentUrlService(userId, bookingId);

    res.status(200).json({
      message: "Tạo link thanh toán thành công",
      url: paymentUrl, 
    });
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
};

// 2. API Webhook Xác nhận thanh toán (Bên thứ 3 như VNPay/Momo sẽ gọi cái này)
// Hoặc Frontend gọi giả lập sau khi thanh toán thành công ở môi trường Sandbox
export const paymentWebhookHandler = async (req: Request, res: Response) => {
  try {
    const { bookingId, transactionId, responseCode } = req.body;

    const result = await processPaymentWebhookService({
        bookingId: Number(bookingId),
        transactionId,
        responseCode 
    });
    
    notifyAdmin('BOOKING');

    res.status(200).json({ message: "Xác nhận thanh toán thành công", data: result });
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
};

export const confirmPaymentHandler = async (req: Request, res: Response) => {
  try {
    const paymentId = req.params.id;
    const { needInvoice } = req.body; 

    if (!paymentId) {
      return res.status(400).json({ message: "Thiếu ID thanh toán" });
    }

    const result = await confirmPayment(paymentId, !!needInvoice);

    return res.status(200).json({
      message: `✅ Xác nhận thanh toán thành công${result.invoice ? " và đã xuất hóa đơn" : ""}`,
      data: result,
    });
  } catch (error: any) {
    return res.status(500).json({
      message: "Lỗi khi xác nhận thanh toán",
      error: error.message,
    });
  }
};

export const fetchInvoices = async (req: Request, res: Response) => {
  try {
    const { user_id, booking_id, phone, invoice_number, page = "1", limit = "10" } = req.query;

    const filters: any = {};
    if (user_id) filters.user_id = String(user_id);
    
    if (booking_id) {
        const bId = Number(booking_id);
        if (!isNaN(bId)) filters.booking_id = bId;
    }

    if (phone) filters.phone = String(phone);
    if (invoice_number) filters.invoice_number = String(invoice_number);

    const result = await getInvoices(filters, Number(page), Number(limit));

    res.status(200).json({
      message: "Lấy danh sách hóa đơn thành công",
      data: result.invoices,
      pagination: result.pagination
    });
  } catch (error: any) {
    console.error("Fetch invoices error:", error);
    res.status(500).json({ message: "Lỗi máy chủ", error: error.message });
  }
};

export const fetchInvoiceById = async (req: Request, res: Response) => {
  try {
    const invoiceId = Number(req.params.id);
    if (isNaN(invoiceId)) return res.status(400).json({ message: "ID hóa đơn không hợp lệ" });

    const invoice = await getInvoiceById(invoiceId);
    
    if (!invoice) {
        return res.status(404).json({ message: "Không tìm thấy hóa đơn" });
    }

    res.status(200).json({ 
        message: "Lấy chi tiết hóa đơn thành công",
        data: invoice 
    });
  } catch (error: any) {
    console.error("Fetch invoice detail error:", error);
    res.status(500).json({ message: "Lỗi máy chủ", error: error.message });
  }
};