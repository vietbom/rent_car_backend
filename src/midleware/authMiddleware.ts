import { PrismaClient } from "@prisma/client";
import type { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

const prisma = new PrismaClient();

interface AuthRequest extends Request {
  user?: {
    id: string;
    role: string;
  };
}

export const verifyAccessToken = (req: AuthRequest, res: Response, next: NextFunction) => {
  const authHeader = req.headers['authorization'];
  
  if (!authHeader) {
    return res.status(401).json({ message: "Yêu cầu cần xác thực (Không có token)" });
  }

  const token = authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ message: "Định dạng token không hợp lệ" });
  }

  const accessTokenSecret = process.env.JWT_ACCESS_SECRET;
  if (!accessTokenSecret) {
    console.error("Lỗi server: JWT_ACCESS_SECRET chưa được thiết lập!");
    return res.status(500).json({ message: "Lỗi cấu hình server" });
  }

  try {
    const decoded = jwt.verify(token, accessTokenSecret) as { id: string,  role: string;};
    
    req.user = { id: decoded.id, role: decoded.role };
    
    next();

  } catch (error) {
    if (error.name === 'TokenExpiredError') {

      return res.status(401).json({ message: "Token đã hết hạn" });
    }
    return res.status(403).json({ message: "Token không hợp lệ" });
  }
};

export const verifyAdmin = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const userRole = req.user?.role;

    if (!userRole) {
      return res
        .status(401)
        .json({ message: "Không được phép (thiếu thông tin role)" });
    }

    if (userRole !== "admin") {
      return res.status(403).json({ message: "Không có quyền Admin" });
    }

    next();
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
};

