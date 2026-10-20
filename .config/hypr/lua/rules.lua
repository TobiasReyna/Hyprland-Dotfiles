-- Window rules
hl.window_rule({ match = { class = "^(pavucontrol|nm-connection-editor|org.gnome.Calculator)$" }, float = true })
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, float = true, pin = true })
hl.window_rule({ match = { class = "^(swappy|com.gabm.satty)$" }, float = true })

-- Explicitly enforce 100% solid opacity on standard media/browser apps
hl.window_rule({ match = { class = "^(firefox)$" }, opaque = true })
hl.window_rule({ match = { class = "^(Spotify)$" }, opaque = true })
hl.window_rule({ match = { class = "^(steam)$" }, opaque = true })
hl.window_rule({ match = { class = "^(vesktop)$" }, opaque = true })

-- Layer rules (Liquid Glass blur + ignorealpha for razor-sharp text)
hl.layer_rule({ match = { namespace = "^(quickshell)$" }, blur = true, ignore_alpha = 0.25 })
hl.layer_rule({ match = { namespace = "^(rofi)$" }, blur = true, ignore_alpha = 0.25 })
hl.layer_rule({ match = { namespace = "^(swaync-control-center)$" }, blur = true, ignore_alpha = 0.25 })
hl.layer_rule({ match = { namespace = "^(swaync-notification-window)$" }, blur = true, ignore_alpha = 0.25 })
hl.layer_rule({ match = { namespace = "^(swayosd)$" }, blur = true, ignore_alpha = 0.25 })

-- Drop-down scratchpad terminal (F12)
hl.window_rule({
    match = { class = "^(ghostty[.-]scratchpad)$" },
    float = true,
    workspace = "special:scratchpad",
    size = "80% 50%",
    move = "10% 5%",
    rounding = 16,
    animation = "slide top",
})
