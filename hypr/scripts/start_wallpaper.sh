#!/bin/bash
# start_wallpaper.sh
# Aplica el fondo de pantalla con un retraso para evitar la condición de carrera
# donde awww img se ejecuta antes de que el demonio esté listo para recibir comandos.

WALLPAPER="$HOME/Imágenes/Wallpapers/fallen_angel.png"
DELAY=2  # segundos de espera tras el inicio del demonio

sleep "$DELAY"

if [ -f "$WALLPAPER" ]; then
    awww img "$WALLPAPER"
else
    notify-send "awww" "Fondo no encontrado: $WALLPAPER" --urgency=normal
fi
