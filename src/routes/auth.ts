import { Router } from "express";
import { forgotPassword, getLocationsHandler, getProfileHandler, loginHandler, logoutHandler, refreshHandler, registerHandler, resetPassword } from "../controllers/authController.ts";
import { verifyAccessToken } from "../midleware/authMiddleware.ts";
import { fetchInvoiceById } from "../controllers/paymentController.ts";

const authRouter = Router();

authRouter.post('/register', registerHandler)
authRouter.post('/login', loginHandler)
authRouter.post('/refresh', refreshHandler)
authRouter.post('/logout', verifyAccessToken, logoutHandler)

authRouter.post('/forgot-password', forgotPassword)
authRouter.post("/reset-password", resetPassword);

authRouter.get('/',verifyAccessToken, getProfileHandler)

authRouter.get("/locations", getLocationsHandler);
authRouter.get("/invoices/:id", fetchInvoiceById);

export default authRouter;