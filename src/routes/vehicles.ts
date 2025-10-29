import { Router } from "express";
import { getDetailVehicleHander, getVehicleHandler } from "../controllers/vehicleController.ts";
import { verifyAccessToken } from "../midleware/authMiddleware.ts";

const vehicleRouter = Router();

vehicleRouter.use(verifyAccessToken);

vehicleRouter.get("/", getVehicleHandler);

vehicleRouter.get("/:id", getDetailVehicleHander);

export default vehicleRouter;