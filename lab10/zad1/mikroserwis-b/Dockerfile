FROM node:slim

WORKDIR /app

COPY package.json .
RUN npm install

COPY app.js .

EXPOSE 3001

CMD ["node", "app.js"]
