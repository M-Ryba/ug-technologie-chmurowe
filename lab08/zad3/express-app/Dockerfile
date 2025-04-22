FROM node:23-slim

WORKDIR /app

COPY package.json app.js ./

RUN npm install

CMD ["npm", "start"]
