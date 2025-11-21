import { Router } from "express";
import { createLocationHandler, forgotPassword, getLocationsHandler, loginHandler, logoutHandler, refreshHandler, registerHandler, resetPassword,} from "../controllers/authController.ts";
import { verifyAccessToken, verifyAdmin,} from "../midleware/authMiddleware.ts";
import { createRentalPackageHandler, createVehicleHandler, createVehicleTypeHandler, deleteRentalPackageHandler, deleteVehicleHandler, deleteVehicleTypeHandler, getRentalPackagesHandler, getVehicleTypesHandler, updateRentalPackageHandler, updateVehicleHandler, updateVehicleTypeHandler, } from "../controllers/vehicleController.ts";
import multer from "multer";
import { confirmPaymentHandler, fetchInvoiceById, fetchInvoices } from "../controllers/paymentController.ts";
import { validate } from "../midleware/validateMiddleware.ts";
import { createLocationSchema, createRentalPackageSchema, createVehicleTypeSchema, updateRentalPackageSchema, updateVehicleTypeSchema } from "../../utils/validate.ts";

const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

const adminRouter = Router();

/** Các route không cần xác thực trước */
// adminRouter.post("/login", (req, res, next) => {
//   req.body.expectedRole = "admin";
//   loginHandler(req, res, next);
// });
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

// --- API LOẠI XE (VEHICLE TYPES) ---
adminRouter.post("/vehicle-types", validate(createVehicleTypeSchema), createVehicleTypeHandler);
adminRouter.get("/vehicle-types", getVehicleTypesHandler);
adminRouter.put("/vehicle-types/:id", validate(updateVehicleTypeSchema), updateVehicleTypeHandler);
adminRouter.delete("/vehicle-types/:id", deleteVehicleTypeHandler);


// --- API GÓI THUÊ (RENTAL PACKAGES) ---
adminRouter.post("/rental-packages", validate(createRentalPackageSchema), createRentalPackageHandler);
adminRouter.get("/rental-packages/:typeId", getRentalPackagesHandler); 
adminRouter.put("/rental-packages/:id", validate(updateRentalPackageSchema), updateRentalPackageHandler);
adminRouter.delete("/rental-packages/:id", deleteRentalPackageHandler);

adminRouter.post("/vehicles", upload.array('images', 5), createVehicleHandler);
adminRouter.put("/vehicles/:id",upload.array('images', 5), updateVehicleHandler);
adminRouter.delete("/vehicles/:id", deleteVehicleHandler);

// --- Quản lý thanh toán ---
adminRouter.post("/payments/:id/confirm", confirmPaymentHandler);

adminRouter.get("/invoices/", fetchInvoices);
adminRouter.get("/invoices/:id", fetchInvoiceById);

adminRouter.post("/locations", validate(createLocationSchema), createLocationHandler);
adminRouter.get("/locations", getLocationsHandler);

export default adminRouter;
