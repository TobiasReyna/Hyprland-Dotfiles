#!/usr/bin/env bash
# Usage: screenshot.sh {area|full|window}
DIR="$HOME/Imágenes/Capturas"
mkdir -p "$DIR"
FILE="$DIR/captura_$(date +%Y%m%d_%H%M%S).png"

for dep in grim wl-copy; do
  command -v "$dep" >/dev/null || { notify-send "Screenshot" "Falta: $dep"; exit 1; }
done

annotate() {
  if command -v satty >/dev/null; then
    satty --filename "$1" --output-filename "$1" --copy-command wl-copy
  elif command -v swappy >/dev/null; then
    swappy -f "$1" -o "$1"
  fi
}

done_msg() { notify-send "Captura guardada" "$FILE" 2>/dev/null; }

case "$1" in
  area)
    command -v slurp >/dev/null || { notify-send "Screenshot" "Falta: slurp"; exit 1; }
    GEOM=$(slurp -d) || exit 0
    [ -z "$GEOM" ] && exit 0
    grim -g "$GEOM" "$FILE" || exit 1
    wl-copy < "$FILE"
    annotate "$FILE"
    [ -f "$FILE" ] && wl-copy < "$FILE"
    done_msg
    ;;
  full)
    grim "$FILE" || exit 1
    wl-copy < "$FILE"
    done_msg
    ;;
  window)
    GEOM=$(hyprctl activewindow -j | jq -r 'select(.address != null) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
    [ -z "$GEOM" ] && { notify-send "Screenshot" "No hay ventana activa"; exit 1; }
    grim -g "$GEOM" "$FILE" || exit 1
    wl-copy < "$FILE"
    done_msg
    ;;
  *)
    echo "Uso: $0 {area|full|window}" >&2
    exit 1
    ;;
esac
