#!/bin/bash

# Ustalamy wersję Nginx i port
NGINX_VERSION="stable"
PORT="8063"

# Funkcja do wyświetlania informacji o krokach
info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

info "KONFIGURACJA" "Używam Nginx w wersji $NGINX_VERSION"

mkdir -p demo-nginx-app-1
cd demo-nginx-app-1 || exit

# Tworzymy prosty plik HTML
cat > index.html << EOF
<!DOCTYPE html>
<html>
<head>
  <title>Demo Nginx App 1</title>
</head>
<body>
  <h1>Hello from Nginx with Docker Volume!</h1>
</body>
</html>
EOF

# Tworzymy wolumin Docker
info "WOLUMIN" "Tworzę wolumin Docker o nazwie nginx_data"
docker volume create nginx_data

# Tworzymy i uruchamiamy kontener Nginx z podłączonym woluminem
info "KONTENER" "Tworzę i uruchamiam kontener Nginx z woluminem"
CONTAINER_ID=$(docker run -d -p $PORT:80 --name nginx-demo-container \
  -v nginx_data:/usr/share/nginx/html \
  nginx:$NGINX_VERSION)

echo "Utworzono kontener o ID: $CONTAINER_ID"

# Kopiujemy plik HTML do woluminu (przez kontener)
info "KOPIOWANIE" "Kopiowanie pliku HTML do woluminu"
docker cp index.html $CONTAINER_ID:/usr/share/nginx/html/

# Sprawdzamy czy serwer zwraca naszą stronę
sleep 3
RESPONSE=$(curl -s http://localhost:$PORT)
info "ODPOWIEDŹ" "Zawartość zwróconego pliku HTML:"
echo -e "\033[0;32m$RESPONSE\033[0m"

if [[ "$RESPONSE" == *"Hello from Nginx with Docker Volume"* ]]; then
  info "SPRAWDZANIE" "Sukces: Serwer zwrócił naszą stronę HTML"
else
  info "SPRAWDZANIE" "Błąd: Oczekiwana odpowiedź nie została znaleziona"
  echo "Otrzymano: ${RESPONSE:0:100}..."
fi

# Wyświetl informacje o woluminie
info "WOLUMIN INFO" "Informacje o utworzonym woluminie:"
docker volume inspect nginx_data

# Na końcu pokazujemy instrukcje jak zatrzymać i usunąć kontener oraz wolumin
info "SPRZĄTANIE" "Aby zatrzymać i usunąć kontener oraz wolumin, wykonaj:"
echo "docker stop $CONTAINER_ID"
echo "docker rm $CONTAINER_ID"
echo "docker volume rm nginx_data"
