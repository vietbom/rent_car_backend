
import { PrismaClient } from '@prisma/client';
import { io } from '../index.ts'; 

const prisma = new PrismaClient();

prisma.$use(async (params, next) => {
    const result = await next(params);

    if (params.model === 'bookings') {
        const relevantActions = ['create'];
        if (relevantActions.includes(params.action)) {
            console.log(`🔄 Detected change in Bookings via Prisma: ${params.action}`);
            
            io.emit('SERVER_REFRESH_BOOKINGS', {
                action: params.action,
                dataId: result?.id || null 
            });
        }
    }

    return result;
});

export default prisma; 