import express from "express";
import authRouter from "./routes/auth.ts";
import adminRouter from "./routes/admin.ts";
import vehicleRouter from "./routes/vehicles.ts";
import bookingRouter from "./routes/booking.ts";
import reviewRouter from "./routes/review.ts";
import reportRouter from "./routes/report.ts";

const app = express();
app.use(express.json());

app.use('/api/v1/auth', authRouter)

app.use('/api/v1/admin', adminRouter)

app.use('/api/v1/vehicles', vehicleRouter);

app.use('/api/v1/bookings', bookingRouter);

app.use('/api/v1/reviews', reviewRouter);

app.use('/api/v1/admin/reports', reportRouter);
export default app;