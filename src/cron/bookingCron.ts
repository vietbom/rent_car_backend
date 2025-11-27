import cron from "node-cron";
import { PrismaClient } from "@prisma/client";
import redisClient from "../config/redis.ts";
import { notifyAdmin } from "../../utils/socket.util.ts";

const prisma = new PrismaClient();

export const startBookingCronJob = () => {
  cron.schedule("* * * * *", async () => {

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
        console.log(`⚠️ [CRON] Phát hiện ${expiredBookings.length} đơn quá hạn. Đang xử lý...`);
        const idsToCancel = expiredBookings.map((b) => b.id);

        await prisma.bookings.updateMany({
          where: { id: { in: idsToCancel } },
          data: { status: "cancelled" },
        });
        

        await redisClient.del("vehicles:page:1");

        for (const booking of expiredBookings) {
            await redisClient.del(`booking:detail:${booking.id}`);
        }
        notifyAdmin("BOOKING", {
            action: "auto_cancel",
            cancelledIds: idsToCancel,
        });
        console.log(`✅ [CRON] Đã hủy thành công ${expiredBookings.length} đơn.`);
      }
    } catch (error) {
      console.error("❌ [CRON ERROR] Lỗi khi chạy cron job:", error);
    }
  });
};