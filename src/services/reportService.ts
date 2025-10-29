import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

export const getEarningsReport = async (startDate: string, endDate: string) => {
  const start = new Date(startDate);
  const end = new Date(endDate);

  const invoiceStats = await prisma.invoices.aggregate({
    _sum: { total_amount: true, amount: true },
    _count: { id: true },
    where: {
      issued_at: { gte: start, lte: end },
    },
  });

  const paymentStats = await prisma.payments.aggregate({
    _sum: { amount: true },
    _count: { id: true },
    where: {
      paid_at: { gte: start, lte: end },
      status: "success",
    },
  });

  const invoiceTotal =
    Number(invoiceStats._sum.total_amount ?? 0) +
    Number(invoiceStats._sum.amount ?? 0);
  const paymentTotal = Number(paymentStats._sum.amount ?? 0);

  return {
    startDate,
    endDate,
    invoices: {
      totalInvoices: invoiceStats._count.id || 0,
      totalAmount: invoiceTotal,
    },
    payments: {
      totalPayments: paymentStats._count.id || 0,
      totalPaidAmount: paymentTotal,
    },
    summary: {
      totalEarnings: invoiceTotal + paymentTotal,
    },
  };
};

export const getRentedVehiclesReport = async () => {
  const rentedBookings = await prisma.bookings.findMany({
    where: { 
      status: "picked_up" 
    }, 
    select: {
      id: true,
      start_datetime: true,
      end_datetime: true,
      total_price: true,
      surcharge_amount: true,
      created_at: true,
      status: true,
      vehicles: { 
        select: {
          id: true,
          title: true,
          plate_number: true,
        },
      },
      users: { 
        select: {
          id: true,
          name: true,
          phone: true,
        },
      },
    },
    orderBy: { start_datetime: "desc" },
  });

  const formatted = rentedBookings.map((b) => ({
    bookingId: b.id,
    vehicleName: b.vehicles?.title ?? "N/A",
    licensePlate: b.vehicles?.plate_number ?? "N/A",
    renter: b.users?.name ?? "Chưa có",
    phone: b.users?.phone ?? "",
    start: b.start_datetime,
    end: b.end_datetime,
    basePrice: (b.total_price as any)?.toNumber?.() ?? Number(b.total_price ?? 0),
    surcharge: (b.surcharge_amount as any)?.toNumber?.() ?? Number(b.surcharge_amount ?? 0),
    status: b.status,
    createdAt: b.created_at,
  }));

  return {
    message: "Danh sách xe đang được thuê",
    total: formatted.length,
    data: formatted,
  };
};


export const getDashboardStats = async () => {
  const [userCount, vehicleCount, bookingCount, totalRevenue, activeRentals] = await Promise.all([
    prisma.users.count(),
    prisma.vehicles.count(),
    prisma.bookings.count(),
    prisma.invoices.aggregate({
      _sum: { total_amount: true },
    }),
    prisma.bookings.count({
      where: { status: "picked_up" }, 
    }),
  ]);

  return {
    users: userCount,
    vehicles: vehicleCount,
    bookings: bookingCount,
    activeRentals,
    totalRevenue: totalRevenue._sum.total_amount
      ? Number(totalRevenue._sum.total_amount)
      : 0,
  };
};