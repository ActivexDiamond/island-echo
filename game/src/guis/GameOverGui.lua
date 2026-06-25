local middleclass = require "libs.middleclass"
local BaseGui = require "guis.BaseGui"

--============================ Helper Methods ==============================

--============================ Constructor ==============================
---@class GameOverGui : BaseGui
---@overload fun(): self
local GameOverGui = middleclass("GameOverGui", BaseGui)
	
function GameOverGui:initialize()
	BaseGui.initialize(self)
	
end

--============================ Core API ==============================
function GameOverGui:update(dt)
	BaseGui.update(self, dt)
end

function GameOverGui:draw(g2d)
	BaseGui.draw(self, g2d)
end

--============================ API ==============================

--============================ Internals ==============================

--============================ Getters / Setters ==============================

return GameOverGui
