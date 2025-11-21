import { io } from "../src/index.ts";

export const notifyAdmin = (type: 'BOOKING' | 'INVOICE', payload?: any) => {
    switch (type) {
        case 'BOOKING':
            io.emit('SERVER_REFRESH_BOOKINGS', payload);
            break;
        case 'INVOICE':
            io.emit('SERVER_REFRESH_INVOICES', payload);
            break;
    }
};