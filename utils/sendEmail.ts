import nodemailer from "nodemailer";
import type { Transporter } from "nodemailer";
import dotenv from 'dotenv';
dotenv.config();

let transporter: Transporter | null = null;

const createTransporter = (): Transporter => {
    if (transporter) return transporter;

    transporter = nodemailer.createTransport({
        host: process.env.MAILTRAP_HOST || process.env.MAIL_HOST || "sandbox.smtp.mailtrap.io",
        port: parseInt(process.env.MAILTRAP_PORT || '587', 10),
        secure: process.env.MAILTRAP_PORT === '465' ? true : false, 
        auth: {
            user: process.env.MAILTRAP_USER || process.env.MAIL_USER,
            pass: process.env.MAILTRAP_PASS || process.env.MAIL_PASS,
        },
    });
    return transporter;
};


export const sendEmail = async (to: string, subject: string, htmlContent: string, from?: string) => {
    const mailTransporter = createTransporter();

    const mailFrom = from || `"Support" <${process.env.MAIL_USER}>`;

    await mailTransporter.sendMail({
        from: mailFrom,
        to: to,
        subject: subject,
        html: htmlContent, 
    });
};

export const sendSecurityAlert = async (ipAddress: string, attempts: number) => {
    const adminEmail = process.env.ADMIN_ALERT_EMAIL || 'admin@yourrentalservice.com';
    const currentTime = new Date().toLocaleString('vi-VN');

    const htmlContent = `
        <div style="font-family: Arial, sans-serif; line-height: 1.6;">
            <h2 style="color: red;">🚨 PHÁT HIỆN ĐĂNG NHẬP BẤT THƯỜNG</h2>
            <p>Hệ thống Mini IDS đã tự động khóa một địa chỉ IP do hành vi Brute-force.</p>
            <hr>
            <p><strong>Chi tiết sự kiện:</strong></p>
            <ul>
                <li><strong>Địa chỉ IP bị chặn:</strong> <code>${ipAddress}</code></li>
                <li><strong>Số lần thất bại:</strong> ${attempts} lần</li>
                <li><strong>Thời gian phát hiện:</strong> ${currentTime}</li>
                <li><strong>Lệnh đã thực thi:</strong> IP này sẽ bị từ chối truy cập trong ${process.env.BLOCK_WINDOW_SECONDS || 3600} giây.</li>
            </ul>
            <p style="margin-top: 20px; color: #555;">Vui lòng kiểm tra log hệ thống nếu hành vi này tiếp tục xảy ra.</p>
        </div>
    `;

    try {
      await sendEmail(
          adminEmail, 
          `[CẢNH BÁO BẢO MẬT] KHÓA IP: ${ipAddress} Đã bị chặn truy cập`, 
          htmlContent,
          '"Rent Car App Security" <security@rentcarapp.com>' // Email người gửi chuyên biệt
      );
      console.log(`✅ Security alert email sent to ${adminEmail}`);
    } catch (error) {
      console.error('❌ Error sending security email:', error);
      // Không re-throw để đảm bảo luồng chính (login) không bị ảnh hưởng bởi lỗi email
    }
};