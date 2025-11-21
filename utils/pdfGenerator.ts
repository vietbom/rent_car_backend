import PDFDocument from 'pdfkit';
import path from 'path';
import fs from 'fs';
import type { invoices } from '@prisma/client';

// Nếu chưa có font tiếng Việt, sẽ dùng Helvetica mặc định
const FONT_PATH = path.join(process.cwd(), 'src', 'assets', 'fonts', 'Roboto-Regular.ttf');

interface InvoiceData {
  invoice: invoices;
  user: { name: string | null; email: string | null; phone: string | null };
  vehicle: { title: string; plate_number: string; brand?: string };
  booking: {
    start_datetime: Date;
    end_datetime: Date;
    actual_end_datetime?: Date;
    late_fee: number;
    cleaning_fee: number;
    compensation_fee: number;
    damage_fee: number;
    other_fee: number;
    total_surcharges: number;
  };
}

export const generateInvoicePDF = (data: InvoiceData): Promise<Buffer> => {
  return new Promise((resolve, reject) => {
    try {
      const doc = new PDFDocument({ size: 'A4', margin: 50 });
      const buffers: any[] = [];

      if (fs.existsSync(FONT_PATH)) doc.font(FONT_PATH);
      else doc.font('Helvetica');

      doc.on('data', buffers.push.bind(buffers));
      doc.on('end', () => resolve(Buffer.concat(buffers)));
      doc.on('error', reject);

      const { invoice, user, vehicle, booking } = data;
      const formatMoney = (amount: number) =>
        new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);

      // Header
      doc.fontSize(20).text('HÓA ĐƠN THANH TOÁN', { align: 'center' });
      doc.moveDown();
      doc.fontSize(12).text(`Mã Hóa Đơn: ${invoice.invoice_number}`);
      doc.text(`Ngày xuất: ${invoice.issued_at?.toLocaleDateString('vi-VN') ?? new Date().toLocaleDateString('vi-VN')}`);
      doc.moveDown();

      // Thông tin khách
      doc.text(`Khách hàng: ${user.name ?? 'Khách vãng lai'}`);
      doc.text(`SĐT: ${user.phone ?? 'N/A'}`);
      doc.text(`Email: ${user.email ?? 'N/A'}`);
      doc.moveDown();
      doc.text('-----------------------------------------------------------');
      doc.moveDown();

      // Thông tin xe
      doc.fontSize(14).text('Chi tiết dịch vụ:', { underline: true });
      doc.fontSize(12).moveDown(0.5);
      doc.text(`Thuê xe: ${vehicle.title} ${vehicle.brand ?? ''}`);
      doc.text(`Biển số: ${vehicle.plate_number}`);
      doc.text(`Ngày thuê: ${booking.start_datetime.toLocaleString('vi-VN')}`);
      doc.text(`Ngày trả dự kiến: ${booking.end_datetime.toLocaleString('vi-VN')}`);
      doc.text(`Ngày trả thực tế: ${booking.actual_end_datetime?.toLocaleString('vi-VN') ?? 'Chưa có'}`);
      doc.moveDown();
      doc.text('-----------------------------------------------------------');
      doc.moveDown();

      // Chi phí
      doc.text(`Phí trễ: ${formatMoney(booking.late_fee)}`, { align: 'right' });
      doc.text(`Phí dọn xe: ${formatMoney(booking.cleaning_fee)}`, { align: 'right' });
      doc.text(`Phí đền bù: ${formatMoney(booking.compensation_fee)}`, { align: 'right' });
      doc.text(`Phí hư hỏng: ${formatMoney(booking.damage_fee)}`, { align: 'right' });
      doc.text(`Phí khác: ${formatMoney(booking.other_fee)}`, { align: 'right' });
      doc.moveDown();
      doc.fontSize(14).text(`Tổng phụ phí: ${formatMoney(booking.total_surcharges)}`, { align: 'right' });

      // Tổng cộng
      doc.moveDown();
      const baseAmount = Number(invoice.base_amount ?? 0);
      const taxAmount = Number(invoice.tax_amount ?? 0);
      const totalAmount = Number(invoice.total_amount ?? 0);
      doc.text(`Thành tiền (Chưa thuế): ${formatMoney(baseAmount)}`, { align: 'right' });
      doc.text(`Thuế VAT (${invoice.tax_rate ?? 8}%): ${formatMoney(taxAmount)}`, { align: 'right' });
      doc.moveDown();
      doc.fontSize(16).text(`TỔNG CỘNG: ${formatMoney(totalAmount)}`, { align: 'right' });

      // Footer
      doc.moveDown(4);
      doc.fontSize(10).text('Cảm ơn quý khách đã sử dụng dịch vụ!', { align: 'center' });

      doc.end();
    } catch (error) {
      console.error('⚠️ Lỗi trong generateInvoicePDF:', error);
      reject(error);
    }
  });
};

