#!/usr/bin/env bash

WALL_DIR="$HOME/Imágenes/Wallpapers"
mkdir -p "$WALL_DIR"

# Generar lista con miniaturas para Rofi
SELECTED=$(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | while read -r img; do
  echo -en "$(basename "$img")\0icon\x1f$img\n"
done | rofi -dmenu -i -p "  Wallpaper" -theme ~/.config/rofi/launcher.rasi)

if [ -n "$SELECTED" ]; then
  FULL_PATH="$WALL_DIR/$SELECTED"
  # Animación de transición de fondo con awww
  awww img "$FULL_PATH" --transition-type grow --transition-pos 0.85,0.9 --transition-step 90 --transition-fps 144
  # Generar paleta adaptativa y recargar colores
  matugen image "$FULL_PATH"
  killall -SIGUSR1 ghostty 2>/dev/null
fi
