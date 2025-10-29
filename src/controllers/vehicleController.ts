import type { NextFunction, Request, Response } from "express";
import {createVehicle, deleteVehicle, getVehicleById, getVehicles, updateVehicle,} from "../services/vehicleServices.ts";

export const createVehicleHandler = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const files = req.files as Express.Multer.File[];
    const data = req.body;

    const newVehicle = await createVehicle(data, files);
    res.status(201).json({
      message: "Tạo xe mới thành công",
      data: newVehicle,
    });
  } catch (error: any) {
    if (error.message.includes("Biển số xe") || error.message.includes("Địa điểm")) {
      return res.status(409).json({ message: error.message });
    }
    if (error.message.includes("bắt buộc")) {
      return res.status(400).json({ message: error.message });
    }
    res.status(500).json({ message: error.message || "Lỗi máy chủ" });
  }
};

export const updateVehicleHandler = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const vehicleId = parseInt(req.params.id, 10);
    if (isNaN(vehicleId)) {
      return res.status(400).json({ message: "ID xe không hợp lệ" });
    }

    const updatedVehicle = await updateVehicle(vehicleId, req.body);
    res.status(200).json({
      message: "Cập nhật xe thành công",
      data: updatedVehicle,
    });
  } catch (error: any) {
    if (error.message.includes("Không tìm thấy xe")) {
      return res.status(404).json({ message: error.message });
    }
    if (error.message.includes("Biển số xe")) {
      return res.status(409).json({ message: error.message });
    }
    res.status(500).json({ message: error.message || "Lỗi máy chủ" });
  }
};

export const deleteVehicleHandler = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const vehicleId = parseInt(req.params.id, 10);
    if (isNaN(vehicleId)) {
      return res.status(400).json({ message: "ID xe không hợp lệ" });
    }

    await deleteVehicle(vehicleId);
    res.status(200).json({ message: "Xóa xe thành công" });
  } catch (error: any) {
    if (error.message.includes("Không tìm thấy xe")) {
      return res.status(404).json({ message: error.message });
    }
    res.status(500).json({ message: error.message || "Lỗi máy chủ" });
  }
};

export const getVehicleHandler = async(req: Request, res: Response) => {
    try {
        const page = parseInt(req.query.page as string) || 1;
        const limit = parseInt(req.query.limit as string) || 10;
        let searchTerm = req.query.search as string | undefined;
        if (searchTerm) {
          if (searchTerm.length > 100) { 
            return res.status(400).json({ 
              message: "Từ khóa tìm kiếm quá dài. Tối đa 100 ký tự." 
            });
          }
          searchTerm = searchTerm.trim();
        }
        const data = await getVehicles(page, limit, searchTerm);
        res.status(200).json({ 
            message: "Lay thong tin xe thanh cong",
            ...data,
        });
    } catch (error: any) {
        res.status(500).json({ message: error.message || "Lỗi máy chủ" });
    }
}

export const getDetailVehicleHander = async (req: Request, res: Response) => {
    try {
        const id = parseInt(req.params.id, 10);
        if (isNaN(id)) return res.status(400).json({ message: "ID xe không hợp lệ" });

        const vehicle = await getVehicleById(id);

        res.status(200).json({
            message: "Lấy thông tin xe thành công",
            data: vehicle,
        });
    } catch (error: any) {
        if (error.message.includes("Không tìm thấy xe")) {
            return res.status(404).json({ message: error.message });
        }
        res.status(500).json({ message: error.message || "Lỗi máy chủ" });
    }
};