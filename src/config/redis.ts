import Redis from 'ioredis';
import dotenv from 'dotenv';

dotenv.config();

// Khởi tạo client ioredis
// ioredis tự động quản lý kết nối, tự reconnect khi mất mạng
const redisClient = new Redis({
  host: process.env.REDIS_HOST || 'localhost', // Ubuntu 1 gọi chính nó
  port: Number(process.env.REDIS_PORT) || 6379,
  password: process.env.REDIS_PASSWORD || undefined,
  
  // Cấu hình quan trọng giúp không bị treo khi mất kết nối
  retryStrategy: (times) => {
    const delay = Math.min(times * 50, 2000);
    return delay;
  },
  
  // Tắt lazy connect để biết lỗi ngay khi khởi động
  lazyConnect: true 
});

redisClient.on('connect', () => {
  console.log('✅ Connected to Redis (ioredis)');
});

redisClient.on('error', (err) => {
  console.error('❌ Redis connection error:', err);
});

// Hàm connect thủ công (để gọi ở index.ts cho đồng bộ)
export const connectRedis = async () => {
  try {
    // Với ioredis, lệnh này sẽ đợi cho đến khi kết nối thành công
    await redisClient.connect(); 
  } catch (error) {
    console.error('❌ Failed to connect to Redis:', error);
  }
};

export default redisClient;