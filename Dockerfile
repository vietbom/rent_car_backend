FROM node:18-alpine

RUN apk update && apk upgrade --no-cache

WORKDIR /app

COPY package*.json ./

RUN npm install
RUN npm install -g tsx nodemon

COPY . .

RUN npx prisma generate

EXPOSE 3000

CMD ["npm", "run", "dev"]