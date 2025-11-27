// src/utils/prometheus.ts
import { Registry, Counter, Histogram, collectDefaultMetrics } from 'prom-client';

// 1. Tạo registry riêng cho project
export const register = new Registry();

// 2. Thu thập metrics mặc định của Node.js (CPU, RAM, GC, Event Loop...)
collectDefaultMetrics({ register });

// 3. Metrics tùy chỉnh cho hệ thống thuê xe
export const httpRequestTotal = new Counter({
  name: 'http_requests_total',
  help: 'Tổng số request theo method, route, status code',
  labelNames: ['method', 'route', 'status'],
  registers: [register],
});

export const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'Thời gian xử lý request (seconds)',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.1, 0.3, 0.5, 1, 2, 5, 10], 
  registers: [register],
});

export const bookingCreatedTotal = new Counter({
  name: 'booking_created_total',
  help: 'Tổng số đơn thuê xe được tạo',
  labelNames: ['status', 'payment_method'],
  registers: [register],
});

export const paymentStatusTotal = new Counter({
  name: 'payment_status_total',
  help: 'Trạng thái thanh toán',
  labelNames: ['status', 'method'],
  registers: [register],
});