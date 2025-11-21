import type { NextFunction, Request, Response } from "express";
import {createRentalPackageService, createVehicle, createVehicleTypeService, deleteRentalPackageService, deleteVehicle, deleteVehicleTypeService, getRentalPackagesService, getVehicleById, getVehicles, getVehicleTypesService, updateRentalPackageService, updateVehicle, updateVehicleTypeService,} from "../services/vehicleServices.ts";

export const createVehicleTypeHandler = async (req: Request, res: Response) => {
    try {
        const newType = await createVehicleTypeService(req.body);
        res.status(201).json({ message: "Tạo loại xe thành công", data: newType });
    } catch (error: any) {
        res.status(400).json({ message: error.message });
    }
};

export const getVehicleTypesHandler = async (req: Request, res: Response) => {
    try {
        const types = await getVehicleTypesService();
        res.status(200).json({ message: "Lấy danh sách loại xe thành công", data: types });
    } catch (error: any) {
        res.status(500).json({ message: "Lỗi server" });
    }
};

export const updateVehicleTypeHandler = async (req: Request, res: Response) => {
    try {
        const id = Number(req.params.id);
        if (isNaN(id)) return res.status(400).json({ message: "ID không hợp lệ" });
        
        const updated = await updateVehicleTypeService(id, req.body);
        res.status(200).json({ message: "Cập nhật loại xe thành công", data: updated });
    } catch (error: any) {
        res.status(400).json({ message: error.message });
    }
};

export const deleteVehicleTypeHandler = async (req: Request, res: Response) => {
    try {
        const id = Number(req.params.id);
        if (isNaN(id)) return res.status(400).json({ message: "ID không hợp lệ" });
        
        await deleteVehicleTypeService(id);
        res.status(200).json({ message: "Xóa loại xe thành công" });
    } catch (error: any) {
        const status = error.message.includes("Không thể xóa") ? 409 : 404;
        res.status(status).json({ message: error.message });
    }
};

export const createRentalPackageHandler = async (req: Request, res: Response) => {
    try {
        const newPackage = await createRentalPackageService(req.body);
        res.status(201).json({ message: "Tạo gói thuê thành công", data: newPackage });
    } catch (error: any) {
        res.status(400).json({ message: error.message });
    }
};

export const getRentalPackagesHandler = async (req: Request, res: Response) => {
    try {
        const typeId = Number(req.params.typeId);
        if (isNaN(typeId)) return res.status(400).json({ message: "ID loại xe không hợp lệ" });

        const packages = await getRentalPackagesService(typeId);
        res.status(200).json({ message: "Lấy danh sách gói thuê thành công", data: packages });
    } catch (error: any) {
        res.status(500).json({ message: "Lỗi server" });
    }
};

export const updateRentalPackageHandler = async (req: Request, res: Response) => {
    try {
        const id = Number(req.params.id);
        if (isNaN(id)) return res.status(400).json({ message: "ID gói thuê không hợp lệ" });
        
        const updated = await updateRentalPackageService(id, req.body);
        res.status(200).json({ message: "Cập nhật gói thuê thành công", data: updated });
    } catch (error: any) {
        res.status(400).json({ message: error.message });
    }
};

export const deleteRentalPackageHandler = async (req: Request, res: Response) => {
    try {
        const id = Number(req.params.id);
        if (isNaN(id)) return res.status(400).json({ message: "ID gói thuê không hợp lệ" });
        
        await deleteRentalPackageService(id);
        res.status(200).json({ message: "Xóa gói thuê thành công" });
    } catch (error: any) {
        const status = error.message.includes("Không thể xóa") ? 409 : 404;
        res.status(status).json({ message: error.message });
    }
};

/*--------------------------------------------------------------------------------------------*/
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

    const files = req.files as Express.Multer.File[];

    const updatedVehicle = await updateVehicle(vehicleId, req.body, files);

    return res.status(200).json({
      message: "Cập nhật xe thành công",
      data: updatedVehicle,
    });
  } catch (error: any) {
    console.error("❌ Lỗi cập nhật xe:", error);

    if (error.message.includes("Không tìm thấy xe")) {
      return res.status(404).json({ message: error.message });
    }
    if (error.message.includes("Biển số xe")) {
      return res.status(409).json({ message: error.message });
    }

    return res.status(500).json({ message: error.message || "Lỗi máy chủ" });
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
        const userRole = (req as any).user?.role;
        const data = await getVehicles(page, limit, searchTerm, userRole);
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