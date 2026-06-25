local middleclass = require "libs.middleclass"
local suit = require "libs.suit"
local DataRegistry = require "core.DataRegistry"

local EventSystem = require "cat-paw.core.patterns.event.EventSystem"
local EvKeyPress = require "cat-paw.core.patterns.event.keyboard.EvKeyPress"
local EvTextInput = require "cat-paw.core.patterns.event.keyboard.EvTextInput"

local uColor = require "cat-paw.core.utilities.uColor"

local colorStrings = {
	BACKGROUND_COLOR_1 =   "#136588ff",
	BACKGROUND_COLOR_2 =   "#a01040ff",
	
	PRIMARY_COLOR =        "#26A9E0ff",
	SECONDARY_COLOR =      "#EA316Eff",
	AUXILIARY_COLOR =      "#99003dff",
	
	TEXT_COLOR =           "#222222",
	HIGHLIGHT_TEXT_COLOR = "#25B786",

	SHADOW_COLOR =         "#4c4c4c",
	OUTLINE_COLOR =        "#760c2eff",
}

local fromHex = uColor.fromHex
local devThemeData = {"dev_theme",
	THEME_ID = "dev",
	LOGO_ID = "dev_logo",
	LOGO_SCALE = 0.7,
	DRAW_LOGO = true,
	
	BACKGROUND_COLOR_1 = {fromHex(colorStrings.BACKGROUND_COLOR_1)},
	BACKGROUND_COLOR_2 = {fromHex(colorStrings.BACKGROUND_COLOR_2)},
	
	PRIMARY_COLOR = {fromHex(colorStrings.PRIMARY_COLOR)},
	SECONDARY_COLOR = {fromHex(colorStrings.SECONDARY_COLOR)},
	AUXILIARY_COLOR = {fromHex(colorStrings.AUXILIARY_COLOR)},
	
	TEXT_COLOR = {fromHex(colorStrings.TEXT_COLOR)},
	HIGHLIGHT_TEXT_COLOR = {fromHex(colorStrings.HIGHLIGHT_TEXT_COLOR)},
	FONT_ID = "RobotoMono-VariableFont_wght.ttf",
	IS_PIXEL_FONT = false,
	FONT_SIZE = 28,

	BACKGROUND_TYPE = "image",

	BACKGROUND_ID = "dev_background",
	BACKGROUND_ALLOW_STRETCH = true,
	BACKGROUND_X_SCALE = 1.1,
	BACKGROUND_Y_SCALE = 1.25,
	BACKGROUND_X_OFFSET = -0.08,
	BACKGROUND_Y_OFFSET = -0.2,

	HIGH_SCORES_BORDER_THICKNESS = 4,
	HIGH_SCORES_BORDER_ROUNDNESS = 25,

	SHADOW_COLOR = {fromHex(colorStrings.SHADOW_COLOR)},
	OUTLINE_COLOR = {fromHex(colorStrings.OUTLINE_COLOR)},

	SHADERS = {
		{id = "glow", strength = 4, min_luma = 0.999},
		{id = "godsray", light_x = 5, light_y = 2, weight=0.1, density = 0.1, exposure=0.15, decay = 0.98},
		{id = "colorgradesimple", factors = {0.8, 0.8, 0.85}}
	},

	GAME_X_OFFSET = 0,--0.32,
	GAME_Y_OFFSET = 0,--0.26,
	GAME_SCALE_FACTOR = 1,--0.4,
	
	SPRITES = {
		tic = {id = "tic"},
		tac = {id = "tac"},
		mem1  = {id = "mem1"}, 
		mem2  = {id = "mem2"}, 
		mem3  = {id = "mem3"}, 
		mem4  = {id = "mem4"}, 
		mem5  = {id = "mem5"}, 
		mem6  = {id = "mem6"}, 
		mem7  = {id = "mem7"}, 
		mem8  = {id = "mem8"}, 
		mem9  = {id = "mem9"}, 
		mem10 = {id = "mem10"}, 
		mem11 = {id = "mem11"}, 
		mem12 = {id = "mem12"}, 
		center= {id = "center"}, 
		cover = {id = "cover"}, 
	},
}

local dtd = devThemeData

--============================ Helper Methods ==============================
local function bind(val, min, max)
	return math.max(min, math.min(val, max))
end

local function capitalizeWord(str)
    return str:sub(1,1):upper() .. str:sub(2)
end
local function capitalizeString(str)
    return str:gsub("%a[^%s]*", capitalizeWord)
end

local function keyToDisplayName(str)
	str = str:lower()
	str = str:gsub("_", " ")
	str = capitalizeString(str)
	return str
end

local colorPickerMutableVals = {}
local function colorPicker(target, key, textW, textH, label)
	textW = textW or 125
	textH = textH or 25
	label = label or keyToDisplayName(key)

	local input = colorPickerMutableVals[key]
	if not input then
		input = {text = colorStrings[key]}
		colorPickerMutableVals[key] = input
	end
	local gotHit = false

	suit.Label(label, suit.layout:col(textW, textH))
	if suit.Input(input, suit.layout:col(textW, textH)).submitted then
		local str = input.text
		local r, g, b, a = uColor.fromHex(str)
		--If set to an invalid color, reset to the last valid one.
		if r then
			--Clean the string up.
			if str:sub(1, 1) ~= "#" then str = "#" .. str end
	--		if #str == 7 then str = str .. "ff" end
			--Update the last valid string, update the color-table in themeData, and issue a theme updat.
			colorStrings[key] = str
			dtd[key] = {r, g, b, a}
			gotHit = true
		end
		--Update the display text. If str was invalid, will revert back to the last valid one.
			input.text = colorStrings[key]
	end
	return gotHit
end

local function stepper(label, target, key, opts)
	--Default opts.
	opts = opts or {}
	local step = opts.step or 1
	--`bigStep` defaults to step*5, but can be disabled by setting it to `false`.
	local bigStep = (opts.bigStep == nil) and step * 5 or false
	local min = opts.min or -math.huge
	local max = opts.max or math.huge
	
	--Keep track of hit amount and drection, if any.
	local hit = 0

	--Sizing vars used for the layout.
	local tmp = 25
	local labelW, labelH = 125, tmp
	local buttonW, buttonH = tmp, tmp
	local valW, valH = 50, tmp
	
	suit.Label(label, suit.layout:col(labelW, labelH))
	if bigStep then
		if suit.Button("++", {id = label .. "++"}, suit.layout:col(buttonW, buttonH)).hit then
			hit = hit + bigStep
		end
	else
		suit.layout:col(buttonW, buttonH)
	end

	if suit.Button("+", {id = label .. "+"}, suit.layout:col(buttonW, buttonH)).hit then
		hit = hit + step
	end

	suit.Label(target[key], suit.layout:col(valW, valH))

	if suit.Button("-", {id = label .. "-"}, suit.layout:col(buttonW, buttonH)).hit then
		hit = hit - step
	end
	if bigStep then
		if suit.Button("--", {id = label .. "--"}, suit.layout:col(buttonW, buttonH)).hit then
			hit = hit - bigStep
		end
	else
		suit.layout:col(buttonW, buttonH)
	end

	target[key] = bind(target[key] + hit, min, max)
	return hit ~= 0
end

local function filePickerCallback(files, filterName, errorString)
	if #files == 0 then
		print("No files were selected.")
		return false
	end
	local succ, imageFile = pcall(love.filesystem.openNativeFile, files[1], 'r')    ---@diagnostic disable-line: undefined-field
	if not succ then
		print("Failed to open the selected file.")
		return false
	end
	local image
	succ, image = pcall(love.graphics.newImage, imageFile)
	if not succ then
		print("Got and read the file, but failed to load an image from it.")
		return false
	end
	return image
end

local function imagePicker(self, target, key, label, textW, textH)
	label = label or "Choose Image"
	textW = textW or 125
	textH = textH or 25

	suit.Label(label, suit.layout:col(textW, textH))
	if suit.Button("BROWSE", {id = target}, suit.layout:col(textW, textH)).hit then
		love.window.showFileDialog('openfile', function(...)    ---@diagnostic disable-line: undefined-field
			local img = filePickerCallback(...)
			if img then
				target[key] = img
				self:_updateTheme()
			end
		end, {filters = {Images = "png;jpg;jpeg"}})
	end
end

--============================ Constructor ==============================

---@class DebugMenu
---@overload fun(): self
local DebugMenu = middleclass("DebugMenu")

function DebugMenu:initialize()
	GAME:getEventSystem():attach(self, EventSystem.ATTACH_TO_ALL)
	DataRegistry:loadDatumInPlace(devThemeData)

	self.tabs = {
		Main = {
		},
		Colors = {
		},
		Background = {
			types = {"perlin", "image"},
			typeAt = 1
		},
		Sprites = {
		},
	}
	self.active = true 
	self.activeTab = "Main"
	self.padX = 5
	self.padY = 5
	self.debugMenuY = 70

	self.line = 0
	self.lineH = 25

	self.lastPrint = 0
	self.printCooldown = 2

	self.backgroundW = 0
	self.backgroundH = 0
end

--============================ Core API ==============================
function DebugMenu:update(dt)
	if not self.active then return end
	self.line = 0

	--Draw tab-header.
	self:_TabSelector(dt)
	local tabId = ("_%sTab"):format(self.activeTab)
	
	self.backgroundW, _ = suit.layout:nextCol()

	self:_nextLine()
	--Draw the active tab.
	self[tabId](self, dt)

	_, self.backgroundH = suit.layout:nextRow()
	self.backgroundH = self.backgroundH - 40
end

function DebugMenu:draw(g2d)
	if not self.active then return end

	if self.backgroundW >= 1 and self.backgroundH >= 1 then
		g2d.push('all')
			g2d.setColor(0.3, 0.3, 0.3, 0.9)
			g2d.rectangle('fill', 0, self.debugMenuY, self.backgroundW, self.backgroundH)
		g2d.pop()
	end

	suit.draw()
end

--============================ Callbacks ==============================
DebugMenu[EvTextInput] = function(self, e)
	suit.textinput(e.char)
end

DebugMenu[EvKeyPress] = function(self, e)
	suit.keypressed(e.key)
end

--============================ Internals ==============================

function DebugMenu:_updateTheme()
	local tm = GAME:getThemeManager()
	DataRegistry:loadDatumInPlace(devThemeData)
	local themeData = {ID = "dev_theme"}
	DataRegistry:applyStats(themeData)
	--FIXME: Dynamically read the numeric-ID of `dev_theme`.
	tm.themeData[1] = themeData
	print("setting theme to: " .. "dev_theme")
	print(tm:setTheme("dev_theme"))
end


function DebugMenu:_nextLine()
	local h = self.debugMenuY + self.line * self.lineH * 1.1
	suit.layout:reset(0, h, self.padX, self.padY)
	self.line = self.line + 1
end

function DebugMenu:_TabSelector(dt)
	self:_nextLine()
	local w, h = 80, 40
	if suit.Button("Main", suit.layout:col(w, h)).hit then
		self.activeTab = "Main"
	end
	if suit.Button("Colors", suit.layout:col(w, h)).hit then
		self.activeTab = "Colors"
	end
--	if suit.Button("Font", suit.layout:col(w, h)).hit then
--		self.activeTab = "Font"
--	end
	if suit.Button("Background", suit.layout:col(w, h)).hit then
		self.activeTab = "Background"
	end

--	self:_nextLine()
--	self:_nextLine()
--	if suit.Button("Borders", suit.layout:col(w, h)).hit then
--		self.activeTab = "Borders"
--	end

	if suit.Button("Sprites", suit.layout:col(w, h)).hit then
		self.activeTab = "Sprites"
	end
end

local cbDrawLogo = {text = "Show Logo"}
local cbDrawShaders = {text = "Show VFX"}
local cbIsPixelFont = {text = "Sharp Font"}
function DebugMenu:_MainTab(dt)
	self:_nextLine()

	local textW, textH = 125, 25
	local checkboxW = 100
	local gotHit = false

	cbDrawLogo.checked = dtd.DRAW_LOGO
	--Show logo.
	if suit.Checkbox(cbDrawLogo, suit.layout:col(checkboxW, textH)).hit then
		dtd.DRAW_LOGO = not dtd.DRAW_LOGO
		gotHit = true
	end
	cbDrawShaders.checked = not DEBUG.DISABLE_SHADERS
	
	--Show shaders.
	if suit.Checkbox(cbDrawShaders, suit.layout:col(checkboxW, textH)).hit then
		DEBUG.DISABLE_SHADERS = not DEBUG.DISABLE_SHADERS
		gotHit = true
	end

	--Is pixel font.
	cbIsPixelFont.checked = dtd.IS_PIXEL_FONT
	if suit.Checkbox(cbIsPixelFont, suit.layout:col(checkboxW, textH)).hit then
		dtd.IS_PIXEL_FONT = not dtd.IS_PIXEL_FONT
		gotHit = true
	end
	self:_nextLine()

	--Logo scale.
	gotHit = stepper("Logo Scale", dtd, "LOGO_SCALE", {step = 0.05, min = 0.1}) or gotHit
	self:_nextLine()
	
	--Font size..
	gotHit = stepper("Font Size", dtd, "FONT_SIZE", {step = 1, min = 1, max = 80}) or gotHit
	self:_nextLine()

	--Logo path.
	imagePicker(self, dtd, "LOGO_ID", "Choose Logo")
	self:_nextLine()

	--Game scale.
	gotHit = stepper("Game X-Offset", dtd, "GAME_X_OFFSET",
			{step = 0.01, min = -3, max = 3}) or gotHit
	self:_nextLine()

	gotHit = stepper("Game Y-Offset", dtd, "GAME_Y_OFFSET",
			{step = 0.01, min = -3, max = 3}) or gotHit
	self:_nextLine()

	gotHit = stepper("Game Scale", dtd, "GAME_SCALE_FACTOR",
			{step = 0.005, min = 0.01, max = 12}) or gotHit
	self:_nextLine()

	--Borders.
	gotHit = stepper("Border Thickness", dtd, "HIGH_SCORES_BORDER_THICKNESS",
			{min = 1, max = 12}) or gotHit
	self:_nextLine()

	gotHit = stepper("Border Roundness", dtd, "HIGH_SCORES_BORDER_ROUNDNESS",
			{min = 1, max = 100}) or gotHit

	if gotHit then self:_updateTheme() end
end

function DebugMenu:_ColorsTab(dt)
	self:_nextLine()
	
	local textW, textH = 100, 25
	local gotHit = false

	gotHit = colorPicker(dtd, "PRIMARY_COLOR") or gotHit
	self:_nextLine()
	gotHit = colorPicker(dtd, "SECONDARY_COLOR") or gotHit
	self:_nextLine()
	gotHit = colorPicker(dtd, "AUXILIARY_COLOR") or gotHit
	self:_nextLine()

	self:_nextLine()

	gotHit = colorPicker(dtd, "BACKGROUND_COLOR_1") or gotHit
	self:_nextLine()
	gotHit = colorPicker(dtd, "BACKGROUND_COLOR_2") or gotHit
	self:_nextLine()

	self:_nextLine()

	gotHit = colorPicker(dtd, "SHADOW_COLOR") or gotHit
	self:_nextLine()
	gotHit = colorPicker(dtd, "OUTLINE_COLOR") or gotHit
	
	self:_nextLine()
	self:_nextLine()
	gotHit = colorPicker(dtd, "TEXT_COLOR") or gotHit
	self:_nextLine()
	gotHit = colorPicker(dtd, "HIGHLIGHT_TEXT_COLOR") or gotHit

	if gotHit then self:_updateTheme() end
end

function DebugMenu:_BackgroundTab(dt)
	self:_nextLine()

	local textW, textH = 125, 25
	local gotHit = false

	--Background type.
	local t = self.tabs.Background
	suit.Label("BG Type", suit.layout:col(textW, textH))
	if suit.Button(dtd.BACKGROUND_TYPE, {id = "background-type"}, suit.layout:col(textW, textH)).hit then
		t.typeAt = (t.typeAt % #t.types) + 1
		dtd.BACKGROUND_TYPE = t.types[t.typeAt]
		gotHit = true
	end
	self:_nextLine()

	self:_nextLine()

	--Image Background Stats.
	suit.Label("BACKGROUND PATH", suit.layout:col(textW, textH))
	self:_nextLine()

	gotHit = stepper("BG X-Scale", dtd, "BACKGROUND_X_SCALE", {step = 0.05, 
		min = 0.1, max = 10}) or gotHit
	self:_nextLine()
	gotHit = stepper("BG Y-Scale", dtd, "BACKGROUND_Y_SCALE", {step = 0.05, 
		min = 0.1, max = 10}) or gotHit
	self:_nextLine()
	gotHit = stepper("BG X-Offset", dtd, "BACKGROUND_X_OFFSET", {step = 0.01, 
		min = -1000, max = 1000}) or gotHit
	self:_nextLine()
	gotHit = stepper("BG Y-Offset", dtd, "BACKGROUND_Y_OFFSET", {step = 0.01, 
		min = -1000, max = 1000}) or gotHit

	if gotHit then self:_updateTheme() end
end

function DebugMenu:_SpritesTab(dt)
	self:_nextLine()

--	local textW, textH = 125, 25
--	local gotHit = false
	
	--TicTacToe.
	imagePicker(self, dtd.SPRITES.tic, "id", "Tic")
	self:_nextLine()
	imagePicker(self, dtd.SPRITES.tac, "id", "Tac")
	self:_nextLine()
	
	--Memory.
	imagePicker(self, dtd.SPRITES.mem1, "id", "Memory-1")
	self:_nextLine()
	imagePicker(self, dtd.SPRITES.mem2, "id", "Memory-2")
	self:_nextLine()
	imagePicker(self, dtd.SPRITES.mem3, "id", "Memory-3")
	self:_nextLine()
	imagePicker(self, dtd.SPRITES.mem4, "id", "Memory-4")
	self:_nextLine()
	imagePicker(self, dtd.SPRITES.mem5, "id", "Memory-5")
	self:_nextLine()
	imagePicker(self, dtd.SPRITES.mem6, "id", "Memory-6")
	self:_nextLine()
	imagePicker(self, dtd.SPRITES.mem7, "id", "Memory-7")
	self:_nextLine()
	imagePicker(self, dtd.SPRITES.mem8, "id", "Memory-8")
	self:_nextLine()
	imagePicker(self, dtd.SPRITES.mem9, "id", "Memory-9")
	self:_nextLine()
	imagePicker(self, dtd.SPRITES.mem10, "id", "Memory-10")
	self:_nextLine()
	imagePicker(self, dtd.SPRITES.mem11, "id", "Memory-11")
	self:_nextLine()
	imagePicker(self, dtd.SPRITES.mem12, "id", "Memory-12")
	self:_nextLine()

	imagePicker(self, dtd.SPRITES.center, "id", "Center")
	self:_nextLine()
	imagePicker(self, dtd.SPRITES.cover, "id", "Cover")
end

--============================ Getters / Setters ==============================

function DebugMenu:setActive(bool)
	self.active = bool
end

function DebugMenu:isActive()
	return self.active
end


return DebugMenu
