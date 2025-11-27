// src/middleware/prometheusMiddleware.ts
import type { Request, Response, NextFunction } from 'express';
import { httpRequestDuration, httpRequestTotal } from '../../utils/prometheus.ts';

export const prometheusMiddleware = (req: Request, res: Response, next: NextFunction) => {
  const start = Date.now();

  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route?.path || req.path || 'unknown';

    httpRequestTotal.inc({
      method: req.method,
      route,
      status: res.statusCode.toString(),
    });

    httpRequestDuration
      .labels(req.method, route, res.statusCode.toString())
      .observe(duration);
  });

  next();
};