local middleclass = require "libs.middleclass"

local EventSystem = require "cat-paw.core.patterns.event.EventSystem"
local EvWindowResize = require "cat-paw.core.patterns.event.os.EvWindowResize"
local EvMousePress = require "cat-paw.core.patterns.event.mouse.EvMousePress"
local EvFileChange = require "cat-paw.core.patterns.event.dev.EvFileChange"
local DataRegistry = require "core.DataRegistry"
local uColor = require "cat-paw.core.utilities.uColor"


--============================ Helper Methods ==============================

--============================ Constructor ==============================
---@class BaseGui
---@overload fun(id: string?): self
local BaseGui = middleclass("BaseGui")

---@param id string? If an ID is provided, it will be used by the DataRegistry to inject stats into the GUI.
function BaseGui:initialize(id)
	GAME:getEventSystem():attach(self, EventSystem.ATTACH_TO_ALL)
	
	if id then
		self.ID = id
		DataRegistry:applyStats(self)
	end

	self.windowW, self.windowH = nil, nil
	self.centerX, self.centerY = nil, nil
--	self.leastRadius = nil
	self:_computeWindowMargins()

	self.buttons = {}
end

--============================ Core API ==============================

function BaseGui:update(dt)
	if self.popup and self.popup.timeout ~= -1 then
		if love.timer.getTime() - self.popup.startTime > self.popup.timeout then
			self.popup = nil
		end
	end

	for _, b in pairs(self.buttons) do
		b.gotPressed = b.gotPressed - 1
	end
end

function BaseGui:draw(g2d)
end

--============================ API ==============================

function BaseGui:_addPopup(text, timeout, callback, ...)
	self.popup = {
		str = {{1, 1, 1}, text},
		onPress = callback,
		args = {...},
		timeout = timeout or -1,
		startTime = love.timer.getTime()
	}

	--Defaults
	self.popup.x = 50
	self.popup.y = 50
	self.popup.h = GAME:getThemeManager():getFont():getAscent() * 2
	self.popup.w = self.windowW - self.windowW * (self.PAD_X_FACTOR or 1)
	self.popup.thickness = 1
	self.popup.roundness = 0
	self.popup.align = 'center'
end


function BaseGui:_addButton(id, textColor, text, callback, ...)
	local b= {x = 0, y = 0, w = 0, h = 0,
		str = {textColor, text},
		onPress = callback,
		args = {...},
	}

	--Defaults
	b.x = 50
	b.y = 50
	b.h = GAME:getThemeManager():getFont():getAscent() * 2
	local w = GAME:getThemeManager():getFont():getWidth(text)
	b.w = w + w * (self.PAD_X_FACTOR or 1)
	b.thickness = 1
	b.roundness = 0
	b.xPad = 0
	b.gotPressed = 0
	b.align = 'center'
	b.isMultiline = false

	self.buttons[id] = b
	self:_computeMultilineHeight(id)
end


function BaseGui:_recomputeButton(id, x, y, w, h, thickness, roundness, xPad)
	local b = self.buttons[id]
	b.x = x or b.x
	b.y = y or b.y
	b.w = w or b.w
	b.h = h or b.h
	b.thickness = thickness or b.thickness
	b.roundness = roundness or b.roundness
	b.xPad = xPad or b.xPad

	self:_computeMultilineHeight(id)
end

function BaseGui:_updateText(id, text, color)
	local b = self.buttons[id]
	b.str[1] = color or b.str[1]
	b.str[2] = text or b.str[2]

	self:_computeMultilineHeight(id)
end

function BaseGui:_updateCallback(id, callback, ...)
	self.buttons[id].onPress = callback or self.buttons[id].onPress
	self.buttons[id].args = {...} or self.buttons[id].args
end

function BaseGui:_computeMultilineHeight(id)
	local b = self.buttons[id]
	local _, wrappedText = GAME:getThemeManager():getFont():getWrap(b.str[2], b.w)
	if #wrappedText > 1 then
		b.isMultiline = true
		local lineH = GAME:getThemeManager():getFont():getAscent() * 1.6
		local newH = lineH * #wrappedText
		if newH > b.h then
			b.h = newH
		end
	else
		b.isMultiline = false
	end

end

function BaseGui:drawButton(g2d, id, fillColor, lineColor)
	local b = self.buttons[id]
	local tm = GAME:getThemeManager()
	g2d.push('all')
		g2d.setLineWidth(b.thickness)
		if b.gotPressed <= 0 then
			g2d.setColor(fillColor or tm:getSecondaryColor())
		else
			local r, g, b = unpack(fillColor or tm:getSecondaryColor())
			g2d.setColor(uColor.blendRgb(0.75, r, g, b, 0, 0, 0))
		end

		g2d.rectangle('fill', b.x - b.xPad / 4, b.y, b.w + b.xPad / 2, b.h, b.roundness)
		g2d.setColor(lineColor or tm:getPrimaryColor())
		g2d.rectangle('line', b.x - b.xPad / 4 ,b.y, b.w + b.xPad / 2, b.h, b.roundness)
	
		g2d.setColor(tm:getTextColor())
		local Y_MUL = b.isMultiline and 5 or 2
		local y;	
		if b.isMultiline then
			y = (b.y + b.h / 1.8)
			local lineH = tm:getFont():getAscent() * 1.6 
			local _, wrappedText = tm:getFont():getWrap(b.str[2], b.w)
			for i = 1, #wrappedText do
				y = y - lineH / 2
			end
		else
			y = (b.y + b.h / 2) - tm:getFont():getAscent() / 1.6 - b.thickness
		end
		local x = b.x
		if b.__left_pad__ then x = x + b.__left_pad__ end
		g2d.printf(b.str, x, y, b.w, b.align)
	g2d.pop()
end

function BaseGui:drawPopup(g2d)
	local p = self.popup
	if not p then return end
	local tm = GAME:getThemeManager()

	p.w = self.windowW - self.windowW * (self.PAD_X_FACTOR or 1)
	
	local lineH = GAME:getThemeManager():getFont():getAscent() * 2
	local TEXT_PAD = 16
	local _, wrappedText = GAME:getThemeManager():getFont():getWrap(p.str[2], p.w - TEXT_PAD)
	p.h = lineH * #wrappedText

	p.x = self.centerX - p.w/2
	p.y = self.centerY - p.h/2
	p.thickness = tm:getHighScoresBorderThickness()
	p.roundness = tm:getHighScoresBorderRoundness()

	g2d.push('all')
		g2d.setColor(0, 0, 0, 0.4)
		g2d.rectangle('fill', 0, 0, g2d.getDimensions())
		g2d.setLineWidth(p.thickness)
		g2d.setColor(tm:getSecondaryColor())
		g2d.rectangle('fill', p.x ,p.y, p.w, p.h, p.roundness)
		g2d.setColor(tm:getPrimaryColor())
		g2d.rectangle('line', p.x ,p.y, p.w, p.h, p.roundness)
	
		g2d.setColor(tm:getTextColor())
		local y = (p.y + p.h / (2 * #wrappedText)) - tm:getFont():getAscent() / 1.8 - p.thickness
		local x = p.x
		g2d.printf(p.str, x + TEXT_PAD/2, y, p.w - TEXT_PAD, p.align)
	g2d.pop()
end


--============================ Callbacks ==============================

function BaseGui:onSceneEnter(from)
	self:_computeWindowMargins()
end
BaseGui[EvMousePress] = function(self, e)
	--FIXME: This no longer works, not with my trivia setup.
--	if not GAME:getCurrentState():hasObject(self) then return end

	--Buttons are ignored if there's a popup. If a popup has a callback, call it and remove the popup.
	--Otherwise, the popup must be removed externally or times out.
	if self.popup then
		local p = self.popup
		if e.x < p.x + p.w
				and p.x < e.x 
				and e.y < p.y + p.h
				and p.y < e.y then
			if p.onPress then 
				p.onPress(unpack(p.args))
				self.popup = nil
			end
		end
		return
	end
	for _, b in pairs(self.buttons) do
		if e.x < (b.x - b.xPad / 4) + (b.w + b.xPad / 2)
				and (b.x - b.xPad / 4) < e.x 
				and e.y < b.y + b.h
				and b.y < e.y then
			b.onPress(unpack(b.args))
			b.gotPressed = 10
		end
	end
end
BaseGui[EvWindowResize] = function(self, e)
	if not GAME:getCurrentState():hasObject(self) then return end
	self:_computeWindowMargins(e.w, e.h)
end

BaseGui[EvFileChange] = function(self, e)
	if not GAME:getCurrentState():hasObject(self) then return end
	if self.ID then
		DataRegistry:loadData()
		DataRegistry:applyStats(self)
	end
	self:_computeWindowMargins()
end

--============================ Internals ==============================
function BaseGui:_computeWindowMargins(w, h)
	if not w or not h then
		w, h = love.window.getMode()
	end
	self.windowW, self.windowH = w, h
	self.centerX = self.windowW / 2 
	self.centerY = self.windowH / 2
--	self.leastAxis = math.min(w, h)
end

--============================ Getters / Setters ==============================

return BaseGui
