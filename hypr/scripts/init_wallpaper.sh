#!/bin/bash
# init_wallpaper.sh
# Script de inicio para Hyprland.
# Restaura el último wallpaper seleccionado por el usuario, o usa el fallback
# si es el primer arranque / no hay caché.
# Al terminar, sincroniza el cursor con set_cursor.sh.

CACHE_FILE="$HOME/.cache/current_wallpaper"
FALLBACK_WALL="$HOME/Imágenes/Wallpapers/fallen_angel.png"
SCRIPTS_DIR="$(dirname "$(realpath "$0")")"

# --- 1) Esperar a que el socket de awww esté listo ---
# awww-daemon se lanza antes que este script en exec.conf.
# Reintentamos hasta 10 segundos para no tener race-condition.
for i in $(seq 1 10); do
    if awww ping &>/dev/null; then
        break
    fi
    sleep 1
done

# --- 2) Elegir el wallpaper a aplicar ---
if [[ -f "$CACHE_FILE" ]]; then
    WALL_PATH=$(cat "$CACHE_FILE")

    # Verificar que la ruta sigue siendo válida (archivo no fue eliminado/movido)
    if [[ ! -f "$WALL_PATH" ]]; then
        notify-send "init_wallpaper" \
            "Wallpaper en caché no encontrado:\n$WALL_PATH\nUsando fallback." \
            --urgency=low 2>/dev/null || true
        WALL_PATH="$FALLBACK_WALL"
    fi
else
    # Primer arranque: no hay caché todavía
    WALL_PATH="$FALLBACK_WALL"
fi

# --- 3) Aplicar el wallpaper y regenerar colores ---
awww img "$WALL_PATH"
wallust run "$WALL_PATH"

# --- 4) Sincronizar el cursor con el tema de color actual ---
# sleep 1 extra para garantizar que hyprctl esté listo para recibir setcursor
sleep 1
"$SCRIPTS_DIR/set_cursor.sh"
