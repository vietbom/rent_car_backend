import { Router } from "express";
import { createPaymentUrlHandler, paymentWebhookHandler } from "../controllers/paymentController.ts";
import { verifyAccessToken } from "../midleware/authMiddleware.ts";

const paymentRouter = Router();

// User gọi để lấy link thanh toán (Yêu cầu đăng nhập)
paymentRouter.post("/create-url", verifyAccessToken, createPaymentUrlHandler);

// Webhook (Không cần verifyAccessToken của user, nhưng nên verify IP/Signature của Payment Gateway)
// Ở môi trường dev demo thì để public
paymentRouter.post("/webhook", paymentWebhookHandler);

export default paymentRouter;