import type { Request, Response } from "express";
import { confirmPayment } from "../services/paymentService.ts";


export const confirmPaymentHandler = async (req: Request, res: Response) => {
  try {
    const paymentId = req.params.id;
    const { needInvoice } = req.body;

    if (!paymentId) {
      return res.status(400).json({ message: "Thiếu ID thanh toán" });
    }

    const result = await confirmPayment(paymentId, !!needInvoice);

    return res.status(200).json({
      message: `✅ Xác nhận thanh toán thành công${needInvoice ? " và đã xuất hóa đơn" : ""}`,
      data: result,
    });
  } catch (error: any) {
    return res.status(500).json({
      message: "Lỗi khi xác nhận thanh toán",
      error: error.message,
    });
  }
};
