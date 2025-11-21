import app from './app.ts';
import dotenv from 'dotenv';
import prisma from './config/db.ts';
import { connectRedis } from './config/redis.ts';
import { initMinio } from './config/minio.ts';
import { startBookingCronJob } from './cron/bookingCron.ts';
import { createServer } from 'http';
import { Server } from 'socket.io';

dotenv.config();
const PORT = parseInt(process.env.PORT || '3000', 10);

startBookingCronJob();

const httpServer = createServer(app);
export const io = new Server(httpServer, {
  cors: {
    origin: "*", // Hoặc điền domain web admin của bạn để bảo mật hơn
    methods: ["GET", "POST"]
  }
});

io.on("connection", (socket) => {
  console.log(`⚡ Client connected: ${socket.id}`);
  
  socket.on("disconnect", () => {
    console.log(`Client disconnected: ${socket.id}`);
  });
});

const startServer = async () => {
  try {
    // 1. Kết nối DB, Redis, MinIO
    await prisma.$connect();
    console.log('✅ Connected to PostgreSQL via Prisma');
    
    await connectRedis();
    await initMinio();
    
    // 2. Khởi động máy chủ Express
    httpServer.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 Server running with Socket.io on http://0.0.0.0:${PORT}`);
    });
    
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
};

startServer();