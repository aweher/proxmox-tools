#!/bin/bash
# Ariel S. Weher <ariel[at]weher.net>
# https://weher.net

# Get current date and time
NOW=$(date +"%Y%m%d%H%M%S")
# Define files
map_file="/tmp/mapping.txt"
interfaces_file="/etc/network/interfaces"

# Hacer una copia de seguridad del archivo originalw
cp "$interfaces_file" "${interfaces_file}.backup.${NOW}"

# Leer el archivo de mapeo y actualizar el archivo de interfaces
while read -r old_name new_name; do
    sed -i "s/\b$old_name\b/$new_name/g" "$interfaces_file"
done < "$map_file"

echo "Interfaces file $interfaces_file was updated."
