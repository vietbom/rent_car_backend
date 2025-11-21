import z from "zod";
import { v4 as uuidv4 } from 'uuid';
export const validateRegisterData = (data: any) => {
    const {email, password, name, phone} = data;

    if(!email || !password || !name ||!phone){
        throw new Error("Email/Password/Name/Phone là thông tin bắt buộc");
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        throw new Error("Email không hợp lệ");
    }

    if (password.length <= 8) {
        throw new Error("Mật khẩu phải có ít nhất 8 ký tự");
    }

    if(!/[A-Z]/.test(password)){
        throw new Error("Mật khẩu phải chứa ít nhất một chữ hoa");
    }

    if(!/[a-z]/.test(password)){
        throw new Error("Mật khẩu phải chứa ít nhất một chữ thường");
    }

    if(!/[^A-Za-z0-9]/.test(password)){
        throw new Error("Mật khẩu phải chứa ít nhất một ký tự đặc biệt");
    }

    const phoneRegex = /^\d{9,10}$/;
    if (!phoneRegex.test(phone)) {
        throw new Error("Số điện thoại phải là 9 hoặc 10 chữ số");
    }

    return { email, password, name, phone };
}

export const validateLoginData = (data: any) => {
    const {email, password, name, phone} = data;

    if(!email || !password ){
        throw new Error("Email/Passwordlà thông tin bắt buộc");
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        throw new Error("Email không hợp lệ");
    }

    if (password.length <= 8) {
        throw new Error("Mật khẩu phải có ít nhất 8 ký tự");
    }

    if(!/[A-Z]/.test(password)){
        throw new Error("Mật khẩu phải chứa ít nhất một chữ hoa");
    }

    if(!/[a-z]/.test(password)){
        throw new Error("Mật khẩu phải chứa ít nhất một chữ thường");
    }

    if(!/[^A-Za-z0-9]/.test(password)){
        throw new Error("Mật khẩu phải chứa ít nhất một ký tự đặc biệt");
    }

    return { email, password};
}

export const validateEmail = (data: any) =>{
    const {email} = data;
    if (!email) {
        throw new Error("Email là bắt buộc");
    }
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        throw new Error("Email không hợp lệ");
    }

    return {email};
}

export const validateAccount = (data: any) =>{
    const {email, otp, newPassword} = data;
    if (!email || !otp || !newPassword) {
        throw new Error("Thiếu thông tin email, OTP, hoặc mật khẩu mới");
    }
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        throw new Error("Email không hợp lệ");
    }

    if(!otp || otp.length !== 6 ){
        throw new Error("Mật khẩu phải có 6 ký tự");
    }

    if (newPassword.length <= 8) {
        throw new Error("Mật khẩu phải có ít nhất 8 ký tự");
    }

    if(!/[A-Z]/.test(newPassword)){
        throw new Error("Mật khẩu phải chứa ít nhất một chữ hoa");
    }

    if(!/[a-z]/.test(newPassword)){
        throw new Error("Mật khẩu phải chứa ít nhất một chữ thường");
    }

    if(!/[^A-Za-z0-9]/.test(newPassword)){
        throw new Error("Mật khẩu phải chứa ít nhất một ký tự đặc biệt");
    }

    return {email, otp, newPassword};
}

export const validateVehicleData = (data: any, isCreate = true) => {
  const requiredFields = ["title", "plate_number", "year", "location_id", "vehicle_type_id"];

  if (isCreate) {
    for (const field of requiredFields) {
      if (!data[field]) throw new Error(`Trường ${field} là bắt buộc`);
    }
  }

  const validated: any = {
    ...(data.title && { title: data.title.trim() }),
    ...(data.plate_number && { plate_number: data.plate_number.trim() }),
    ...(data.brand && { brand: data.brand.trim() }),
    ...(data.model && { model: data.model.trim() }),
    ...(data.status && { status: data.status }),
    
    keep_images: data.keep_images ? (Array.isArray(data.keep_images) ? data.keep_images : [data.keep_images]) : undefined,
  };

  if (data.year !== undefined) validated.year = Number(data.year);
  if (data.location_id !== undefined) validated.location_id = Number(data.location_id);
  if (data.vehicle_type_id !== undefined) validated.vehicle_type_id = Number(data.vehicle_type_id);

  if (validated.year && (validated.year < 1980 || validated.year > new Date().getFullYear() + 1)) {
    throw new Error("Năm sản xuất không hợp lệ");
  }
  
  if (validated.location_id && validated.location_id <= 0) throw new Error("ID địa điểm không hợp lệ");
  if (validated.vehicle_type_id && validated.vehicle_type_id <= 0) throw new Error("ID loại xe không hợp lệ");

  return validated;
};

export const createVehicleTypeSchema = z.object({
  name: z.string().min(3, "Tên loại xe tối thiểu 3 ký tự"),
  seats: z.number().int().positive("Số ghế phải là số nguyên dương"),
  deposit_amount: z.number().positive("Tiền cọc phải là số dương"),
});

export const updateVehicleTypeSchema = z.object({
  name: z.string().min(3, "Tên loại xe tối thiểu 3 ký tự").optional(),
  seats: z.number().int().positive("Số ghế phải là số nguyên dương").optional(),
  deposit_amount: z.number().positive("Tiền cọc phải là số dương").optional(),
});

export const createRentalPackageSchema = z.object({
  vehicle_type_id: z.number().int().positive("ID loại xe không hợp lệ"),
  duration_hours: z.number().int().positive("Thời gian thuê (giờ) phải là số nguyên dương"),
  price: z.number().positive("Giá thuê phải là số dương"),
});

export const updateRentalPackageSchema = z.object({
  duration_hours: z.number().int().positive("Thời gian thuê (giờ) phải là số nguyên dương").optional(),
  price: z.number().positive("Giá thuê phải là số dương").optional(),
})

export const createBookingSchema = z.object({
  // Cách viết chuẩn: Gom tin nhắn lỗi vào config
  vehicle_id: z.number({ 
    required_error: "vehicle_id là bắt buộc", 
    invalid_type_error: "vehicle_id phải là số" 
  }),

  rental_package_id: z.number({ 
    required_error: "rental_package_id là bắt buộc",
    invalid_type_error: "rental_package_id phải là số"
  }),

  start_datetime: z.string({ 
    required_error: "start_datetime là bắt buộc" 
  }).min(1, "start_datetime không được để trống"),

  end_datetime: z.string({ 
    required_error: "end_datetime là bắt buộc" 
  }).min(1, "end_datetime không được để trống"),

  pickup_location_id: z.number({ 
    required_error: "pickup_location_id là bắt buộc",
    invalid_type_error: "pickup_location_id phải là số"
  }),

  dropoff_location_id: z.number({ 
    required_error: "dropoff_location_id là bắt buộc",
    invalid_type_error: "dropoff_location_id phải là số"
  }),
});

export const createReviewSchema = z.object({
  booking_id: z
    .number()
    .int({ message: "Booking ID phải là số nguyên" })
    .positive({ message: "Booking ID phải là số nguyên dương" })
    .refine(val => !!val, { message: "Booking ID là bắt buộc" }),

  rating: z
    .number()
    .int({ message: "Rating phải là số nguyên" })
    .min(1, { message: "Rating phải từ 1 đến 5" })
    .max(5, { message: "Rating phải từ 1 đến 5" })
    .refine(val => !!val, { message: "Rating (đánh giá) là bắt buộc" }),

  comment: z
    .string()
    .max(500, { message: "Bình luận không được vượt quá 500 ký tự" })
    .optional(),
});

export const earningsReportSchema = z.object({
  startDate: z.string().refine((v) => !isNaN(Date.parse(v)), "Ngày bắt đầu không hợp lệ"),
  endDate: z.string().refine((v) => !isNaN(Date.parse(v)), "Ngày kết thúc không hợp lệ"),
});

export const createLocationSchema = z.object({
  name: z
    .string()
    .min(2, "Tên địa điểm phải có ít nhất 2 ký tự")
    .max(100, "Tên địa điểm không được vượt quá 100 ký tự"),

  address: z
    .string()
    .max(255, "Địa chỉ không được vượt quá 255 ký tự")
    .optional(),

  lat: z
    .number()
    .min(-90, "Vĩ độ không hợp lệ")
    .max(90, "Vĩ độ không hợp lệ")
    .optional(),

  lng: z
    .number()
    .min(-180, "Kinh độ không hợp lệ")
    .max(180, "Kinh độ không hợp lệ")
    .optional(),
});