local scripts = os.getenv("HOME") .. "/.config/hypr/scripts"

hl.on("hyprland.start", function()
    -- Push session env into systemd/dbus first so tray menus (Qt) and desktop services get the theme
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP QT_QPA_PLATFORMTHEME QT_STYLE_OVERRIDE XCURSOR_THEME XCURSOR_SIZE HYPRCURSOR_THEME HYPRCURSOR_SIZE")
    -- Enforce cursor theme and size in Hyprland
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
    -- Portals / PipeWire in the correct order (script kills stale portals first)
    hl.exec_cmd(scripts .. "/portal-restart.sh")
    -- Authentication agent (first one found)
    hl.exec_cmd(scripts .. "/polkit-agent.sh")
    -- Wallpaper daemon, then shell
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("quickshell")
    -- Scratchpad terminal (hidden in special workspace)
    hl.exec_cmd("[workspace special:scratchpad silent] ghostty --class=ghostty.scratchpad")
    -- Idle management (dim / lock / dpms / suspend)
    hl.exec_cmd("hypridle")
    -- On-screen display daemon
    hl.exec_cmd("swayosd-server")
    -- Notification center daemon
    hl.exec_cmd("swaync")
    -- Tray applets
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")
end)
