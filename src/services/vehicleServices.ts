import { PrismaClient, Prisma } from "@prisma/client";
import { validateVehicleData } from "../../utils/validate.ts";
import { v4 as uuidv4 } from "uuid";
import minioClient  from "../config/minio.ts";
import redisClient from "../config/redis.ts";
import { getPresignedUrl } from "../config/presigned.ts";

const prisma = new PrismaClient();
const BUCKET_NAME = "rentcar";
const CACHE_TTL_LIST = 600;


const invalidateVehicleCaches = async (vehicleId?: number) => {
  try {
    // 1. Xóa cache danh sách (trang 1)
    await redisClient.del("vehicles:page:1");
    
    // 2. Nếu có ID, xóa cache chi tiết
    if (vehicleId) {
      await redisClient.del(`vehicle:${vehicleId}`);
    }
    console.log("🧹 CACHE INVALIDATED: Đã xóa cache xe");
  } catch (err) {
    console.error("❌ Lỗi khi xóa cache xe:", err);
  }
};

export const createVehicleTypeService = async (data: { name: string; seats: number; deposit_amount: number }) => {
    const existingType = await prisma.vehicle_types.findUnique({
        where: { name: data.name },
    });
    if (existingType) throw new Error("Tên loại xe đã tồn tại.");
    
    return await prisma.vehicle_types.create({ data });
};

export const getVehicleTypesService = async () => {
    return await prisma.vehicle_types.findMany({
        orderBy: { name: 'asc' },
        include: { _count: { select: { rental_packages: true, vehicles: true } } }
    });
};

export const updateVehicleTypeService = async (id: number, data: any) => {
    if (data.name) {
        const existing = await prisma.vehicle_types.findFirst({
            where: { name: data.name, id: { not: id } },
        });
        if (existing) throw new Error("Tên loại xe này đã được sử dụng.");
    }

    return await prisma.vehicle_types.update({
        where: { id },
        data: data,
    });
};

export const deleteVehicleTypeService = async (id: number) => {
    try {
        return await prisma.vehicle_types.delete({ where: { id } });
    } catch (error) {
        if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2003') {
            throw new Error("Không thể xóa: Vẫn còn xe hoặc gói thuê liên kết với loại xe này.");
        }
        throw new Error("Không tìm thấy loại xe để xóa.");
    }
};

export const createRentalPackageService = async (data: { vehicle_type_id: number; duration_hours: number; price: number }) => {
    const typeExists = await prisma.vehicle_types.findUnique({ where: { id: data.vehicle_type_id } });
    if (!typeExists) throw new Error("ID loại xe không tồn tại.");

    const packageExists = await prisma.rental_packages.findFirst({
        where: {
            vehicle_type_id: data.vehicle_type_id,
            duration_hours: data.duration_hours,
        },
    });
    if (packageExists) throw new Error(`Gói ${data.duration_hours} giờ đã tồn tại cho loại xe này.`);

    return await prisma.rental_packages.create({ data });
};

export const getRentalPackagesService = async (typeId: number) => {
    return await prisma.rental_packages.findMany({
        where: { vehicle_type_id: typeId },
        orderBy: { duration_hours: 'asc' },
        include: { vehicle_type: true } 
    });
};

export const updateRentalPackageService = async (id: number, data: any) => {
    if (data.duration_hours) {
        const existing = await prisma.rental_packages.findFirst({
            where: {
                duration_hours: data.duration_hours,
                vehicle_type_id: data.vehicle_type_id, 
                id: { not: id }
            },
        });
        if (existing) throw new Error("Thời lượng mới đã xung đột với gói khác của loại xe này.");
    }

    return await prisma.rental_packages.update({
        where: { id },
        data: data,
    });
};

export const deleteRentalPackageService = async (id: number) => {
    try {
        return await prisma.rental_packages.delete({ where: { id } });
    } catch (error) {
        if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2003') {
             throw new Error("Không thể xóa gói thuê vì còn booking đang sử dụng.");
        }
        throw new Error("Không tìm thấy gói thuê để xóa.");
    }
};

/*--------------------------------------------------------------------------*/
export const createVehicle = async (data: any, files?: Express.Multer.File[]) => {
    const validData = validateVehicleData(data, true);

    const locationExists = await prisma.locations.findUnique({
        where: { id: validData.location_id },
    });
    if (!locationExists) throw new Error("Địa điểm không tồn tại");

    const typeExists = await prisma.vehicle_types.findUnique({
        where: { id: validData.vehicle_type_id },
    });
    if (!typeExists) throw new Error("Loại xe không tồn tại (Vui lòng tạo loại xe trước)");

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
                const metaData = { 'Content-Type': file.mimetype };
                
                await minioClient.putObject(
                    BUCKET_NAME,
                    objectName,
                    file.buffer,
                    file.size,
                    metaData
                );
                imageUrls.push(objectName);
            })
        );
    }

    const newVehicle = await prisma.vehicles.create({
        data: {
            title: validData.title,
            plate_number: validData.plate_number,
            year: validData.year,
            brand: validData.brand,
            model: validData.model,
            status: validData.status, 
            images: { set: imageUrls },
            
            vehicle_type: {
                connect: { id: validData.vehicle_type_id } 
            },
            locations: {
                connect: { id: validData.location_id }, 
            },
        },
        include: {
            vehicle_type: true, 
            locations: true
        }
    });

    await invalidateVehicleCaches();

    return newVehicle;
};

export const updateVehicle = async (id: number, data: any, files?: Express.Multer.File[]) => {
  const validData = validateVehicleData(data, false);

  try {
    const vehicleExists = await prisma.vehicles.findUnique({ where: { id } });
    if (!vehicleExists) throw new Error("Không tìm thấy xe để cập nhật");

    const { location_id, vehicle_type_id, keep_images, ...vehicleData } = validData;

    if (location_id) {
      const locationExists = await prisma.locations.findUnique({ where: { id: location_id } });
      if (!locationExists) throw new Error("Địa điểm không tồn tại");
    }

    if (vehicle_type_id) {
        const typeExists = await prisma.vehicle_types.findUnique({ where: { id: vehicle_type_id } });
        if (!typeExists) throw new Error("Loại xe không tồn tại");
    }

    const newImageUrls: string[] = [];
    if(files && files.length > 0){
      await Promise.all(
        files.map(async (file) => {
          const fileExtension = file.originalname.split('.').pop();
          const objectName = `${uuidv4()}.${fileExtension}`;
          const metaData = {'Content-Type': file.mimetype};
          const bucketName = process.env.MINIO_BUCKKET_NAME || 'rentcar';

          await minioClient.putObject(
              bucketName,
              objectName,
              file.buffer,
              file.size,
              metaData
          );
          newImageUrls.push(objectName);
        })
      )
    }

  
    let finalImages: string[] = [];

    if (keep_images) {
        const keepList = Array.isArray(keep_images) ? keep_images : [keep_images];
        finalImages = [...keepList];
    } else {
        finalImages = vehicleExists.images || [];
    }
    finalImages = [...finalImages, ...newImageUrls];

    const updated = await prisma.vehicles.update({
      where: { id },
      data: {
        ...vehicleData, 
        images: finalImages,
        ...(location_id && { locations: { connect: { id: location_id } } }),
        ...(vehicle_type_id && { vehicle_type: { connect: { id: vehicle_type_id } } }),
      },
      include: {
          vehicle_type: true
      }
    });

    await invalidateVehicleCaches(id);

    return updated;
  } catch (error: any) {
    if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === "P2025") {
      throw new Error("Không tìm thấy xe để cập nhật");
    }
    throw error;
  }
};

export const deleteVehicle = async (id: number) => {
    try {
        await prisma.vehicles.delete({
            where: { id },
        });
        await invalidateVehicleCaches(id);
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

const enrichVehicleWithUrls = async (vehicle: any) => {
  if (!vehicle) return null;

  const imageUrls = await Promise.all(
    (vehicle.images || []).map(async (fileName: string) => {
      try {
        return await getPresignedUrl(fileName);
      } catch {
        return null;
      }
    })
  );

  return { ...vehicle, imageUrls: imageUrls.filter((url) => url) };
};

export const getVehicles = async (
  page: number,
  limit: number,
  searchTerm?: string,
  role?: string
) => {
  const skip = (page - 1) * limit;
  const cacheKey = `vehicles:page:${page}:limit:${limit}${searchTerm ? `:search:${searchTerm}` : ""}`;

  let rawDataResult; 

  if (page === 1 && !searchTerm && role !== "customer") {
    try {
      const cachedData = await redisClient.get(cacheKey);
      if (cachedData) {
        console.log("✅ CACHE HIT: Lấy data thô từ Redis");
        rawDataResult = JSON.parse(cachedData);
      }
    } catch (err) {
      console.error("Lỗi Redis:", err);
    }
  }

  if (!rawDataResult) {
    const whereClause: Prisma.vehiclesWhereInput = {};
    const searchConditions: Prisma.vehiclesWhereInput[] = [];

    if (searchTerm) {
      searchConditions.push({ title: { contains: searchTerm, mode: "insensitive" } });
      searchConditions.push({ brand: { contains: searchTerm, mode: "insensitive" } });
      searchConditions.push({ model: { contains: searchTerm, mode: "insensitive" } });
      searchConditions.push({ plate_number: { contains: searchTerm, mode: "insensitive" } });
      searchConditions.push({ vehicle_type: { name: { contains: searchTerm, mode: "insensitive" } } });
    }

    const filterConditions: Prisma.vehiclesWhereInput[] = [];
    if (role === "customer") {
      filterConditions.push({ status: "available" });
    }

    if (filterConditions.length > 0) whereClause.AND = filterConditions;
    if (searchConditions.length > 0) whereClause.OR = searchConditions;

    const [vehicles, total] = await prisma.$transaction([
      prisma.vehicles.findMany({
        where: whereClause,
        skip,
        take: limit,
        orderBy: { created_at: "desc" },
        include: {
          locations: true,
          vehicle_type: {
            include: {
              rental_packages: { orderBy: { duration_hours: 'asc' } }
            }
          }
        },
      }),
      prisma.vehicles.count({ where: whereClause }),
    ]);

    const totalPages = Math.ceil(total / limit);

    rawDataResult = {
      data: vehicles, 
      pagination: {
        totalItems: total,
        currentPage: page,
        totalPages,
        limit,
        ...(searchTerm && { searchTerm }),
      },
    };

    if (page === 1 && !searchTerm && role !== "customer") {
      try {
        await redisClient.setEx(cacheKey, CACHE_TTL_LIST, JSON.stringify(rawDataResult));
      } catch (err) { console.error(err); }
    }
  }

  const vehiclesWithUrls = await Promise.all(
    rawDataResult.data.map(async (vehicle: any) => {
        return await enrichVehicleWithUrls(vehicle);
    })
  );

  return {
      ...rawDataResult,
      data: vehiclesWithUrls
  };
};

export const getVehicleById = async (id: number) => {
  const cacheKey = `vehicle:${id}`;
  
  const cachedData = await redisClient.get(cacheKey);
  
  let vehicleData; 

  if (cachedData) {
    console.log("✅ Lấy dữ liệu thô từ Redis cache");
    vehicleData = JSON.parse(cachedData);
  } else {
    vehicleData = await prisma.vehicles.findUnique({
      where: { id },
      include: {
        locations: { select: { id: true, name: true, address: true } },
        vehicle_type: {
            include: {
                rental_packages: { orderBy: { duration_hours: 'asc' } }
            }
        }
      },
    });

    if (!vehicleData) throw new Error("Không tìm thấy xe");

    await redisClient.setEx(cacheKey, 60 * 10, JSON.stringify(vehicleData)); 
  }

  return await enrichVehicleWithUrls(vehicleData);
};