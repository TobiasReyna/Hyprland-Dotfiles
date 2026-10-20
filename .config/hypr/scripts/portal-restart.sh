#!/usr/bin/env bash
# Restart portals in the correct order so screen sharing works.
sleep 1
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE HYPRLAND_INSTANCE_SIGNATURE 2>/dev/null
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE HYPRLAND_INSTANCE_SIGNATURE 2>/dev/null

# Stop stale portals (reverse order)
for p in xdg-desktop-portal-hyprland xdg-desktop-portal-gnome xdg-desktop-portal-gtk xdg-desktop-portal; do
  killall -q "$p" 2>/dev/null
done
sleep 1

# PipeWire stack first
systemctl --user start pipewire wireplumber 2>/dev/null
sleep 1

# Backend, then frontend
for bin in /usr/lib/xdg-desktop-portal-hyprland /usr/libexec/xdg-desktop-portal-hyprland; do
  [ -x "$bin" ] && { "$bin" & break; }
done
sleep 2
for bin in /usr/lib/xdg-desktop-portal /usr/libexec/xdg-desktop-portal; do
  [ -x "$bin" ] && { "$bin" & break; }
done
wait
