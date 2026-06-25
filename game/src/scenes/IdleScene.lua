local middleclass = require "libs.middleclass"
local Scene = require "cat-paw-mods.Scene"

--============================ Helper Methods ==============================

--============================ Constructor ==============================
---@class IdleScene : Scene
---@overload fun(): self
local IdleScene = middleclass("IdleScene", Scene)
	
function IdleScene:initialize()
	Scene.initialize(self)
end

--============================ Core API ==============================
function IdleScene:update(dt)
	Scene.update(self, dt)
end

function IdleScene:draw(g2d)
	Scene.draw(self, g2d)
end

--============================ API ==============================

--============================ Internals ==============================

--============================ Getters / Setters ==============================

return IdleScene
