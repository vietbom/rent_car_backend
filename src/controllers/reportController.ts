import type { Request, Response } from "express";
import { getDashboardStats, getEarningsReport, getRentedVehiclesReport } from "../services/reportService.ts";

export const getEarningsReportHandler = async (req: Request, res: Response) => {
  try {
    const { startDate, endDate } = req.body;
    const report = await getEarningsReport(String(startDate), String(endDate));

    return res.status(200).json({
      message: "Báo cáo tài chính",
      data: report,
    });
  } catch (error: any) {
    return res.status(500).json({ message: "Lỗi tạo báo cáo", error: error.message });
  }
};

export const getRentedVehiclesReportHandler = async (req: Request, res: Response) => {
  try {
    const report = await getRentedVehiclesReport();
    return res.status(200).json(report);
  } catch (error: any) {
    return res.status(500).json({ message: "Lỗi hệ thống", error: error.message });
  }
};

export const getDashboardStatsHandler = async (req: Request, res: Response) => {
  try {
    const stats = await getDashboardStats();
    return res.status(200).json({ 
        message: "Lấy số liệu Dashboard thành công", 
        data: stats 
    });
  } catch (error: any) {
    return res.status(500).json({ message: "Lỗi server", error: error.message });
  }
};