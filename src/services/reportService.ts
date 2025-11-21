import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

/**
 * Báo cáo doanh thu (Earnings Report)
 * Tách biệt giữa "Doanh thu trên giấy tờ" (Invoices) và "Tiền thực về túi" (Payments)
 */
export const getEarningsReport = async (startDate: string, endDate: string) => {
  const start = new Date(startDate);
  const end = new Date(endDate);
  if (endDate.length <= 10) {
      end.setHours(23, 59, 59, 999);
  }

  // 1. Số lượt Booking mới trong khoảng thời gian này
  const totalBookings = await prisma.bookings.count({
    where: {
      created_at: { gte: start, lte: end },
    },
  });

  // 2. Số tài khoản đăng ký mới
  const newUsers = await prisma.users.count({
    where: {
      created_at: { gte: start, lte: end },
      role: 'customer', // Chỉ đếm khách hàng
    },
  });

  // 3. Doanh thu (Dựa trên Hóa đơn đã xuất)
  const revenueStats = await prisma.invoices.aggregate({
    _sum: { total_amount: true },
    where: {
      issued_at: { gte: start, lte: end },
    },
  });

  const totalRevenue = Number(revenueStats._sum.total_amount ?? 0);

  return {
    startDate,
    endDate,
    totalBookings,
    newUsers,
    totalRevenue,
  };
};

/**
 * Lấy danh sách xe ĐANG ĐƯỢC THUÊ (Live Status)
 */
export const getRentedVehiclesReport = async () => {
  const now = new Date();

  const rentedBookings = await prisma.bookings.findMany({
    where: { 
      status: "rented" // Enum chuẩn: 'rented' (không phải picked_up)
    }, 
    select: {
      id: true,
      start_datetime: true,
      end_datetime: true, // Đã bao gồm gia hạn
      original_end_datetime: true,
      total_price: true,
      created_at: true,
      status: true,
      vehicles: { 
        select: {
          id: true,
          title: true,
          plate_number: true,
          vehicle_type: { select: { name: true } }
        },
      },
      users: { 
        select: {
          id: true,
          name: true,
          phone: true,
          email: true
        },
      },
    },
    orderBy: { end_datetime: "asc" }, 
  });

  const formatted = rentedBookings.map((b) => {
    const totalPrice = Number(b.total_price ?? 0);
    const isOverdue = new Date(b.end_datetime) < now; 

    return {
      bookingId: b.id,
      vehicle: {
          title: b.vehicles?.title ?? "N/A",
          plate: b.vehicles?.plate_number ?? "N/A",
          type: b.vehicles?.vehicle_type?.name ?? ""
      },
      customer: {
          name: b.users?.name ?? "Khách lẻ",
          phone: b.users?.phone ?? "",
          email: b.users?.email
      },
      schedule: {
          start: b.start_datetime,
          end: b.end_datetime,
          isExtended: !!b.original_end_datetime, 
          isOverdue: isOverdue, 
      },
      financial: {
          estimatedTotal: totalPrice
      }
    };
  });

  return {
    message: "Danh sách xe đang hoạt động",
    count: formatted.length,
    data: formatted,
  };
};

/**
 * Thống kê nhanh Dashboard (Stats)
 */
export const getDashboardStats = async () => {
  const [userCount, vehicleCount, bookingStats, revenueStats] = await Promise.all([
    prisma.users.count(),
    prisma.vehicles.count(),
    prisma.bookings.groupBy({
        by: ['status'],
        _count: { id: true }
    }),
    prisma.invoices.aggregate({
      _sum: { total_amount: true },
    }),
  ]);

  let pending = 0, confirmed = 0, rented = 0, completed = 0, cancelled = 0;
  bookingStats.forEach(stat => {
      if (stat.status === 'pending') pending = stat._count.id;
      if (stat.status === 'confirmed') confirmed = stat._count.id;
      if (stat.status === 'rented') rented = stat._count.id;
      if (stat.status === 'completed') completed = stat._count.id;
      if (stat.status === 'cancelled') cancelled = stat._count.id;
  });

  return {
    overview: {
        totalUsers: userCount,
        totalVehicles: vehicleCount,
        totalRevenue: Number(revenueStats._sum.total_amount ?? 0)
    },
    bookings: {
        total: pending + confirmed + rented + completed + cancelled,
        pending,   
        confirmed, 
        rented,   
        completed, 
        cancelled
    }
  };
};