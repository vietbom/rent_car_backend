import express from "express";
import cors from "cors";
import authRouter from "./routes/auth.ts";
import adminRouter from "./routes/admin.ts";
import vehicleRouter from "./routes/vehicles.ts";
import bookingRouter from "./routes/booking.ts";
import reviewRouter from "./routes/review.ts";
import reportRouter from "./routes/report.ts";
import { getPresignedUrl } from "./config/presigned.ts";
import paymentRouter from "./routes/payments.ts";
import logger from "./config/logger.ts";
import morgan from "morgan";
import { prometheusMiddleware } from "./midleware/prometheusMiddleware.ts";
import { register } from "../utils/prometheus.ts";

const app = express();
app.use(express.json());
app.use(cors());

app.use(prometheusMiddleware);

app.get("/metrics", async (req, res) => {
  try {
    res.setHeader("Content-Type", register.contentType);
    res.send(await register.metrics());
  } catch (error) {
    res.status(500).send("Metrics error");
  }
});

app.use(
  morgan("combined", {
    stream: {
      write: (message) => logger.info(message.trim()),
    },
    skip: (req) => req.url === "/metrics" || req.url === "/health"
  })
);

app.use('/api/v1/auth', authRouter)

app.use('/api/v1/admin', adminRouter)

app.use('/api/v1/vehicles', vehicleRouter);

app.use('/api/v1/bookings', bookingRouter);

app.use("/api/v1/payments", paymentRouter);

app.use('/api/v1/reviews', reviewRouter);

app.use('/api/v1/admin/reports', reportRouter);

app.get("/vehicle/image/:filename", async (req, res) => {
  const filename = req.params.filename;

  try {
    const url = await getPresignedUrl(filename);
    res.json({ url });
  } catch (error) {
    res.status(500).json({ error: "Cannot generate link" });
  }
});

export default app;