#!/bin/bash

docker network create --driver bridge --subnet 192.168.1.0/24 --gateway 192.168.1.1 my_bridge
docker run -dt --name my_container --network my_bridge alpine:latest
docker exec my_container ip addr show
docker exec my_container ping google.com
docker network inspect my_bridge