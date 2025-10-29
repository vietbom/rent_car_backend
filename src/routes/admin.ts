import { Router } from "express";
import { createLocationHandler, forgotPassword, getLocationsHandler, loginHandler, logoutHandler, refreshHandler, registerHandler, resetPassword,} from "../controllers/authController.ts";
import { verifyAccessToken, verifyAdmin,} from "../midleware/authMiddleware.ts";
import { createVehicleHandler, deleteVehicleHandler, updateVehicleHandler, } from "../controllers/vehicleController.ts";
import multer from "multer";
import { confirmPaymentHandler } from "../controllers/paymentController.ts";
import { validate } from "../midleware/validateMiddleware.ts";
import { createLocationSchema } from "../../utils/validate.ts";

const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

const adminRouter = Router();

/** Các route không cần xác thực trước */
adminRouter.post("/login", (req, res, next) => {
  req.body.expectedRole = "admin";
  loginHandler(req, res, next);
});
adminRouter.post("/forgot-password", forgotPassword);
adminRouter.post("/reset-password", resetPassword);
adminRouter.post("/refresh", refreshHandler);


/** Các route cần token + quyền admin */
adminRouter.use(verifyAccessToken);
adminRouter.use(verifyAdmin);

adminRouter.post("/register", (req, res, next) => {
  req.body.role = "admin";
  registerHandler(req, res, next);
});

adminRouter.post("/logout", logoutHandler);

adminRouter.post("/vehicles", upload.array('images', 5), createVehicleHandler);
adminRouter.put("/vehicles/:id", updateVehicleHandler);
adminRouter.delete("/vehicles/:id", deleteVehicleHandler);

// --- Quản lý thanh toán ---
adminRouter.post("/payments/:id/confirm", confirmPaymentHandler);

adminRouter.post("/locations", validate(createLocationSchema), createLocationHandler);
adminRouter.get("/locations", getLocationsHandler);

export default adminRouter;
