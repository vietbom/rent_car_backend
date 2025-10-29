import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

async function connectDB() {
  try {
    await prisma.$connect();
    console.log('✅ Connected to PostgreSQL via Prisma');
  } catch (err) {
    console.error('❌ PostgreSQL connection error:', err);
  }
}

connectDB();

export default prisma;
