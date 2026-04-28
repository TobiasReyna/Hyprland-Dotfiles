#!/usr/bin/env bash
# theme-selector.sh — Selector de temas para Waybar
# Uso: ejecutar directamente o via atajo de teclado (SUPER+CTRL+B)
#
# Estructura esperada:
#   ~/.config/waybar/themes/
#   └── <nombre-del-tema>/
#       ├── config.jsonc
#       └── style.css

WAYBAR_DIR="${HOME}/.config/waybar"
THEMES_DIR="${WAYBAR_DIR}/themes"

# ── Validación ────────────────────────────────────────────────────
if [[ ! -d "${THEMES_DIR}" ]]; then
    notify-send "Waybar Themes" "Directorio de temas no encontrado:\n${THEMES_DIR}" --icon=dialog-error
    exit 1
fi

# ── Listado de temas disponibles ──────────────────────────────────
# Se listan sólo directorios (cada uno es un tema)
mapfile -t themes < <(ls -1 "${THEMES_DIR}")

if [[ ${#themes[@]} -eq 0 ]]; then
    notify-send "Waybar Themes" "No hay temas disponibles en:\n${THEMES_DIR}" --icon=dialog-warning
    exit 1
fi

# ── Selección via Rofi ────────────────────────────────────────────
selected=$(printf '%s\n' "${themes[@]}" | rofi -dmenu \
    -p "Tema Waybar" \
    -theme-str 'window {width: 400px;}' \
    -no-fixed-num-lines \
    -i)

# Si el usuario canceló (Esc / sin selección)
[[ -z "${selected}" ]] && exit 0

THEME_PATH="${THEMES_DIR}/${selected}"

# ── Validación del tema elegido ───────────────────────────────────
if [[ ! -f "${THEME_PATH}/config.jsonc" || ! -f "${THEME_PATH}/style.css" ]]; then
    notify-send "Waybar Themes" "El tema '${selected}' no tiene config.jsonc o style.css." --icon=dialog-error
    exit 1
fi

# ── Aplicar tema: crear/actualizar symlinks ───────────────────────
ln -sf "${THEME_PATH}/config.jsonc" "${WAYBAR_DIR}/config.jsonc"
ln -sf "${THEME_PATH}/style.css"    "${WAYBAR_DIR}/style.css"

notify-send "Waybar Themes" "Tema aplicado: ${selected}" --icon=dialog-information

# ── Recargar Waybar ───────────────────────────────────────────────
killall waybar && waybar &
