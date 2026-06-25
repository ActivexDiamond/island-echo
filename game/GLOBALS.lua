DEBUG = {
--	INITIAL_SCENE = require("core.Game").ESceneIds.HIGH_SCORES,
	SKIP_LOGOS = false,
	DEV_MODE = true,
	SHOW_DEBUG_MENU_ON_BOOT = false,

	SHOW_LOVE_VERSION = true,
	SHOW_FPS = true,

	
	DISABLE_SHADERS = true,

	MUTE_AUDIO = false,

	DISABLE_HUD = false,

}

--FIXME: Move default font size to a datapack.
GLOBAL ={
	FONT_SIZE = 20,
}

SFX = {
}

local os = love.system.getOS()
if os == "Web" or os == "Android" then
	DEBUG.DEV_MODE = false
	DEBUG.SKIP_LOGOS = false
	DEBUG.INITIAL_SCENE = nil
	DEBUG.MUTE_AUDIO = false
	DEBUG.SHOW_DEBUG_MENU_ON_BOOT = false
end
if os == 'Web' then
	DEBUG.DISABLE_SHADERS = false
end
if os == "Android" then
	DEBUG.DISABLE_SHADERS = true
end


if DEBUG.MUTE_AUDIO then
	love.audio.setVolume(0)
end
