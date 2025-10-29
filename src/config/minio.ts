import { Client } from 'minio';
import dotenv from 'dotenv';

dotenv.config();

const minioClient = new Client({
  endPoint: process.env.MINIO_ENDPOINT || 'localhost',
  port: Number(process.env.MINIO_PORT) || 9000,
  useSSL: false,
  accessKey: process.env.MINIO_ACCESS_KEY || '',
  secretKey: process.env.MINIO_SECRET_KEY || '',
});

export const initMinio = async () => {
  const bucketName = process.env.MINIO_BUCKET_NAME || 'rentcar';
  try {
    const exists = await minioClient.bucketExists(bucketName);
    if (!exists) {
      await minioClient.makeBucket(bucketName, 'us-east-1');
      console.log(`🪣 Created new bucket: ${bucketName}`);
    } else {
      console.log(`✅ MinIO bucket "${bucketName}" is ready`);
    }
  } catch (err) {
    console.error('❌ MinIO connection error:', err);
  }
};

export default minioClient;
