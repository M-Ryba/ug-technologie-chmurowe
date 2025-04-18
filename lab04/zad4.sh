#!/bin/bash

# Funkcja do wyświetlania informacji o krokach
info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

# Funkcja do pytania o usunięcie kontenera
ask_remove_container() {
  local container_id=$1
  read -rp "Do you want to remove the temporary container? (y/n): " response
  if [[ "$response" =~ ^[yY]$ ]]; then
    info "Removing container..."
    docker stop ${container_id}
    docker rm ${container_id}
  fi
}

# Sprawdź czy podano wymagane argumenty
if [ $# -lt 2 ]; then
    echo "Usage: $0 <volume_name|archive_file.tar.gpg> [encrypt | decrypt]"
    echo "Example: $0 my_volume encrypt"
    echo "Example: $0 my_volume.tar.gpg decrypt"
    exit 1
fi

ACTION=$2

if [ "$ACTION" = "encrypt" ]; then
    # Dla szyfrowania argument to nazwa woluminu
    VOLUME_NAME=$1
    ARCHIVE_NAME="${VOLUME_NAME}.tar"
    ENCRYPTED_FILE="${ARCHIVE_NAME}.gpg"

    # Stwórz wolumin jeśli nie istnieje
    volume_exists=$(docker volume ls -q -f name=${VOLUME_NAME})
    if [ -z "$volume_exists" ];then
        info "Creating Docker volume: ${VOLUME_NAME}"
        docker volume create ${VOLUME_NAME}
    fi

    info "Encrypting volume: ${VOLUME_NAME}"

    # Stwórz tymczasowy kontener (Alpine Linux)
    CONTAINER_ID=$(docker run -d -v ${VOLUME_NAME}:/data alpine sleep 100)

    # Stwórz archiwum tar woluminu
    info "Creating archive of the volume..."
    docker exec ${CONTAINER_ID} tar -cf /${ARCHIVE_NAME} -C /data .

    # Skopiuj archiwum tar z woluminu
    docker cp ${CONTAINER_ID}:/${ARCHIVE_NAME} .

    # Zaszyfruj archiwum
    info "Encrypting the archive..."
    gpg --symmetric --cipher-algo AES256 ${ARCHIVE_NAME}

    # Usuń archiwum
    rm ${ARCHIVE_NAME}

    # Zapytaj o usunięcie kontenera
    ask_remove_container ${CONTAINER_ID}

    info "Volume encrypted to ${ENCRYPTED_FILE}"

elif [ "$ACTION" = "decrypt" ]; then
    # Dla deszyfrowania argument to plik .tar.gpg
    ENCRYPTED_FILE=$1

    # Sprawdź czy zaszyfrowane archiwum istnieje i ma właściwe rozszerzenie
    if [ ! -f "${ENCRYPTED_FILE}" ] || [[ "${ENCRYPTED_FILE}" != *.tar.gpg ]]; then
        info "Error" "Specified file ${ENCRYPTED_FILE} not found or not a .tar.gpg file!"
        exit 1
    fi

    # Wyciągnij nazwę woluminu z nazwy pliku
    ARCHIVE_NAME=${ENCRYPTED_FILE%.gpg}
    VOLUME_NAME=${ARCHIVE_NAME%.tar}

    info "Decrypting to volume: ${VOLUME_NAME}"

    # Stwórz wolumin jeśli nie istnieje
    volume_exists=$(docker volume ls -q -f name=${VOLUME_NAME})
    if [ -z "$volume_exists" ]; then
        info "Creating Docker volume: ${VOLUME_NAME}"
        docker volume create ${VOLUME_NAME}
    fi

    # Odszyfruj archiwum
    info "Decrypting the archive..."
    gpg --decrypt ${ENCRYPTED_FILE} > ${ARCHIVE_NAME}

    # Stwórz tymczasowy kontener (Alpine Linux)
    CONTAINER_ID=$(docker run -d -v ${VOLUME_NAME}:/data alpine sleep 100)

    # Skopiuj archiwum do kontenera
    docker cp ${ARCHIVE_NAME} ${CONTAINER_ID}:/

    # Wypakuj archiwum w kontenerze
    info "Extracting archive to the volume..."
    docker exec ${CONTAINER_ID} sh -c "rm -rf /data/* && tar -xf /${ARCHIVE_NAME} -C /data"

    # Usuń archiwum
    rm ${ARCHIVE_NAME}

    # Zapytaj o usunięcie kontenera
    ask_remove_container ${CONTAINER_ID}

    info "Volume ${VOLUME_NAME} has been successfully decrypted"
else
    info "Invalid action: ${ACTION}"
    info "Use 'encrypt' or 'decrypt'"
    exit 1
fi
