import type { Request, Response } from "express";
import { createReview } from "../services/reviewService.ts";

interface AuthenticatedRequest extends Request {
  user?: { id: string; role?: string };
}

export const createReviewHandler = async (req: AuthenticatedRequest, res: Response) => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res
        .status(401)
        .json({ message: "Không tìm thấy thông tin người dùng" });
    }

    const reviewData = req.body;

    const newReview = await createReview(userId, reviewData);

    res.status(201).json({
      message: "Gửi đánh giá thành công",
      data: newReview,
    });
    
  } catch (error: any) {
    if (error.message.includes("Bạn không có quyền")) {
      return res.status(403).json({ message: error.message }); 
    }
    if (error.message.includes("Bạn chỉ có thể đánh giá")) {
      return res.status(400).json({ message: error.message }); 
    }
    if (error.message.includes("Bạn đã đánh giá")) {
      return res.status(409).json({ message: error.message }); 
    }
    if (error.message.includes("Booking không tồn tại")) {
      return res.status(404).json({ message: error.message });
    }

    res.status(500).json({ message: error.message || "Lỗi máy chủ" });
  }
};