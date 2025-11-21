import cron from "node-cron";
import { PrismaClient } from "@prisma/client";
import redisClient from "../config/redis.ts";

const prisma = new PrismaClient();

export const startBookingCronJob = () => {
  cron.schedule("* * * * *", async () => {
    console.log("⏳ [CRON] Đang quét các đơn booking quá hạn 30 phút...");

    try {
      const thirtyMinutesAgo = new Date(Date.now() - 30 * 60 * 1000);

      const expiredBookings = await prisma.bookings.findMany({
        where: {
          status: "pending",
          created_at: {
            lt: thirtyMinutesAgo, 
          },
        },
        select: { id: true, vehicle_id: true }, 
      });

      if (expiredBookings.length > 0) {
        console.log(`🔥 Tìm thấy ${expiredBookings.length} đơn quá hạn. Đang hủy...`);

        const idsToCancel = expiredBookings.map((b) => b.id);

        await prisma.bookings.updateMany({
          where: { id: { in: idsToCancel } },
          data: { status: "cancelled" },
        });
        

        await redisClient.del("vehicles:page:1");

        for (const booking of expiredBookings) {
            await redisClient.del(`booking:detail:${booking.id}`);
        }

        console.log("✅ [CRON] Đã hủy thành công các đơn quá hạn.");
      }
    } catch (error) {
      console.error("❌ [CRON ERROR] Lỗi khi chạy cron job:", error);
    }
  });
};