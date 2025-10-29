import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

interface ReviewInput {
  booking_id: number;
  rating: number;
  comment?: string;
}

export const createReview = async (userId: string, data: ReviewInput) => {
  const { booking_id, rating, comment } = data;


  const booking = await prisma.bookings.findUnique({
    where: { id: booking_id },
  });

  if (!booking) {
    throw new Error("Booking không tồn tại");
  }


  if (booking.user_id !== userId) {
    throw new Error("Bạn không có quyền đánh giá đơn booking này");
  }

  if (booking.status !== "completed") {
    throw new Error(
      "Bạn chỉ có thể đánh giá sau khi chuyến đi đã hoàn tất (status: completed)",
    );
  }

  const existingReview = await prisma.reviews.findFirst({
    where: { booking_id: booking_id },
  });

  if (existingReview) {
    throw new Error("Bạn đã đánh giá đơn booking này rồi");
  }

  const newReview = await prisma.reviews.create({
    data: {
      booking_id: booking_id,
      user_id: userId,
      rating: rating,
      comment: comment || null, 
    },
  });

  return newReview;
};