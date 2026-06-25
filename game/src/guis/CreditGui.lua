local middleclass = require "libs.middleclass"
local BaseGui = require "guis.BaseGui"

--============================ Helper Methods ==============================

--============================ Constructor ==============================
---@class CreditGui : BaseGui
---@overload fun(): self
local CreditGui = middleclass("CreditGui", BaseGui)
	
function CreditGui:initialize()
	BaseGui.initialize(self)
	
end

--============================ Core API ==============================
function CreditGui:update(dt)
	BaseGui.update(self, dt)
end

function CreditGui:draw(g2d)
	BaseGui.draw(self, g2d)
end

--============================ API ==============================

--============================ Internals ==============================

--============================ Getters / Setters ==============================

return CreditGui
