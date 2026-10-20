-- Default apps
hl.env("BROWSER", "firefox")
hl.env("TERMINAL", "ghostty")

-- Wayland
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_STYLE_OVERRIDE", "breeze")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- NVIDIA (hybrid Intel + RTX 4060)
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")

hl.config({
    cursor = {
        no_hardware_cursors = 1,
    },
})

-- XWayland: render at 1:1 instead of bitmap-scaling (sharp with fractional scale)
hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})
