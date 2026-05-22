module.exports = {
  apps: [
    {
      name: 'rentcar-api',
      script: 'src/index.ts', // 1. File khởi chạy chính (TypeScript)
      exec_mode: 'cluster',    // 2. Chế độ phân tán (Bắt buộc để fix single-thread bottleneck)
      instances: 'max',        // 3. Tận dụng tối đa số nhân CPU có sẵn
      
      node_args: ["-r", "dotenv/config"],
      // Cấu hình TypeScript (ts-node)
      interpreter: './node_modules/.bin/ts-node',
      interpreter_args: '--esm', // Cờ cần thiết cho dự án ES Modules (import/export)
      
      // Cấu hình Môi trường
      env_file: '.env',          // Load biến môi trường từ file .env (rất quan trọng)
      env: {
        NODE_ENV: 'production',
      },
      
      // Resilience và Monitoring
      watch: false,                 // Tắt watch trong môi trường Production/Load Test
      time: true,                   // Thêm timestamp vào log
      max_memory_restart: '500M',   // Tự khởi động lại nếu bộ nhớ vượt 500MB (phòng rò rỉ bộ nhớ)
      max_restarts: 10,             // Giới hạn số lần khởi động lại tự động
      min_uptime: '60s',            // Yêu cầu tiến trình phải chạy tối thiểu 60s
    },
  ],
};