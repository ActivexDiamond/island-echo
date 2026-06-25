local middleclass = require "libs.middleclass"

local AbstractGame = require "cat-paw.engine.AbstractGame"

local LogosScene = require "scenes.LogosScene"
local InGameScene = require "scenes.InGameScene"
local GameOverScene = require "scenes.GameOverScene"
local CreditScene = require "scenes.CreditScene"
local IdleScene = require "scenes.IdleScene"

local EventSystem = require "cat-paw.core.patterns.event.EventSystem"
local EvWindowResize = require "cat-paw.core.patterns.event.os.EvWindowResize"
local EvMousePress = require "cat-paw.core.patterns.event.mouse.EvMousePress"
local EvKeyPress = require "cat-paw.core.patterns.event.keyboard.EvKeyPress"

local DebugMenu = require "core.DebugMenu"

local moonshine = require "libs.moonshine"
local shack = require "libs.shack"

------------------------------ Defaults ------------------------------

DEFAULT_SHADERS = {
	{id = "crt", distortionFactor = {1.03, 1.05}, scaleFactor = 1, feather = 0.05},
	{id = "filmgrain", opacity = 0.7, size = 3},
	{id = "glow", strength = 7},
}

------------------------------ Constructor ------------------------------

---@class Game : AbstractGame
---@overload fun(title: string, targetWindowW: number, targetWindowH: number): self
local Game = middleclass("Game", AbstractGame)

function Game:initialize(...)
	AbstractGame.initialize(self, ...)
	math.randomseed(os.time())
	self:_loadAllAssets()
	
	self:getEventSystem():attach(self, EventSystem.ATTACH_TO_ALL)

	self.SCALE = 1
	self.windowW = self.windowW / self.SCALE
	self.windowH = self.windowH / self.SCALE  
	
	GAME = self

	self.shaders = nil
	self:_setupShaders()
	self.showDebugMenu = DEBUG.SHOW_DEBUG_MENU_ON_BOOT
	self.debugMenu = DebugMenu()

	self:add(Game.ESceneIds.LOGOS, LogosScene())
	self:add(Game.ESceneIds.IN_GAME, InGameScene())
	self:add(Game.ESceneIds.GAME_OVER, GameOverScene())
	self:add(Game.ESceneIds.CREDIT, CreditScene())
	self:add(Game.ESceneIds.IDLE, IdleScene())
	
	if DEBUG and DEBUG.INITIAL_SCENE then
		self:goTo(DEBUG.INITIAL_SCENE)
	else
		self:goTo(self.ESceneIds.LOGOS)
	end

	--Temp fix for resizing event sometimes not getting called early on, in Android and Web builds.
	local w, h = love.window.getMode()
	self.eventSystem:queue(EvWindowResize(w, h))
end

function Game:goTo(...)
	AbstractGame.goTo(self, ...)
	local w, h = love.graphics.getDimensions()
	self:getEventSystem():queue(EvWindowResize(w, h))
end

------------------------------ Constants ------------------------------
Game.ESceneIds = {
	LOGOS = 1,
	IN_GAME = 2,
	GAME_OVER = 3,
	CREDIT = 4,
	IDLE = 6,
}

------------------------------ Core API ------------------------------
function Game:update(dt)
	AbstractGame.update(self, dt)
	shack:update(dt)
	if self.showDebugMenu then self.debugMenu:update(dt) end
end

local function normalDraw(self)
	local g2d = love.graphics
	shack:apply()
	AbstractGame.draw(self)
end

--tmp var
local showInfo = DEBUG.SHOW_FPS

local function drawHud(self)
	local g2d = love.graphics
	g2d.push('all')
		if DEBUG.SHOW_LOVE_VERSION then
			g2d.setColor(1, 1, 1)
		    local major, minor, revision, codename = love.getVersion()
		    local str = string.format("Version %d.%d.%d - %s", major, minor, revision, codename)
			local x = g2d.getWidth() - g2d.getFont():getWidth(str) - 5
		    g2d.print(str, x, 20)
		end
		if DEBUG.SHOW_FPS then
			g2d.setColor(1, 1, 1)
			g2d.print("FPS: " .. love.timer.getFPS(), g2d.getWidth() - 50, 40)	
		end
	g2d.pop()
end

function Game:draw()
	if not DEBUG.DISABLE_SHADERS then
		self.shaders.draw(normalDraw, self)
	else
		normalDraw(self)
	end
	if not DEBUG.DISABLE_HUD then drawHud(self) end
	if self.showDebugMenu then self.debugMenu:draw(love.graphics) end
end

--============================ Callbacks ==============================
Game[EvKeyPress] = function(self, e)
	if self.showDebugMenu then return end

	if e.key == "s" then 
		DEBUG.DISABLE_SHADERS = not DEBUG.DISABLE_SHADERS 
	elseif e.key == 'd' then
--		self.showDebugMenu = not self.showDebugMenu
	elseif e.key == 'escape' then
		love.event.quit()
	end
end

Game[EvWindowResize] = function(self, e)
	if self.shaders then self.shaders.resize(e.w, e.h) end
end

------------------------------ Internals ------------------------------
function Game:_loadAllAssets()
	local tAll, tData, tInv, tObj, tGui
	local time = love.timer.getTime
	
	tAll = time() 
	local DataRegistry = require "core.DataRegistry"
	print "------------------------------ Loading Data... ------------------------------"
		tData = time(); DataRegistry:loadData(); tData = time() - tData
	print "Done!\n"
		
	local AssetRegistry = require "core.AssetRegistry"
	print "------------------------------ Loading Sprites (inv)... ------------------------------"
	tInv = time(); AssetRegistry:loadSprInv(); tInv = time() - tInv
	
	print "------------------------------ Loading Sprites (obj)... ------------------------------"
	tObj = time(); AssetRegistry:loadSprObj(); tObj = time() - tObj
	
	print "------------------------------ Loading Sprites (gui)... ------------------------------"
		tGui = time(); AssetRegistry:loadSprGui(); tGui = time() - tGui
	print "Done!"
	tAll = time() - tAll
	
local str = string.format([[
------------------------------------------------------------
	Loading dat took: %.2fms
	Loading Inv took: %.2fms
	Loading Obj took: %.2fms
	Loading Gui took: %.2fms
	>Total load-time: %.4fs
------------------------------------------------------------
	]], tData*1e3, tInv*1e3, tObj*1e3, tGui*1e3, tAll)
	print(str)
end

function Game:_setupShaders()
	for k, shader in ipairs(DEFAULT_SHADERS) do
		local id = shader.id
		if k == 1 then 
			self.shaders = moonshine(moonshine.effects[id]) 
		else
			self.shaders.chain(moonshine.effects[id])
		end
		for paramName, paramVal in pairs(DEFAULT_SHADERS[k]) do
			if paramName ~= "id" then
				self.shaders[id][paramName] = paramVal
			end
		end
	end
end
--============================ Getters / Setters ==============================

return Game
