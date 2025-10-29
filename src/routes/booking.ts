import { Router } from "express";
import { verifyAccessToken, verifyAdmin } from "../midleware/authMiddleware.ts";
import { cancelBookingHandler, confirmBookingHandler, createBookingHandler, getBookingDetailsHandler, getBookingsHandler, pickupBookingHandler, returnBookingHandler } from "../controllers/bookingController.ts";
import { createBookingSchema } from "../../utils/validate.ts";
import { validate } from "../midleware/validateMiddleware.ts";

const bookingRouter = Router();


// --- BẮT BUỘC ĐĂNG NHẬP CHO TẤT CẢ ROUTE ---
bookingRouter.use(verifyAccessToken);

// POST /bookings — (Customer) tạo booking
bookingRouter.post("/", validate(createBookingSchema), createBookingHandler);

// GET /bookings — (Customer) xem booking của mình, (Admin) xem tất cả
bookingRouter.get("/", getBookingsHandler);

// GET /bookings/:id — (Customer) xem chi tiết 1 booking (nếu là của mình), (Admin) xem bất kỳ
bookingRouter.get("/:id", getBookingDetailsHandler);

// PATCH /bookings/:id/cancel — (Customer) hủy booking (nếu là của mình), (Admin) hủy bất kỳ
bookingRouter.patch("/:id/cancel", cancelBookingHandler);


// POST /bookings/:id/confirm — (Admin) xác nhận 1 booking
bookingRouter.post("/:id/confirm", verifyAdmin, confirmBookingHandler);

// POST /bookings/:id/pickup — (Admin) xác nhận khách đã lấy xe
bookingRouter.post("/:id/pickup", verifyAdmin, pickupBookingHandler);

// POST /bookings/:id/return — (Admin) xác nhận khách đã trả xe (tính phụ phí)
bookingRouter.post("/:id/return", verifyAdmin, returnBookingHandler);
export default bookingRouter;