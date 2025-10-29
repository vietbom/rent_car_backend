import type { NextFunction, Request, Response } from "express";
import type { ZodSchema } from "zod";

export const validate = (schema: ZodSchema<any>) => 
  (req: Request, res: Response, next: NextFunction) => {
    try {
      schema.parse(req.body);
      next();
    } catch (error: any) {
      if (error.errors) {
        return res.status(400).json({
          message: "Dữ liệu không hợp lệ",
          errors: error.errors.map((e: any) => e.message),
        });
      }
      return res.status(400).json({ message: error.message });
    }
};
