-- --- Modular Hyprland Entry Point (Lua) ---
local config_dir = os.getenv("HOME") .. "/.config/hypr"
package.path = config_dir .. "/?.lua;" .. config_dir .. "/?/init.lua;" .. package.path

require("lua.env")
require("lua.monitors")
require("lua.autostart")
require("lua.input")
require("lua.look")
require("lua.animations")
require("lua.rules")
require("lua.binds")

-- HyprMod managed settings
require("hyprland-gui")
