#!/bin/bash

# Ustalamy wersję Node.js i port
NODE_VERSION="14"
PORT="8064"

# Funkcja do wyświetlania informacji o krokach
info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

info "KONFIGURACJA" "Używam Node.js w wersji $NODE_VERSION"

mkdir -p demo-node-app-2
cd demo-node-app-2 || exit

# Tworzymy prosty plik package.json
echo '{
  "name": "demo-app-2",
  "version": "1.0.0",
  "main": "app.js",
  "dependencies": {
    "express": "^4.17.1"
  }
}' > package.json

# Tworzymy prosty plik aplikacji
cat > app.js << EOF
const express = require("express");
const app = express();
app.get("/", (req, res) => {
  const now = new Date();
  res.json({
    date: now.toISOString().split("T")[0],
    time: now.toTimeString().split(" ")[0],
  });
});
app.listen($PORT, () => {});
EOF

# Tworzymy i uruchamiamy kontener Docker w trybie detached (w tle)
info "KONTENER" "Tworzę i uruchamiam kontener Docker z Node.js $NODE_VERSION"
CONTAINER_ID=$(docker run -d -p $PORT:$PORT --name node-demo-container-2 -it node:$NODE_VERSION-alpine tail -f /dev/null)

echo "Utworzono kontener o ID: $CONTAINER_ID"

# Tworzymy katalog w kontenerze
info "STRUKTURA" "Tworzenie katalogu /app w kontenerze"
docker exec $CONTAINER_ID mkdir -p /app

# Kopiujemy pliki aplikacji do kontenera
info "KOPIOWANIE" "Kopiowanie plików aplikacji do kontenera za pomocą docker cp"
docker cp package.json $CONTAINER_ID:/app/
docker cp app.js $CONTAINER_ID:/app/

# Instalujemy zależności wewnątrz kontenera
info "ZALEŻNOŚCI" "Instalacja zależności Node.js wewnątrz kontenera"
docker exec -w /app $CONTAINER_ID npm install

# Uruchamiamy aplikację
info "URUCHOMIENIE" "Uruchamianie aplikacji Node.js w kontenerze"
docker exec -d -w /app $CONTAINER_ID node app.js

# Sprawdzamy czy serwer zwraca Hello World
sleep 3
response=$(curl -s http://localhost:$PORT)
if [[ "$response" == *"date"* && "$response" == *"time"* ]]; then
  echo "Sukces: Serwer zwrócił dane z datą i czasem"
  echo "$response"
else
  echo "Błąd: Serwer nie zwrócił oczekiwanych danych"
  echo "$response"
fi

# Na końcu pokazujemy instrukcje jak zatrzymać i usunąć kontener
info "SPRZĄTANIE" "Aby zatrzymać i usunąć kontener, wykonaj:"
echo "docker stop $CONTAINER_ID"
echo "docker rm $CONTAINER_ID"
