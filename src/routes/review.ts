import { Router } from "express";
import { verifyAccessToken } from "../midleware/authMiddleware.ts";
import { createReviewHandler } from "../controllers/reviewController.ts";
import { createReviewSchema } from "../../utils/validate.ts";
import { validate } from "../midleware/validateMiddleware.ts";


const reviewRouter = Router();

reviewRouter.use(verifyAccessToken);

// POST /reviews - Customer tạo đánh giá
reviewRouter.post("/", validate(createReviewSchema), createReviewHandler);

export default reviewRouter;
