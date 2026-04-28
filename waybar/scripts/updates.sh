#!/usr/bin/env bash
# ~/.config/waybar/scripts/updates.sh

# ── Repositorios oficiales ───────────────────────────────────────
official_count=$(checkupdates 2>/dev/null | wc -l)

# ── AUR via paru ─────────────────────────────────────────────────
aur_count=$(paru -Qua 2>/dev/null | wc -l)

# ── Total ────────────────────────────────────────────────────────
total=$((official_count + aur_count))

# Si no hay nada que actualizar, salimos sin imprimir nada.
[[ "$total" -eq 0 ]] && exit 0

# ── Salida JSON limpia ───────────────────────────────────────────
printf '{"text":"%s","tooltip":"%s oficiales, %s AUR","class":"pending"}\n' "$total" "$official_count" "$aur_count"
