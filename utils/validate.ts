import z from "zod";

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
    const requiredFields = ["title", "plate_number", "year", "seats", "location_id", "price_per_day"];

    if (isCreate) {
    for (const field of requiredFields) {
        if (!data[field]) throw new Error(`Trường ${field} là bắt buộc`);
    }
    }

    const validated = {
        title: data.title?.trim(),
        plate_number: data.plate_number?.trim(),
        year: Number(data.year),
        seats: Number(data.seats),
        location_id: Number(data.location_id),
        price_per_day: Number(data.price_per_day),
        images: Array.isArray(data.images) ? data.images : [],
        description: data.description?.trim() || null,
    };

    if (validated.year < 1980 || validated.year > new Date().getFullYear() + 1) {
        throw new Error("Năm sản xuất không hợp lệ");
    }
    if (validated.seats <= 0) throw new Error("Số ghế phải lớn hơn 0");
    if (validated.price_per_day <= 0) throw new Error("Giá thuê mỗi ngày phải lớn hơn 0");

    return validated;
};

export const createBookingSchema = z.object({
    vehicle_id: z.number().refine(val => !!val, {
        message: "vehicle_id là bắt buộc",
    }),
    start_datetime: z.string().min(1, { message: "start_datetime là bắt buộc" }),
    end_datetime: z.string().min(1, { message: "end_datetime là bắt buộc" }),
    pickup_location_id: z.number().refine(val => !!val, {
        message: "pickup_location_id là bắt buộc",
    }),
    dropoff_location_id: z.number().refine(val => !!val, {
        message: "dropoff_location_id là bắt buộc",
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