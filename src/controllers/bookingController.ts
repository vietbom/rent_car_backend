import type { Request, Response } from "express";
import { cancelBooking, confirmBooking, createBooking, getBookingDetails, getBookings, pickupBooking, returnBooking } from "../services/bookingServices.ts";

export const createBookingHandler = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id; 
    const bookingData = req.body;
    
    const newBooking = await createBooking(userId, bookingData);

    res.status(201).json({
      message: "Đặt xe thành công",
      booking: newBooking,
    });
  } catch (error: any) {
    if (error.message.includes("Xe đã được đặt")) {
      return res.status(409).json({ message: error.message }); 
    }
    res.status(500).json({ message: error.message || "Lỗi máy chủ"});
  }
};

export const getBookingsHandler = async (req: Request, res: Response) => {
  try {
    const user = (req as any).user;
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;

    const result = await getBookings(user, page, limit);

    res.status(200).json({
      message: "Lấy danh sách booking thành công",
      ...result,
    });
  } catch (error: any) {
    res.status(500).json({
      message: error.message || "Lỗi máy chủ",
    });
  }
};

export const getBookingDetailsHandler = async (req: Request, res: Response) => {
  try {
    const user = (req as any).user; 

    const {id: bookingIdString} = req.params;

    if (!bookingIdString) {
      return res.status(400).json({ message: "Yêu cầu không hợp lệ (thiếu ID booking)" });
    }

    const bookingId = parseInt(bookingIdString, 10);

    if (isNaN(bookingId)) {
      return res.status(400).json({ message: "ID booking không hợp lệ (phải là một số)" });
    }

    const booking = await getBookingDetails(user, bookingId);

    res.status(200).json({
      message: "Lấy chi tiết booking thành công",
      data: booking,
    });
  } catch (error: any) {
    if (error.code === 'P2025' || error.message.includes("Không tìm thấy")) {
        return res.status(404).json({ message: "Không tìm thấy booking hoặc bạn không có quyền xem." });
    }
    res.status(500).json({
      message: error.message || "Lỗi máy chủ",
    });
  }
};

export const cancelBookingHandler = async(req: Request, res: Response) => {
    try {
        const user = (req as any).user; 

        const {id: bookingIdString} = req.params;

        if (!bookingIdString) {
          return res.status(400).json({ message: "Yêu cầu không hợp lệ (thiếu ID booking)" });
        }

        const bookingId = parseInt(bookingIdString, 10);

        if (isNaN(bookingId)) {
          return res.status(400).json({ message: "ID booking không hợp lệ (phải là một số)" });
        }

        const updatedBooking = await cancelBooking(user, bookingId);

        return res.status(200).json({
            message: "Hủy booking thành công",
            booking: updatedBooking,
        });
    } catch (error: any) {
        if (error.message.includes("Không thể hủy booking")) {
            return res.status(400).json({ message: error.message });
        }

        if (error.message.includes("không có quyền")) {
            return res.status(403).json({ message: error.message });
        }

        return res.status(500).json({ message: error.message || "Lỗi máy chủ" });
    }
}

export const confirmBookingHandler = async(req: Request, res: Response) => {
  try {
      const bookingIdString = req.params.id;

      if (!bookingIdString) {
        return res
          .status(400)
          .json({ message: "ID booking không hợp lệ (không tìm thấy)" });
      }

      const bookingId = parseInt(bookingIdString, 10);
      if (isNaN(bookingId)) {
        return res.status(400).json({ message: "ID booking không hợp lệ" });
      }
      if (isNaN(bookingId)) {
        return res
          .status(400)
          .json({ message: "ID booking không hợp lệ (phải là một số)" });
      }

      const user = (req as any).user!;
      const confirmedBooking = await confirmBooking(user, bookingId);

      res.status(200).json({
        message: "Xác nhận booking thành công",
        data: confirmedBooking,
      });
  } catch (error: any) {
      if (error.message.includes("Booking không tìm thấy")) {
        return res.status(404).json({ message: error.message });
      }
      if (error.message.includes("Chỉ có thể xác nhận")) {
        return res.status(409).json({ message: error.message });
      }
      res.status(500).json({ message: error.message || "Lỗi máy chủ" });
  }
};

export const pickupBookingHandler = async (req: Request, res: Response) => {
  try {
    const bookingIdString = req.params.id;
    const { deposit_amount, payment_method } = req.body;

    if (!bookingIdString) {
      return res.status(400).json({ message: "Thiếu ID booking" });
    }

    const bookingId = parseInt(bookingIdString, 10);
    if (isNaN(bookingId)) {
      return res.status(400).json({ message: "ID booking không hợp lệ" });
    }

    if (!deposit_amount || !payment_method) {
      return res.status(400).json({
        message: "Thiếu thông tin tiền cọc hoặc phương thức thanh toán",
      });
    }

    const user = (req as any).user!;
    const result = await pickupBooking(
      user,
      bookingId,
      Number(deposit_amount),
      payment_method
    );

    return res.status(200).json({
      message: "✅ Đã xác nhận khách hàng nhận xe thành công",
      data: result,
    });
  } catch (error: any) {
    //console.error("❌ Pickup booking error:", error);
    return res.status(500).json({ message: error.message });
  }
};

export const returnBookingHandler = async (req: Request, res: Response) => {
  try {
    const bookingIdString = req.params.id;
    const { extra_fee } = req.body; 

    if (!bookingIdString) {
      return res.status(400).json({ message: "Thiếu ID booking" });
    }

    const bookingId = parseInt(bookingIdString, 10);
    if (isNaN(bookingId)) {
      return res.status(400).json({ message: "ID booking không hợp lệ" });
    }

    const user = (req as any).user!;
    const result = await returnBooking(user, bookingId, Number(extra_fee ?? 0));

    return res.status(200).json({
      message: "✅ Đã xác nhận khách hàng trả xe thành công",
      data: result,
    });
  } catch (error: any) {
    // console.error("❌ Return booking error:", error);
    return res.status(500).json({ message: error.message });
  }
};
