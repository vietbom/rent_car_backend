import app from './app.ts';
import dotenv from 'dotenv';
import prisma from './config/db.ts';
import { connectRedis } from './config/redis.ts';
import { initMinio } from './config/minio.ts';


dotenv.config();
const PORT = process.env.PORT || 3000;

const startServer = async () => {
  try {
    // 1. Kết nối DB, Redis, MinIO
    await prisma.$connect();
    console.log('✅ Connected to PostgreSQL via Prisma');
    
    await connectRedis();
    await initMinio();
    
    // 2. Khởi động máy chủ Express
    app.listen(PORT, () => {
      console.log(`🚀 Server running on port ${PORT}`);
    });
    
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
};

startServer();