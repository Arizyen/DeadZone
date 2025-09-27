return {
	colors1 = {
		Color3.fromRGB(35, 60, 170),
		Color3.fromRGB(5, 100, 180),
		Color3.fromRGB(0, 145, 195),
		Color3.fromRGB(1, 157, 74),
		Color3.fromRGB(115, 200, 75),
		Color3.fromRGB(250, 230, 0),
		Color3.fromRGB(250, 165, 25),
		Color3.fromRGB(239, 123, 33),
		Color3.fromRGB(255, 75, 100),
		Color3.fromRGB(240, 25, 40),
		Color3.fromRGB(160, 35, 145),
		Color3.fromRGB(90, 50, 150),
	},

	colors2 = {
		Color3.fromRGB(115, 200, 75),
		Color3.fromRGB(250, 230, 0),
		Color3.fromRGB(250, 165, 25),
		Color3.fromRGB(239, 123, 33),
		Color3.fromRGB(255, 75, 100),
		Color3.fromRGB(240, 25, 40),
	},

	gradientColors = {
		white = { Color3.fromRGB(255, 255, 255), Color3.fromRGB(235, 235, 235) },
		blackTotal = { Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0) },

		blue = { Color3.fromRGB(54, 177, 255), Color3.fromRGB(28, 141, 244) },
		blueStatic = { Color3.fromRGB(54, 177, 255), Color3.fromRGB(54, 177, 255) },

		green = { Color3.fromRGB(56, 221, 111), Color3.fromRGB(50, 150, 100) },

		purple = { Color3.fromRGB(119, 44, 225), Color3.fromRGB(81, 81, 225) },
		purple2 = { Color3.fromRGB(112, 41, 255), Color3.fromRGB(75, 37, 203) },
		purple3 = {
			Color3.fromRGB(170, 75, 255),
			Color3.fromRGB(120, 50, 200),
		},

		orange = {
			Color3.fromRGB(255, 140, 25),
			Color3.fromRGB(210, 90, 10),
		},
		gold = {
			Color3.fromRGB(255, 190, 40),
			Color3.fromRGB(210, 135, 15),
		},
		yellow = {
			Color3.fromRGB(255, 225, 50),
			Color3.fromRGB(210, 180, 20),
		},
		pink = {
			Color3.fromRGB(255, 95, 180),
			Color3.fromRGB(200, 50, 130),
		},
		teal = {
			Color3.fromRGB(0, 210, 190),
			Color3.fromRGB(0, 160, 150),
		},
		indigo = {
			Color3.fromRGB(95, 80, 255),
			Color3.fromRGB(65, 55, 200),
		},
		cyan = {
			Color3.fromRGB(0, 255, 255),
			Color3.fromRGB(0, 180, 200),
		},
		lime = {
			Color3.fromRGB(150, 255, 70),
			Color3.fromRGB(100, 200, 40),
		},
		magenta = {
			Color3.fromRGB(255, 0, 180),
			Color3.fromRGB(200, 0, 120),
		},
		-- gold = {
		-- 	Color3.fromRGB(255, 200, 50),
		-- 	Color3.fromRGB(210, 160, 30),
		-- },
		turquoise = {
			Color3.fromRGB(64, 224, 208),
			Color3.fromRGB(40, 160, 150),
		},
		crimson = {
			Color3.fromRGB(220, 20, 60),
			Color3.fromRGB(160, 15, 45),
		},
		silver = {
			Color3.fromRGB(210, 210, 220),
			Color3.fromRGB(160, 160, 170),
		},
		bronze = {
			Color3.fromRGB(205, 127, 50),
			Color3.fromRGB(160, 90, 35),
		},

		rainbow = {
			Color3.fromRGB(255, 0, 4),
			Color3.fromRGB(255, 170, 0),
			Color3.fromRGB(255, 255, 0),
			Color3.fromRGB(85, 255, 0),
			Color3.fromRGB(0, 170, 255),
			Color3.fromRGB(170, 85, 255),
		},
		rainbow2 = {
			Color3.fromRGB(244, 67, 54),
			Color3.fromRGB(233, 30, 99),
			Color3.fromRGB(156, 39, 176),
			Color3.fromRGB(33, 150, 243),
			Color3.fromRGB(0, 200, 83),
			Color3.fromRGB(255, 235, 59),
			Color3.fromRGB(255, 109, 0),
		},

		red = { Color3.fromRGB(255, 35, 15), Color3.fromRGB(190, 27, 12) },
		redStatic = { Color3.fromRGB(255, 35, 15), Color3.fromRGB(255, 35, 15) },

		-- CUSTOM COLORS
		coins = { Color3.fromRGB(253, 188, 13), Color3.fromRGB(252, 149, 4) },
		xp = { Color3.fromRGB(253, 188, 13), Color3.fromRGB(252, 149, 4) },
	},

	colorSequences = {}, -- Gets auto filled in on init (all colors from gradientColors)
}
