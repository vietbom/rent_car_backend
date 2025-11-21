
import dotenv from "dotenv";
import minioClient from "./minio.ts";
dotenv.config();


export const getPresignedUrl = async (fileName: string) => {
  return await minioClient.presignedGetObject(
    process.env.MINIO_BUCKET_NAME!,
    fileName,
    60 * 60 // 1 hour
  );
};
