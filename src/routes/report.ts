import { Router } from "express";
import { verifyAccessToken, verifyAdmin } from "../midleware/authMiddleware.ts";
import { validate } from "../midleware/validateMiddleware.ts";
import { earningsReportSchema } from "../../utils/validate.ts";
import { getDashboardStatsHandler, getEarningsReportHandler, getRentedVehiclesReportHandler } from "../controllers/reportController.ts";


const reportRouter = Router();

reportRouter.use(verifyAccessToken);
reportRouter.use(verifyAdmin);


//Báo cáo doanh thu trong một khoảng thời gian.
reportRouter.post(
    "/earnings", 
    validate(earningsReportSchema), 
    getEarningsReportHandler
);


//Lấy danh sách các xe ĐANG ĐƯỢC THUÊ 
reportRouter.get("/rented-vehicles", getRentedVehiclesReportHandler);

/**
 * GET /reports/stats
 * Lấy các số liệu thống kê nhanh cho Dashboard (Tổng user, xe, booking...)
 */
reportRouter.get("/stats", getDashboardStatsHandler);


export default reportRouter;