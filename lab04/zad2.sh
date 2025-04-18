#!/bin/bash

# Funkcja do wyświetlania informacji o krokach
info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

# Utwórz wolumin nodejs_data
info "Creating nodejs_data volume..."
docker volume create nodejs_data

# Uruchom kontener Node.js z nodejs_data zamontowanym w katalogu /app
info "Running Node.js container with volume mounted at /app..."
docker run -d --name nodejs_container \
  -v nodejs_data:/app \
  node:latest \
  tail -f /dev/null

# Utwórz przykładowe pliki w katalogu /app
info "Creating example files in /app directory..."
docker exec nodejs_container sh -c "echo 'console.log(\"Hello World\");' > /app/index.js"
docker exec nodejs_container sh -c "echo '{\"name\":\"node-app\",\"version\":\"1.0.0\"}' > /app/package.json"

# Utwórz wolumin all_volumes
info "Creating all_volumes volume..."
docker volume create all_volumes

# Sprawdź i utwórz wolumin nginx_data jeśli nie istnieje
info "Checking nginx_data volume..."
if ! docker volume inspect nginx_data &>/dev/null; then
  info "Creating nginx_data volume..."
  docker volume create nginx_data

  # Utwórz tymczasowy kontener nginx z przykładowymi plikami
  info "Creating example nginx files..."
  docker run --rm -v nginx_data:/usr/share/nginx/html nginx:alpine sh -c "echo '<html><body><h1>Nginx Test Page</h1></body></html>' > /usr/share/nginx/html/index.html"
fi

# Kopiuj pliki z nginx_data do all_volumes (tymczasowy kontener Alpine Linux)
info "Copying files from nginx_data:/usr/share/nginx/html to all_volumes..."
docker run --rm \
  -v nginx_data:/usr/share/nginx/html \
  -v all_volumes:/destination \
  alpine \
  sh -c "cp -r /usr/share/nginx/html/* /destination/ || echo 'No files to copy or directory empty'"

# Zaktualizuj nodejs_container, aby miał dostęp do all_volumes
info "Updating Node.js container to access all_volumes..."
docker stop nodejs_container
docker rm nodejs_container
docker run -d --name nodejs_container \
  -v nodejs_data:/app \
  -v all_volumes:/destination \
  node:latest \
  tail -f /dev/null

# Kopiuj pliki z /app do all_volumes z wnętrza kontenera
info "Copying files from /app to all_volumes from within the container..."
docker exec nodejs_container sh -c "cp -r /app/* /destination/"

info "Operation completed successfully!"
