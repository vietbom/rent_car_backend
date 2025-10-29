import { PrismaClient, Prisma } from "@prisma/client";
import { validateVehicleData } from "../../utils/validate.ts";
import { v4 as uuidv4 } from "uuid";
import minioClient  from "../config/minio.ts";
import redisClient from "../config/redis.ts";

const prisma = new PrismaClient();
const BUCKET_NAME = "rentcar";
const CACHE_TTL_LIST = 600;

export const createVehicle = async (data: any, files?: Express.Multer.File[]) => {
    const validData = validateVehicleData(data, true);

    const locationExists = await prisma.locations.findUnique({
        where: { id: validData.location_id },
    });
    if (!locationExists) throw new Error("Địa điểm không tồn tại");

    const plateExists = await prisma.vehicles.findUnique({
        where: { plate_number: validData.plate_number },
    });
    if (plateExists) throw new Error("Biển số xe đã tồn tại");

    const imageUrls: string[] = [];

    if (files && files.length > 0) {
        
        await Promise.all(
            files.map(async (file) => {
                const fileExtension = file.originalname.split('.').pop();
                const objectName = `${uuidv4()}.${fileExtension}`;
                
                const metaData = {
                    'Content-Type': file.mimetype,
                };

                await minioClient.putObject(
                    BUCKET_NAME,
                    objectName,
                    file.buffer,
                    file.size,
                    metaData
                );

                const url = `http://${process.env.MINIO_ENDPOINT}:${process.env.MINIO_PORT}/${BUCKET_NAME}/${objectName}`;
                imageUrls.push(url);
            })
        );
    }

    const newVehicle = await prisma.vehicles.create({
        data: {
            title: validData.title,
            plate_number: validData.plate_number,
            year: validData.year,
            seats: validData.seats,
            price_per_day: validData.price_per_day,
            images: imageUrls, 
            brand: data.brand || null,
            model: data.model || null,
            status: data.status || "available",
            locations: {
                connect: { id: validData.location_id }, 
            },
        },
    });

    return newVehicle;
};

export const updateVehicle = async (id: number, data: any) => {
  const validData = validateVehicleData(data, false);

  try {
    const { location_id, ...vehicleData } = validData;

    if (location_id) {
      const locationExists = await prisma.locations.findUnique({
        where: { id: location_id },
      });
      if (!locationExists) throw new Error("Địa điểm không tồn tại");
    }

    const updated = await prisma.vehicles.update({
      where: { id },
      data: {
        ...vehicleData,
        ...(location_id && { locations: { connect: { id: location_id } } }),
      },
    });

    return updated;
  } catch (error: any) {
    if (error instanceof Prisma.PrismaClientKnownRequestError) {
      if (error.code === "P2025") {
        throw new Error("Không tìm thấy xe để cập nhật");
      }
    }
    throw error;
  }
};

export const deleteVehicle = async (id: number) => {
    try {
        await prisma.vehicles.delete({
            where: { id },
        });
        return { message: "Xóa xe thành công" };
    } catch (error: any) {
        if (error instanceof Prisma.PrismaClientKnownRequestError) {
            if (error.code === "P2025") {
            throw new Error("Không tìm thấy xe với ID này");
            }
        }
        throw error;
    }
};

export const getVehicles = async (page: number, limit: number, searchTerm?: string) => {
  const skip = (page - 1) * limit;
  const cacheKey = `vehicles:page:${page}:limit:${limit}${searchTerm ? `:search:${searchTerm}` : ""}`;

  if (page === 1 && !searchTerm) {
    try {
      const cachedData = await redisClient.get(cacheKey);
      if (cachedData) {
        console.log("CACHE HIT: Lấy danh sách xe trang 1 từ Redis");
        return JSON.parse(cachedData);
      }
    } catch (err) {
      console.error("Lỗi khi đọc cache Redis:", err);
    }
  }

  console.log(`CACHE MISS (hoặc đang search): Lấy danh sách xe trang ${page} từ PostgreSQL`);

  const whereClause: Prisma.vehiclesWhereInput = {};

  if (searchTerm) {
    whereClause.OR = [
      { title: { contains: searchTerm, mode: "insensitive" } },
      { brand: { contains: searchTerm, mode: "insensitive" } },
      { model: { contains: searchTerm, mode: "insensitive" } },
      { plate_number: { contains: searchTerm, mode: "insensitive" } },
    ];
  }

  const [vehicles, total] = await prisma.$transaction([
    prisma.vehicles.findMany({
      where: whereClause,
      skip,
      take: limit,
      orderBy: { created_at: "desc" },
      include: { locations: true },
    }),
    prisma.vehicles.count({ where: whereClause }),
  ]);

  const totalPages = Math.ceil(total / limit);

  const result = {
    data: vehicles,
    pagination: {
      totalItems: total,
      currentPage: page,
      totalPages,
      limit,
      ...(searchTerm && { searchTerm }),
    },
  };

  if (page === 1 && !searchTerm) {
    try {
      await redisClient.setEx(cacheKey, CACHE_TTL_LIST, JSON.stringify(result));
    } catch (err) {
      console.error("Lỗi khi ghi cache Redis:", err);
    }
  }

  return result;
};

export const getVehicleById = async(id: number) => {
    const cacheKey = `vehicle:${id}`;

    const cachedData = await redisClient.get(cacheKey);
    if (cachedData) {
        console.log("✅ Lấy từ Redis cache");
        return JSON.parse(cachedData);
    }

    const vehicle = await prisma.vehicles.findUnique({
        where: { id },
        include: {
        locations: {
            select: { id: true, name: true, address: true },
        },
        },
    });

    if (!vehicle) throw new Error("Không tìm thấy xe");

    await redisClient.setEx(cacheKey, 60, JSON.stringify(vehicle));

    return vehicle;
}