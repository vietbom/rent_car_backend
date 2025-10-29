import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { validateLoginData, validateRegisterData } from "../../utils/validate.ts";
import { PrismaClient } from "@prisma/client";
import { createToken } from "../../utils/generateTokens.ts";
import crypto from "crypto";
import redisClient from "../config/redis.ts";
import { sendEmail } from "../../utils/sendEmail.ts";

const prisma = new PrismaClient();

export const registerUser = async(data: any) => {
    const {email, password, name, phone} = validateRegisterData(data);

    const existingUser = await prisma.users.findUnique({where: {email}});
    if (existingUser) throw new Error("Email đã được sử dụng");

    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(password, salt);

    const newUser = await prisma.users.create({
        data: {email, password_hash, name, phone, role: "customer", is_verified: false},
    });

    const tokens = createToken({ id: newUser.id, role: newUser.role });

    const token_hash = await bcrypt.hashSync(tokens.refreshToken, 10);
    await prisma.refresh_tokens.create({
        data: {
            user_id: newUser.id,
            token_hash ,
            expires_at: new Date(Date.now() + 7*24*60*60*1000),
        },
    });

    return {
        id: newUser.id,
        email: newUser.email,
        name: newUser.name,
        phone: newUser.phone,
        role: newUser.role,
        is_verified: newUser.is_verified,
        created_at: newUser.created_at,
        updated_at: newUser.updated_at,
        tokens,
    };
}

export const loginUser = async(data: any) => {
    const {email, password} = validateLoginData(data); 

    const user = await prisma.users.findUnique({where: {email}});
    if(!user) throw new Error("Email hoặc mật khẩu không chính xác");

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if(!isMatch) throw new Error("Email hoặc mật khẩu không chính xác");

    if (!user.role) {
        throw new Error("Tài khoản không có quyền hạn (role) hợp lệ.");
    }
    
    const accessTokens = createToken({ id: user.id, role: user.role });

    return {
        id: user.id,
        email: user.email,
        name: user.name,
        phone: user.phone,
        role: user.role,
        is_verified: user.is_verified,
        created_at: user.created_at,
        updated_at: user.updated_at,
        accessTokens,
    };
}

export const refreshUserToken = async (receivedToken: string) => {
  if (!receivedToken) throw new Error("Không tìm thấy refresh token");

  const refreshTokenSecret = process.env.JWT_REFRESH_SECRET;
  if (!refreshTokenSecret) throw new Error("Lỗi cấu hình server");

  try {
    const decoded = jwt.verify(receivedToken, refreshTokenSecret) as { id: string; role: string };
    const userId = decoded.id;

    const tokens = await prisma.refresh_tokens.findMany({
      where: { user_id: userId, revoked: false },
    });

    if (tokens.length === 0) throw new Error("Không tìm thấy refresh token hợp lệ");

    let matchedToken = null;
    for (const tokenRecord of tokens) {
      const match = await bcrypt.compare(receivedToken, tokenRecord.token_hash);
      if (match) {
        matchedToken = tokenRecord;
        break;
      }
    }

    if (!matchedToken) throw new Error("Refresh token không hợp lệ hoặc đã bị thu hồi");

    if (matchedToken.expires_at && matchedToken.expires_at < new Date()) {
      await prisma.refresh_tokens.update({
        where: { id: matchedToken.id },
        data: { revoked: true },
      });
      throw new Error("Refresh token đã hết hạn");
    }

    const { accessToken, refreshToken: newRefreshToken } = createToken({ id: userId, role: decoded.role });

    await prisma.refresh_tokens.create({
      data: {
        user_id: userId,
        token_hash: bcrypt.hashSync(newRefreshToken, 10),
        expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      },
    });

    return { accessToken, refreshToken: newRefreshToken };
  } catch (error: any) {
    console.error("Refresh token error:", error.message);
    throw new Error("Refresh token không hợp lệ hoặc đã hết hạn");
  }
};

export const logoutUser = async (userId: string, receivedToken?: string) => {
  try {
    if (receivedToken) {
      const tokens = await prisma.refresh_tokens.findMany({
        where: { user_id: userId, revoked: false },
      });

      for (const tokenRecord of tokens) {
        const match = await bcrypt.compare(receivedToken, tokenRecord.token_hash);
        if (match) {
          await prisma.refresh_tokens.update({
            where: { id: tokenRecord.id },
            data: { revoked: true },
          });
          return { message: "Đăng xuất khỏi thiết bị hiện tại thành công" };
        }
      }

      throw new Error("Token không hợp lệ hoặc đã bị thu hồi");
    } else {
      await prisma.refresh_tokens.updateMany({
        where: { user_id: userId },
        data: { revoked: true },
      });
      return { message: "Đăng xuất khỏi tất cả thiết bị thành công" };
    }
  } catch (error: any) {
    throw new Error(error.message);
  }
};

export const handleForgotPassword = async(email: string) => {
    const user = await prisma.users.findUnique({where: {email}});
    if (!user) throw new Error("Email không tồn tại trong hệ thống");

    const exists = await redisClient.exists(`otp:${email}`);
    if (exists) {
      throw new Error("Vui lòng đợi 1 phút trước khi yêu cầu lại OTP");
    }
    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    const hashedOtp = crypto.createHash("sha256").update(otp).digest("hex");

    await redisClient.setEx(`otp:${email}`, 300, hashedOtp);
    await redisClient.setEx(`otp_cooldown:${email}`, 60, "true");
    
    const subject = "Yêu cầu đặt lại mật khẩu";
    const text = `Mã OTP đặt lại mật khẩu của bạn là: ${otp}. Mã sẽ hết hạn sau 5 phút.`;

    await sendEmail(email, subject, text);
}

export const handleResetPassword = async (email: string, otp: string, newPassword: string) => {
    const storedHash = await redisClient.get(`otp:${email}`);
    if (!storedHash) throw new Error("OTP đã hết hạn hoặc không tồn tại");

    const hashedInput = crypto.createHash("sha256").update(otp).digest("hex");
    if (hashedInput !== storedHash) throw new Error("Mã OTP không chính xác hoặc đã hết hạn");

    const user = await prisma.users.findUnique({ where: { email } });
    if (!user) throw new Error("Người dùng không tồn tại");

    const hashedPassword = await bcrypt.hash(newPassword, 12);

    await prisma.users.update({
        where: { email },
        data: { password_hash: hashedPassword },
    });

    await redisClient.del(`otp:${email}`);
};

export const createLocationService = async (data: {name: string;address?: string;lat?: number;lng?: number;}) => {
  const existing = await prisma.locations.findFirst({
    where: { name: data.name },
  });

  if (existing) {
    throw new Error("Địa điểm này đã tồn tại trong hệ thống");
  }

  const location = await prisma.locations.create({
    data: {
      name: data.name,
      address: data.address ?? null,
      lat: data.lat ?? null,
      lng: data.lng ?? null,
    },
  });

  return location;
};

export const getLocationsService = async () => {
  const locations = await prisma.locations.findMany({
    orderBy: { id: "asc" },
    select: {
      id: true,
      name: true,
      address: true,
      lat: true,
      lng: true,
    },
  });

  return locations;
};