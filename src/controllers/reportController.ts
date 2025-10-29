import type { Request, Response } from "express";
import { getDashboardStats, getEarningsReport, getRentedVehiclesReport } from "../services/reportService.ts";

export const getEarningsReportHandler = async (req: Request, res: Response) => {
  try {
    const { startDate, endDate } = req.body;

    const report = await getEarningsReport(String(startDate), String(endDate));

    return res.status(200).json({
      message: "Báo cáo doanh thu",
      data: report,
    });
  } catch (error: any) {
    console.error("Error generating report:", error);
    return res.status(500).json({
      message: "Lỗi khi tạo báo cáo",
      error: error.message,
    });
  }
};

export const getRentedVehiclesReportHandler = async (req: Request, res: Response) => {
  try {
    const rentedVehicles = await getRentedVehiclesReport();
    return res.status(200).json({
      message: "Danh sách xe đang được thuê",
      data: rentedVehicles,
    });
  } catch (error: any) {
    console.error("Lỗi khi lấy báo cáo xe đang được thuê:", error);
    return res.status(500).json({
      message: "Lỗi hệ thống",
      error: error.message,
    });
  }
};

export const getDashboardStatsHandler = async (req: Request, res: Response) => {
  try {
    const stats = await getDashboardStats();
    return res.status(200).json({ message: "Thống kê Dashboard thành công", data: stats });
  } catch (error: any) {
    console.error("Lỗi khi lấy thống kê dashboard:", error);
    return res.status(500).json({ message: "Lỗi khi lấy thống kê dashboard", error: error.message });
  }
};