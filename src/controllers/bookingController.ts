import type { Request, Response } from "express";
import { cancelBooking, createBooking, extendBookingService, getBookingDetails, getBookings, pickupBooking, returnBookingService } from "../services/bookingServices.ts";

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

export const pickupBookingHandler = async (req: Request, res: Response) => {
  try {
    const bookingIdString = req.params.id;
    const { security_deposit, payment_method } = req.body; 

    if (!bookingIdString) return res.status(400).json({ message: "Thiếu ID booking" });

    const bookingId = parseInt(bookingIdString, 10);
    if (isNaN(bookingId)) return res.status(400).json({ message: "ID booking không hợp lệ" });

    if (!security_deposit) return res.status(400).json({ message: "Thiếu thông tin tiền cọc thế chấp xe" });

    const user = (req as any).user;
    
    const result = await pickupBooking(
      user,
      bookingId,
      Number(security_deposit),
      payment_method || "cash"
    );

    return res.status(200).json({
      message: "✅ Khách đã nhận xe thành công",
      data: result,
    });
  } catch (error: any) {
    return res.status(500).json({ message: error.message });
  }
};

export const extendBookingHandler = async (req: Request, res: Response) => {
  try {
    const user = (req as any).user;
    const { id: bookingIdString } = req.params;

    if (!bookingIdString) return res.status(400).json({ message: "Thiếu ID booking" });
    const bookingId = parseInt(bookingIdString, 10);
    if (isNaN(bookingId)) return res.status(400).json({ message: "ID booking không hợp lệ" });

    const updatedBooking = await extendBookingService(user, bookingId);

    return res.status(200).json({
      message: "✅ Gia hạn thời gian thuê thành công",
      data: updatedBooking,
    });
  } catch (error: any) {
    // Nếu lỗi do trùng lịch (409 Conflict) hoặc lỗi validation (400 Bad Request)
    const status = error.message.includes("trùng lịch") ? 409 : 400;
    return res.status(status).json({ 
        message: error.message,
        warning: "Vui lòng trả xe đúng hạn để tránh phát sinh phí phạt vi phạm hợp đồng." 
    });
  }
};

export const returnBookingHandler = async (req: Request, res: Response) => {
  try {
    const bookingIdString = req.params.id;
    // Admin nhập thêm phí phát sinh (vệ sinh, trầy xước, xăng xe...)
    const { actual_end_datetime, cleaning_fee, damage_fee, other_fee, compensation_fee, note } = req.body;

    if (!bookingIdString) return res.status(400).json({ message: "Thiếu ID booking" });

    const bookingId = parseInt(bookingIdString, 10);
    if (isNaN(bookingId)) return res.status(400).json({ message: "ID booking không hợp lệ" });

    if (!actual_end_datetime) { // Bắt buộc phải có giờ trả xe thực tế
      return res.status(400).json({ message: "Thiếu thời gian trả xe thực tế (actual_end_datetime)" });
    }
    
    const actualReturnTime = new Date(actual_end_datetime);
    if (isNaN(actualReturnTime.getTime())) {
      return res.status(400).json({ message: "Thời gian trả xe không hợp lệ (cần định dạng ISO 8601)" });
    }

    const user = (req as any).user;
    
    const result = await returnBookingService(
      user, 
      bookingId, 
      actualReturnTime,
      {
        cleaning_fee: Number(cleaning_fee || 0),
        damage_fee: Number(damage_fee || 0),
        other_fee: Number(other_fee || 0),
        compensation_fee: Number(compensation_fee || 0),
        note: note || ""
      }
    );

    return res.status(200).json({
      message: "✅ Trả xe và quyết toán thành công",
      data: result,
    });
  } catch (error: any) {
    return res.status(500).json({ message: error.message });
  }
};
