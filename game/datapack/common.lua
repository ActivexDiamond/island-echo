--Author:    Dulfiqar 'Active Diamond' H. Al-Safi
--Year:      (C) 2026
--File:      common.lua

data{"logos_scene",
	LOGOS = {{
			ID = "love_logo",
			DURATION = 2,
			TEXT = "MADE WITH:",
			w = 1024 / 2,
			h = 380 / 2,
	},{
			ID = "cat_paw_logo",
			DURATION = 2,
			TEXT = "MADE WITH:",
			w = 15 * 20,
			h = 15 * 20,
	}},

	BACKGROUND_COLOR = {fromHex("#100f36ff")},
	--BACKGROUND_COLOR = {fromHex("#e64999ff")},
	FADE_IN = true,
	FADE_OUT = true,

	--The distance from the center for the text displayed above the logos ("Made By", etc...). Percentage of window height.
	TEXT_Y_CENTER_OFFSET = 0.2
}
