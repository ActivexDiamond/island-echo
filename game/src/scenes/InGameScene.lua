local middleclass = require "libs.middleclass"

local Scene = require "cat-paw-mods.Scene"
local EvFileChange = require "cat-paw.core.patterns.event.dev.EvFileChange"
local EvKeyPress = require "cat-paw.core.patterns.event.keyboard.EvKeyPress"

--============================ Helper Methods ==============================

--============================ Constructor ==============================
---@class InGameScene : Scene
---@field GAME_CLASSES ArcadeGameBase[] 
---@overload fun(): self
local InGameScene = middleclass("InGameScene", Scene)
	
function InGameScene:initialize()
	Scene.initialize(self)
end

--============================ Constants ==============================

--============================ Core API ==============================

function InGameScene:update(dt)
	Scene.update(self, dt)
end

function InGameScene:draw(g2d)
	Scene.draw(self, g2d)
end

--============================ API ==============================

--============================ Callbacks ==============================

InGameScene[EvFileChange] = function(self, e)
	if self.fsm:getCurrentState() ~= self then return end
end

--============================ Internals ==============================

--============================ Getters / Setters ==============================

return InGameScene
