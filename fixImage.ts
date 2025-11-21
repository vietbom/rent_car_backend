import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Địa chỉ IP mới (IP của VM Ubuntu)
const OLD_URL_PART = 'http://localhost:9000';
const NEW_URL_PART = 'http://192.168.210.155:9000'; // Đảm bảo IP này đúng

async function fixUrls() {
  console.log('Bắt đầu tìm kiếm xe cần cập nhật...');

  // 1. Lấy tất cả xe
  const vehicles = await prisma.vehicles.findMany();

  let updatedCount = 0;

  // 2. Lặp qua từng xe
  for (const vehicle of vehicles) {
    let needsUpdate = false;

    // 3. Lặp qua mảng 'images' và tạo mảng URL mới
    const newImages = vehicle.images.map(url => {
      if (url.startsWith(OLD_URL_PART)) {
        needsUpdate = true;
        return url.replace(OLD_URL_PART, NEW_URL_PART);
      }
      return url;
    });

    // 4. Nếu xe này cần cập nhật, thực hiện update
    if (needsUpdate) {
      await prisma.vehicles.update({
        where: { id: vehicle.id },
        data: { images: newImages },
      });
      console.log(`Đã cập nhật URL cho xe ID: ${vehicle.id}`);
      updatedCount++;
    }
  }

  console.log(`Hoàn thành! Đã cập nhật ${updatedCount} xe.`);
}

fixUrls()
  .catch(e => {
    console.error('Lỗi khi cập nhật URL:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });