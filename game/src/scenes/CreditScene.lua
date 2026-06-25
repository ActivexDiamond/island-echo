local middleclass = require "libs.middleclass"
local Scene = require "cat-paw-mods.Scene"

local CreditGui = require "guis.CreditGui"

--============================ Helper Methods ==============================

--============================ Constructor ==============================
---@class CreditScene : Scene
---@overload fun(): self
local CreditScene = middleclass("CreditScene", Scene)
	
function CreditScene:initialize()
	Scene.initialize(self)
	self:addObject(CreditGui())
end

--============================ Core API ==============================
function CreditScene:update(dt)
	Scene.update(self, dt)
end

function CreditScene:draw(g2d)
	Scene.draw(self, g2d)
end

--============================ API ==============================

--============================ Internals ==============================

--============================ Getters / Setters ==============================

return CreditScene
