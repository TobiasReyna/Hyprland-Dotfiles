#!/usr/bin/env bash
# Hyprlock battery status script

BAT_PATH=$(find /sys/class/power_supply -name "BAT*" 2>/dev/null | head -n 1)

if [ -z "$BAT_PATH" ] || [ ! -d "$BAT_PATH" ]; then
    exit 0
fi

CAPACITY=$(cat "$BAT_PATH/capacity" 2>/dev/null || echo "")
STATUS=$(cat "$BAT_PATH/status" 2>/dev/null || echo "")

[ -z "$CAPACITY" ] && exit 0

if [ "$STATUS" = "Charging" ]; then
    ICON="󰂄"
elif [ "$CAPACITY" -ge 90 ]; then
    ICON="󰁹"
elif [ "$CAPACITY" -ge 80 ]; then
    ICON="󰂂"
elif [ "$CAPACITY" -ge 70 ]; then
    ICON="󰂁"
elif [ "$CAPACITY" -ge 60 ]; then
    ICON="󰂀"
elif [ "$CAPACITY" -ge 50 ]; then
    ICON="󰁿"
elif [ "$CAPACITY" -ge 40 ]; then
    ICON="󰁾"
elif [ "$CAPACITY" -ge 30 ]; then
    ICON="󰁽"
elif [ "$CAPACITY" -ge 20 ]; then
    ICON="󰁼"
elif [ "$CAPACITY" -ge 10 ]; then
    ICON="󰁻"
else
    ICON="󰁺"
fi

echo "$ICON $CAPACITY%"
