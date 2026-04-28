#!/bin/bash
# set_cursor.sh
# Selecciona y aplica un cursor Catppuccin Mocha basado en el color de mayor
# croma (saturación visual) entre los acentos generados por wallust.
#
# El caché ~/.cache/wallust/dominant_color contiene 7 líneas (color1..color7).
# El algoritmo:
#   1) De los 7 acentos, elige el de mayor croma = max(R,G,B) - min(R,G,B)
#      → este es el color que el ojo percibe como "el color del tema"
#   2) Calcula distancia euclidiana en RGB contra la paleta Catppuccin Mocha
#   3) Aplica el cursor cuyo color canónico está más cercano
#
# Fallback: catppuccin-mocha-mauve-cursors (si el caché no existe o hay error)

set -euo pipefail

CURSOR_SIZE=24
FALLBACK_COLOR="mauve"
CACHE_FILE="$HOME/.cache/wallust/dominant_color"
DOMINANT_HEX="(sin caché)"   # valor por defecto para el log
MATCHED_COLOR="$FALLBACK_COLOR"

# --- Paleta canónica Catppuccin Mocha (hex sin '#') ---
declare -A CATPPUCCIN_MOCHA=(
    [rosewater]="f5e0dc"
    [flamingo]="f2cdcd"
    [pink]="f5c2e7"
    [mauve]="cba6f7"
    [red]="f38ba8"
    [maroon]="eba0ac"
    [peach]="fab387"
    [yellow]="f9e2af"
    [green]="a6e3a1"
    [teal]="94e2d5"
    [sky]="89dceb"
    [sapphire]="74c7ec"
    [blue]="89b4fa"
    [lavender]="b4befe"
)

# --- Función: convertir HEX a componentes R G B ---
hex_to_rgb() {
    local hex="${1#\#}"  # eliminar '#' si existe
    printf "%d %d %d" \
        "$(( 16#${hex:0:2} ))" \
        "$(( 16#${hex:2:2} ))" \
        "$(( 16#${hex:4:2} ))"
}

# --- Función: croma = max(R,G,B) - min(R,G,B) ---
# Cuanto mayor, más "vívido" y saturado es el color.
color_chroma() {
    local r=$1 g=$2 b=$3
    local max=$r min=$r
    (( g > max )) && max=$g
    (( b > max )) && max=$b
    (( g < min )) && min=$g
    (( b < min )) && min=$b
    echo $(( max - min ))
}

# --- Función: distancia euclidiana al cuadrado en RGB ---
color_distance_sq() {
    local r1=$1 g1=$2 b1=$3 r2=$4 g2=$5 b2=$6
    echo $(( (r1-r2)**2 + (g1-g2)**2 + (b1-b2)**2 ))
}

# --- Leer colores del caché y elegir el de mayor croma ---
if [[ ! -f "$CACHE_FILE" ]]; then
    notify-send "set_cursor" "Caché wallust no encontrado. Usando fallback: $FALLBACK_COLOR" \
        --urgency=low 2>/dev/null || true
else
    BEST_CHROMA=-1
    BEST_HEX=""

    while IFS= read -r line; do
        hex=$(echo "$line" | tr -d '[:space:]')
        [[ "$hex" =~ ^#[0-9a-fA-F]{6}$ ]] || continue

        read -r R G B <<< "$(hex_to_rgb "$hex")"
        chroma=$(color_chroma "$R" "$G" "$B")

        if (( chroma > BEST_CHROMA )); then
            BEST_CHROMA=$chroma
            BEST_HEX=$hex
        fi
    done < "$CACHE_FILE"

    if [[ -z "$BEST_HEX" ]]; then
        notify-send "set_cursor" "No se encontró HEX válido en caché. Usando fallback." \
            --urgency=low 2>/dev/null || true
    else
        DOMINANT_HEX="$BEST_HEX (chroma=${BEST_CHROMA})"

        # --- Buscar el color Catppuccin más cercano por distancia euclidiana ---
        read -r DR DG DB <<< "$(hex_to_rgb "$BEST_HEX")"

        BEST_NAME="$FALLBACK_COLOR"
        BEST_DIST=99999999

        for name in "${!CATPPUCCIN_MOCHA[@]}"; do
            hex="${CATPPUCCIN_MOCHA[$name]}"
            read -r CR CG CB <<< "$(hex_to_rgb "$hex")"
            dist=$(color_distance_sq "$DR" "$DG" "$DB" "$CR" "$CG" "$CB")

            if (( dist < BEST_DIST )); then
                BEST_DIST=$dist
                BEST_NAME=$name
            fi
        done

        MATCHED_COLOR="$BEST_NAME"
    fi
fi

CURSOR_NAME="catppuccin-mocha-${MATCHED_COLOR}-cursors"

# --- Aplicar el cursor en las 4 capas ---

# 1) Hyprland compositor (efecto inmediato en ventanas Wayland nativas)
if command -v hyprctl &>/dev/null; then
    hyprctl setcursor "$CURSOR_NAME" "$CURSOR_SIZE" &>/dev/null || true
fi

# 2) gsettings / dconf (GTK apps — efecto en próxima apertura de ventana)
if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_NAME" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-size  "$CURSOR_SIZE"  2>/dev/null || true
fi

# 3) gtk-3.0 settings.ini (persistencia en disco)
GTK3_SETTINGS="$HOME/.config/gtk-3.0/settings.ini"
if [[ -f "$GTK3_SETTINGS" ]]; then
    sed -i "s/^gtk-cursor-theme-name=.*/gtk-cursor-theme-name=$CURSOR_NAME/" "$GTK3_SETTINGS"
    sed -i "s/^gtk-cursor-theme-size=.*/gtk-cursor-theme-size=$CURSOR_SIZE/"  "$GTK3_SETTINGS"
fi

# 4) ~/.icons/default/index.theme (fallback XWayland / XCURSOR)
mkdir -p "$HOME/.icons/default"
cat > "$HOME/.icons/default/index.theme" <<EOF
[Icon Theme]
Name=Default
Comment=Default cursor theme — set by set_cursor.sh
Inherits=$CURSOR_NAME
EOF

# --- Log de auditoría ---
echo "[set_cursor] $(date '+%H:%M:%S') | dominant=${DOMINANT_HEX} matched=${MATCHED_COLOR} cursor=${CURSOR_NAME}" \
    >> "$HOME/.cache/wallust/cursor.log" 2>/dev/null || true
