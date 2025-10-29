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


// prisma/seed.ts
// prisma/seed.ts
// prisma/seed.ts
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // --- TẠO LOCATIONS ---
  console.log('Bắt đầu seeding locations...');

  const locationsData = [
    {
      
      name: 'Bãi xe Quận Cầu Giấy',
      address: 'Trần Quý Kiên, Dịch Vọng Hậu, Cầu Giấy, Hà Nội',
      lat: "21.030950",
      lng: "105.798540"
    }
  ];

  // Dùng createMany để thêm dữ liệu
  const result = await prisma.locations.createMany({
    data: locationsData,
    skipDuplicates: true, // Bỏ qua nếu có lỗi (ví dụ: nếu bạn tự thêm @unique)
  });

  console.log(`Đã thêm ${result.count} locations mới.`);
}

// Chạy hàm main
main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    // Đóng kết nối Prisma
    await prisma.$disconnect();
  });