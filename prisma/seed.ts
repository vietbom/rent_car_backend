// import { PrismaClient } from '@prisma/client';
// import bcrypt from 'bcrypt';

// const prisma = new PrismaClient();

// async function main() {
//   console.log('Bắt đầu seeding (tạo admin)...');

//   const adminEmail = process.env.ADMIN_EMAIL ;
//   const adminPassword = process.env.ADMIN_PASSWORD;

//   const salt = await bcrypt.genSalt(10);
//   const hashedPassword = await bcrypt.hash(adminPassword, salt);

//   const adminUser = await prisma.users.upsert({
//     where: { email: adminEmail },
//     update: {}, 
//     create: {
//       email: adminEmail,
//       password_hash: hashedPassword,
//       name: 'Super Admin',
//       phone: '000000001',
//       role: 'admin',       
//       is_verified: true,
//     },
//   });

//   console.log(`Đã tạo hoặc cập nhật admin: ${adminUser.email}`);
// }

// main()
//   .catch((e) => {
//     console.error(e);
//     process.exit(1);
//   })
//   .finally(async () => {
//     await prisma.$disconnect();
//   });

