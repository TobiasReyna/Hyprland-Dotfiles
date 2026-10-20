#!/usr/bin/env bash

WALL_DIR="$HOME/Imágenes/Wallpapers"
mkdir -p "$WALL_DIR"

# Generar lista con miniaturas para Rofi
SELECTED=$(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -printf '%P\n' | sort | while read -r rel; do
  printf '%s\0icon\x1f%s\n' "$rel" "$WALL_DIR/$rel"
done | rofi -dmenu -i -show-icons -p "  Wallpaper" -theme ~/.config/rofi/launcher.rasi)

[ -z "$SELECTED" ] && exit 0
FULL_PATH="$WALL_DIR/$SELECTED"
[ -f "$FULL_PATH" ] || exit 1

# Asegurar que el daemon corre
pgrep -x awww-daemon >/dev/null || { awww-daemon >/dev/null 2>&1 & sleep 1; }

# Wallpaper con transición suave
awww img "$FULL_PATH" --transition-type grow --transition-pos 0.85,0.9 \
  --transition-step 90 --transition-fps 144 --transition-duration 1.2

# Paleta Material You -> todas las plantillas a la vez
matugen image "$FULL_PATH" --source-color-index 0

# Recargar aplicaciones
killall -SIGUSR1 ghostty 2>/dev/null || true
hyprctl reload >/dev/null 2>&1 || true  # works in Lua mode (re-runs hyprland.lua)
# Quickshell recarga Colors.qml automáticamente al cambiar el archivo
touch "$HOME/.config/quickshell/Colors.qml"
