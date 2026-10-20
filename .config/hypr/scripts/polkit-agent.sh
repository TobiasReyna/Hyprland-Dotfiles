#!/usr/bin/env bash
for agent in /usr/lib/hyprpolkitagent/hyprpolkitagent \
             /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 \
             /usr/lib/polkit-kde-authentication-agent-1; do
  [ -x "$agent" ] && exec "$agent"
done
echo "No polkit agent found (install hyprpolkitagent)" >&2
