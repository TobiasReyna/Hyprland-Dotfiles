local colors = require("lua.colors")

hl.config({
    general = {
        gaps_in = 6,
        gaps_out = 12,
        border_size = 1,
        col = {
            -- Delicate 1px glass bevel: light specular reflection at 45 degrees
            active_border = { colors = { "rgba(ffffff65)", "rgba(ffffff15)" }, angle = 45 },
            inactive_border = { colors = { "rgba(ffffff25)", "rgba(00000015)" }, angle = 45 },
        },
        layout = "dwindle",
    },
    dwindle = {
        preserve_split = true,
    },
    decoration = {
        rounding = 16,
        active_opacity = 1.0,
        inactive_opacity = 0.94,
        blur = {
            enabled = true,
            size = 10,
            passes = 4,
            new_optimizations = true,
            ignore_opacity = true,
            xray = false,
            noise = 0.025,
            contrast = 1.20,
            brightness = 1.12,
            vibrancy = 0.45,
            vibrancy_darkness = 0.15,
            special = true,
            popups = true,
            popups_ignorealpha = 0.25,
        },
        shadow = {
            enabled = true,
            range = 40,
            render_power = 4,
            color = "rgba(00000055)",
            offset = "0 8",
        },
    },
    misc = {
        disable_hyprland_logo = true,
        vrr = 1,
    },
})
