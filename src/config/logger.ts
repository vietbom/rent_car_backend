import winston from 'winston';

const { combine, timestamp, printf, colorize, align } = winston.format;

// Định dạng log tùy chỉnh: [TIMESTAMP] [LEVEL]: MESSAGE
const logFormat = printf(({ level, message, timestamp }) => {
  return `[${timestamp}] ${level}: ${message}`;
});

const logger = winston.createLogger({
  level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
  format: combine(
    timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    // align(),
    logFormat
  ),
  transports: [
    // 1. Hiển thị ra màn hình (Console) có màu sắc
    new winston.transports.Console({
      format: combine(
        colorize(), // Tô màu: Info xanh, Error đỏ, Warn vàng
        logFormat
      ),
    }),
    
    // 2. Lưu lỗi vào file riêng (Để tra cứu sau này nếu trôi log)
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    
    // 3. Lưu tất cả hoạt động vào file chung
    new winston.transports.File({ filename: 'logs/combined.log' }),
  ],
});

export default logger;