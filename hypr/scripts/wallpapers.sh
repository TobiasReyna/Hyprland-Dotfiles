#!/bin/bash
# wallpapers.sh
# Usando rofi para seleccionar (con iconos), awww para aplicar y wallust para extraer colores.

WALL_DIR="$HOME/Imágenes/Wallpapers"

# Comprobar si el directorio existe
if [ ! -d "$WALL_DIR" ]; then
    mkdir -p "$WALL_DIR"
    notify-send "Wallpapers" "Directorio creado en $WALL_DIR. Agrega algunas imágenes."
    exit 1
fi

# Seleccionar fondo con rofi usando previas de imágenes
# Para que rofi muestre iconos en dmenu, usamos el formato: Nombre\0icon\x1fRuta
SELECTED=$(find "$WALL_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | \
    while read -r file; do
        basename=$(basename "$file")
        echo -en "$basename\0icon\x1f$file\n"
    done | rofi -dmenu -show-icons -p "  Fondo" -theme-str 'window {width: 45%;} listview {lines: 4; columns: 3; flow: horizontal;} element { orientation: vertical; } element-icon { size: 6em; }')

if [ -z "$SELECTED" ]; then
    exit 0
fi

# Ruta completa de la imagen (siempre absoluta, nunca ~)
IMAGE_PATH="/home/tobito/Imágenes/Wallpapers/$SELECTED"

# -- Guardia de resiliencia: levantar el demonio si no responde --
if ! awww ping &>/dev/null; then
    awww-daemon &
    sleep 2
fi

# Aplicar el fondo con awww usando ruta absoluta
awww img "$IMAGE_PATH"

# --- Persistencia de estado: guardar el wallpaper actual ---
mkdir -p "$HOME/.cache"
echo "$IMAGE_PATH" > "$HOME/.cache/current_wallpaper"

# Extraer colores y generar templates con wallust
wallust run "$IMAGE_PATH"

# Aplicar cursor Catppuccin según el color dominante extraído por wallust
~/.config/hypr/scripts/set_cursor.sh

# Recargar ghostty para que tome los nuevos colores de inmediato
killall -SIGUSR1 ghostty

# Notificar al usuario
notify-send "Estética Actualizada" "Fondo: $SELECTED | Cursor: $(cat ~/.cache/wallust/dominant_color 2>/dev/null || echo '?')"

