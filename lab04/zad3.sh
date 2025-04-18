#!/bin/bash

# Pobieranie listy woluminów
volumes=$(docker volume ls -q)

echo "=== Docker volume usage ==="
echo "Volume Name                  Usage (%)"
echo "----------------             ----------"

# Sprawdzanie i wyświetlanie zużycia dysku dla każdego woluminu
for volume in $volumes; do
    mountpoint=$(docker volume inspect --format '{{ .Mountpoint }}' $volume)
    echo $mountpoint
    usage=$(df -h $mountpoint | awk 'NR==2 {print $5}')
    echo "$volume                  $usage"
done
