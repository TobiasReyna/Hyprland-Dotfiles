-- Importar colores generados por Matugen
local ok, colors = pcall(require, "colors")
if not ok then
	colors = {
		primary = "rgba(89b4faff)",
		secondary = "rgba(cba6f7ff)",
		surface = "rgba(313244ff)",
	}
end

-- Monitor (Automático / 1920x1200@144Hz en tu laptop)
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
})

-- Autostart (Demonios al iniciar Hyprland)
hl.on("hyprland.start", function()
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("quickshell")
end)

-- Configuración General, Decoración y Teclado
hl.config({
	input = {
		kb_layout = "latam",
		follow_mouse = 1,
		touchpad = {
			natural_scroll = true,
		},
	},
	general = {
		gaps_in = 6,
		gaps_out = 12,
		border_size = 2,
		col = {
			active_border = { colors = { colors.primary, colors.secondary }, angle = 45 },
			inactive_border = colors.surface,
		},
		layout = "dwindle",
	},
	decoration = {
		rounding = 14,
		active_opacity = 1.0,
		inactive_opacity = 0.94,
		blur = {
			enabled = true,
			size = 6,
			passes = 3,
			new_optimizations = true,
			ignore_opacity = true,
		},
		shadow = {
			enabled = true,
			range = 18,
			render_power = 3,
			color = "rgba(00000066)",
		},
	},
})

-- Curvas Bézier y Animaciones
hl.curve("fluent_decel", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("easeOutExpo", { type = "bezier", points = { { 0.16, 1.0 }, { 0.3, 1.0 } } })
hl.curve("softSnap", { type = "bezier", points = { { 0.4, 0.0 }, { 0.2, 1.0 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "fluent_decel", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "easeOutExpo", style = "popin 80%" })
hl.animation({ leaf = "fade", enabled = true, speed = 5, bezier = "softSnap" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "easeOutExpo", style = "slide" })

-- Variables y Atajos de Teclado
local mainMod = "SUPER"
local terminal = "ghostty"
local browser = "firefox"
local launcher = "rofi -show drun -theme ~/.config/rofi/launcher.rasi"
local wallSelector = "~/.config/hypr/scripts/wallpaper-selector.sh"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(launcher))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(wallSelector))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))

-- Espacios de trabajo (SUPER + 1..0 para cambiar, SUPER + SHIFT + 1..0 para mover ventana)
for i = 1, 10 do
	local key = i % 10 -- El 10 se asigna a la tecla 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Mover y redimensionar ventanas con el mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
