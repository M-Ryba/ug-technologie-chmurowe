#!/bin/bash

# Ustalamy wersję Node.js i port
NODE_VERSION="16"
PORT="8065"
MONGO_PORT="27017"

# Funkcja do wyświetlania informacji o krokach
info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

info "KONFIGURACJA" "Używam Node.js w wersji $NODE_VERSION i MongoDB"

mkdir -p demo-node-app-3
cd demo-node-app-3 || exit

# Tworzymy prosty plik package.json
echo '{
  "name": "demo-app-3",
  "version": "1.0.0",
  "main": "app.js",
  "dependencies": {
    "express": "^4.17.1",
    "mongodb": "^3.6.3"
  }
}' > package.json

# Tworzymy prosty plik aplikacji
cat > app.js << EOF
const express = require("express");
const { MongoClient } = require("mongodb");
const app = express();
const url = "mongodb://mongo:27017";
const client = new MongoClient(url);

async function seedDatabase() {
  try {
    await client.connect();
    const database = client.db("testdb");
    const collection = database.collection("testcollection");
    await collection.insertMany([{ name: "John Doe" }, { name: "Jane Doe" }]);
  } catch (error) {
    console.error("Error seeding database:", error);
  }
}

app.get("/", async (req, res) => {
  try {
    const database = client.db("testdb");
    const collection = database.collection("testcollection");
    const data = await collection.find({}).toArray();
    res.json(data);
  } catch (error) {
    res.status(500).send(error.toString());
  }
});

app.listen($PORT, async () => {
  await seedDatabase();
  console.log("Server is running on port $PORT");
});
EOF

# Tworzymy i uruchamiamy kontener Docker z MongoDB w trybie detached (w tle)
info "KONTENER" "Tworzę i uruchamiam kontener Docker z MongoDB"
MONGO_CONTAINER_ID=$(docker run -d -p $MONGO_PORT:27017 --name mongo-container mongo:latest)

# Tworzymy i uruchamiamy kontener Docker z Node.js w trybie detached (w tle)
info "KONTENER" "Tworzę i uruchamiam kontener Docker z Node.js $NODE_VERSION"
NODE_CONTAINER_ID=$(docker run -d -p $PORT:$PORT --link mongo-container:mongo --name node-demo-container-3 -it node:$NODE_VERSION-alpine tail -f /dev/null)

echo "Utworzono kontener MongoDB o ID: $MONGO_CONTAINER_ID"
echo "Utworzono kontener Node.js o ID: $NODE_CONTAINER_ID"

# Tworzymy katalog w kontenerze Node.js
info "STRUKTURA" "Tworzenie katalogu /app w kontenerze Node.js"
docker exec $NODE_CONTAINER_ID mkdir -p /app

# Kopiujemy pliki aplikacji do kontenera Node.js
info "KOPIOWANIE" "Kopiowanie plików aplikacji do kontenera Node.js za pomocą docker cp"
docker cp package.json $NODE_CONTAINER_ID:/app/
docker cp app.js $NODE_CONTAINER_ID:/app/

# Instalujemy zależności wewnątrz kontenera Node.js
info "ZALEŻNOŚCI" "Instalacja zależności Node.js wewnątrz kontenera"
docker exec -w /app $NODE_CONTAINER_ID npm install

# Uruchamiamy aplikację
info "URUCHOMIENIE" "Uruchamianie aplikacji Node.js w kontenerze"
docker exec -d -w /app $NODE_CONTAINER_ID node app.js

# Sprawdzamy czy serwer zwraca dane z MongoDB
sleep 3
response=$(curl -s http://localhost:$PORT)
if [[ "$response" == *"John Doe"* || "$response" == *"Jane Doe"* ]]; then
  echo "Sukces: Serwer zwrócił dane z MongoDB"
  echo "$response"
else
  echo "Błąd: Serwer nie zwrócił oczekiwanych danych"
  echo "$response"
fi

# Na końcu pokazujemy instrukcje jak zatrzymać i usunąć kontenery
info "SPRZĄTANIE" "Aby zatrzymać i usunąć kontenery, wykonaj:"
echo "docker stop $NODE_CONTAINER_ID $MONGO_CONTAINER_ID"
echo "docker rm $NODE_CONTAINER_ID $MONGO_CONTAINER_ID"
