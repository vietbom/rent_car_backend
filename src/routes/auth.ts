import { Router } from "express";
import { forgotPassword, loginHandler, logoutHandler, refreshHandler, registerHandler, resetPassword } from "../controllers/authController.ts";
import { verifyAccessToken } from "../midleware/authMiddleware.ts";

const authRouter = Router();

authRouter.post('/register', registerHandler)
authRouter.post('/login', loginHandler)
authRouter.post('/refresh', refreshHandler)
authRouter.post('/logout', verifyAccessToken, logoutHandler)

authRouter.post('/forgot-password', forgotPassword)
authRouter.post("/reset-password", resetPassword);

export default authRouter;