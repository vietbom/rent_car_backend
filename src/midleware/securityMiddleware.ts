import type { Request, Response, NextFunction } from 'express';
import { ADMIN_IP_BLOCK_PREFIX } from '../config/constants.ts';
import redisClient from '../config/redis.ts';

const getIP = (req: Request): string => {
    return req.headers['x-forwarded-for'] as string || req.socket.remoteAddress || 'unknown_ip';
}

export const checkIPBloclk = async (req: Request, res: Response, next: NextFunction) => {
    const ipAddress = getIP(req);
    (req as any).ipAddress = ipAddress;

    const blockKey = `${ADMIN_IP_BLOCK_PREFIX}${ipAddress}`;
    const isBlocked = await redisClient.get(blockKey)

    if(isBlocked) {
        return res.status(403).json({
            status: "error",
            message: "Truy cập bị từ chối. IP của bạn đã bị khóa do đăng nhập thất bại nhiều lần. Vui lòng thử lại sau 15 phuts."
        })
    }

    next();
}