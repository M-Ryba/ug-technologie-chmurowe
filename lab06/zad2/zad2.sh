#!/bin/bash

docker network create --driver bridge --subnet 192.168.1.0/24 --gateway 192.168.1.1 my_bridge
docker run -dt --name web --network my_bridge -p 3000:3000 node:latest
docker run -dt --name db --network my_bridge -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=testdb mysql:latest

echo "Waiting for MySQL to initialize (15s)..."
sleep 15

docker cp ./db/init.sql db:/init.sql
docker exec db mysql -uroot -ppassword testdb -e "source /init.sql"

docker exec web mkdir -p /app

docker cp ./web/package.json web:/app/
docker cp ./web/server.js web:/app/

docker exec -w /app web npm install -y
docker exec -w /app web npm run start
