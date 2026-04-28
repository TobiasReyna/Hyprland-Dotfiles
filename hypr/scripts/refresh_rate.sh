#!/bin/bash
# refresh_rate.sh
# Cambiar entre 144Hz y 60Hz nativamente usando hyprctl

# Extraer el nombre del monitor principal y la tasa de refresco actual (redondeada)
MONITOR=$(hyprctl monitors -j | grep -m 1 '"name":' | awk -F'"' '{print $4}')
CURRENT_RATE=$(hyprctl monitors -j | grep -m 1 '"refreshRate":' | awk -F':' '{print int($2)}')

# Si la tasa actual es 144 (o mayor por seguridad), cambiamos a 60
if [ "$CURRENT_RATE" -ge 140 ]; then
    # Cambiar a 60Hz para ahorrar batería
    hyprctl keyword monitor "$MONITOR, 1920x1200@60, 0x0, 1"
    notify-send "Tasa de Refresco" "Cambiada a 60Hz (Modo Ahorro)" -i video-display
else
    # Volver a 144Hz para fluidez máxima
    hyprctl keyword monitor "$MONITOR, 1920x1200@144, 0x0, 1"
    notify-send "Tasa de Refresco" "Cambiada a 144Hz (Modo Rendimiento)" -i video-display
fi
