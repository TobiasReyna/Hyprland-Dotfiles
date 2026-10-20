hl.config({ animations = { enabled = true } })

hl.curve("fluent_decel", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("easeOutExpo", { type = "bezier", points = { { 0.16, 1.0 }, { 0.3, 1.0 } } })
hl.curve("softSnap", { type = "bezier", points = { { 0.4, 0.0 }, { 0.2, 1.0 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "fluent_decel", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "easeOutExpo", style = "popin 80%" })
hl.animation({ leaf = "fade", enabled = true, speed = 5, bezier = "softSnap" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "easeOutExpo", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "easeOutExpo", style = "slidefadevert -100%" })
