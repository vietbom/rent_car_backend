import { createClient } from "redis";
import dotenv from 'dotenv';

dotenv.config();

const redisClient = createClient({
    socket: {
        host: process.env.REDIS_HOST,
        port: Number(process.env.REDIS_PORT),
    },
})

redisClient.on('connect', ()=> {
    console.log('✅ Connected to Redis');
})

redisClient.on('error', (err) => {
  console.error('❌ Redis connection error:', err);
});

export const connectRedis = async() => {
    try {
        await redisClient.connect();
    } catch (error) {
        console.error('❌ Redis connection failed:', error);
    }
}

export default redisClient;