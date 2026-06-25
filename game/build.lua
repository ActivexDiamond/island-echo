return {
  -- basic settings:
  name = 'Serious Jam', -- name of the game for your executable
  developer = [[
- Development & Game Design: Dulfiqar 'Active Diamond' H. Al-Safi
- Art & Game Design:         Vick
- Music & SFX:               ___
]]
  output = 'dist', -- output location for your game, defaults to $SAVE_DIRECTORY
  version = '0.1.0', -- 'version' of your game, used to name the folder in output
  love = '11.5', -- version of LÖVE to use, must match github releases
  ignore = {'dist', 'ignoreme.txt'}, -- folders/files to ignore in your project
  icon = 'icon.png', -- 256x256px PNG icon for game, will be converted for you

  -- optional settings:
  use32bit = true, -- set true to build windows 32-bit as well as 64-bit
--  platforms = {'windows', 'macos', 'linux'} -- set if you only want to build for a specific platform
}
