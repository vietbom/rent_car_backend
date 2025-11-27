import type { NextFunction, Request, Response } from "express";
import { createLocationService, getLocationsService, getProfileService, handleForgotPassword, handleResetPassword, loginUser, logoutUser, refreshUserToken, registerUser } from "../services/authServices.ts";
import { validateAccount, validateEmail } from "../../utils/validate.ts";

export const registerHandler = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = await registerUser(req.body);
    res.status(201).json({
      status: "success",
      data: { user },
    });
  } catch (error: any) {
    res.status(400).json({
      status: "error",
      message: error.message,
    });
  }
};

export const loginHandler = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const ipAddress = (req as any).ipAddress;
    const user = await loginUser(req.body, ipAddress);

    res.status(200).json({
      status: "success",
      data: { user },
    });
  } catch (error: any) {
    res.status(400).json({
      status: "error",
      message: error.message,
    });
  }
};

export const logoutHandler = async(req: Request, res: Response) => {
  try {
    const userId = (req as any).user?.id;
    
    if (!userId) {
      return res.status(401).json({ message: "Không được phép" });
    }

    const { refreshToken } = req.body;

    if (!refreshToken) {
      await logoutUser(userId); 
      return res.status(200).json({ message: "Đã đăng xuất khỏi tất cả thiết bị" });
    }

    await logoutUser(userId, refreshToken);

    return res.status(200).json({ message: "Đã đăng xuất thành công" });
  } catch (error: any) {
    return res.status(500).json({ message: error.message });
  }
}

export const refreshHandler = async (req: Request, res: Response) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({ message: "Refresh token là bắt buộc" });
    }

    const newTokens = await refreshUserToken(refreshToken);

    return res.status(200).json({
      message: "Token đã được làm mới",
      data: newTokens, 
    });

  } catch (error) {
    if (error instanceof Error) {
      return res.status(401).json({ message: error.message });
    }
    return res.status(500).json({ message: "Lỗi máy chủ không xác định" });
  }
};

export const forgotPassword = async(req: Request, res: Response) => {
  try {
    const {email} = validateEmail(req.body);

    await handleForgotPassword(email);

    res.status(200).json({ message: "Đã gửi OTP đến email của bạn" });
  } catch (error: any) {
    res.status(500).json({ message: error.message || "Lỗi server" });
  }
}

export const resetPassword = async (req: Request, res: Response) => {
  try {
    const { email, otp, newPassword } = validateAccount(req.body);

    await handleResetPassword(email, otp, newPassword);
    res.status(200).json({ message: "Đặt lại mật khẩu thành công" });
  } catch (error: any) {
    res.status(400).json({ message: error.message || "Lỗi server" });
  }
};

export const createLocationHandler = async (req: Request, res: Response) => {
  try {
    const { name, address, lat, lng } = req.body;

    const location = await createLocationService({ name, address, lat, lng });

    return res.status(201).json({
      message: "Thêm địa điểm thành công",
      data: location,
    });
  } catch (error: any) {
    console.error("Lỗi khi thêm địa điểm:", error);
    return res.status(400).json({
      message: error.message || "Lỗi khi thêm địa điểm",
    });
  }
};

export const getLocationsHandler = async (req: Request, res: Response) => {
  try {
    const locations = await getLocationsService();

    return res.status(200).json({
      message: "Lấy danh sách địa điểm thành công",
      data: locations,
    });
  } catch (error: any) {
    console.error("Lỗi khi lấy danh sách địa điểm:", error);
    return res.status(500).json({
      message: "Lỗi khi lấy danh sách địa điểm",
      error: error.message,
    });
  }
};

export const getProfileHandler = async (req: Request, res: Response) => {
  try {
    // middleware verifyAccessToken đã gán user vào req
    const userId = (req as any).user?.id;

    if (!userId) {
      return res.status(401).json({ message: "Không tìm thấy thông tin người dùng trong token" });
    }

    const user = await getProfileService(userId);

    if (!user) {
      return res.status(404).json({ message: "Không tìm thấy người dùng" });
    }

    return res.status(200).json({
      message: "Lấy thông tin cá nhân thành công",
      data: user,
    });
  } catch (error: any) {
    console.error("Lỗi khi lấy thông tin cá nhân:", error);
    return res.status(500).json({
      message: "Lỗi máy chủ khi lấy thông tin cá nhân",
      error: error.message,
    });
  }
};