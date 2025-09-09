return {
	allKeys = { "common", "uncommon", "rare", "epic", "legendary", "mythic", "vip", "limited" },
	byKey = {
		common = {
			name = "Common",
			-- image = "rbxassetid://139067754958197",
			colors = {
				Color3.fromRGB(255, 255, 255),
				Color3.fromRGB(212, 219, 230),
			},
			color = Color3.fromRGB(212, 219, 230),
			colorSequence = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(212, 219, 230)),
			rarityIndex = 1,
		},

		uncommon = {
			name = "Uncommon",
			-- image = "rbxassetid://127455775540242",
			colors = {
				Color3.fromRGB(127, 225, 115),
				Color3.fromRGB(84, 185, 78),
			},
			color = Color3.fromRGB(84, 185, 78),
			colorSequence = ColorSequence.new(Color3.fromRGB(127, 225, 115), Color3.fromRGB(84, 185, 78)),
			rarityIndex = 2,
		},

		rare = {
			name = "Rare",
			-- image = "rbxassetid://130777115876957",
			colors = {
				Color3.fromRGB(150, 160, 255),
				Color3.fromRGB(82, 85, 255),
			},
			color = Color3.fromRGB(82, 85, 255),
			colorSequence = ColorSequence.new(Color3.fromRGB(150, 160, 255), Color3.fromRGB(82, 85, 255)),
			rarityIndex = 3,
		},

		epic = {
			name = "Epic",
			-- image = "rbxassetid://127408060952501",
			colors = {
				Color3.fromRGB(218, 148, 248),
				Color3.fromRGB(162, 57, 234),
			},
			color = Color3.fromRGB(162, 57, 234),
			colorSequence = ColorSequence.new(Color3.fromRGB(218, 148, 248), Color3.fromRGB(162, 57, 234)),
			rarityIndex = 4,
		},

		legendary = {
			name = "Legendary",
			-- image = "rbxassetid://88000835606143",
			colors = {
				Color3.fromRGB(255, 245, 158),
				Color3.fromRGB(255, 215, 0),
			},
			color = Color3.fromRGB(255, 215, 0),
			colorSequence = ColorSequence.new(Color3.fromRGB(255, 245, 158), Color3.fromRGB(255, 215, 0)),
			rarityIndex = 5,
		},

		mythic = {
			name = "Mythic",
			-- image = "rbxassetid://119049709415044",
			colors = {
				Color3.fromRGB(255, 153, 221),
				Color3.fromRGB(255, 68, 187),
			},
			color = Color3.fromRGB(255, 68, 187),
			colorSequence = ColorSequence.new(Color3.fromRGB(255, 153, 221), Color3.fromRGB(255, 68, 187)),
			rarityIndex = 6,
		},

		-- divine = {
		-- 	name = "Divine",
		-- 	-- image = "rbxassetid://119049709415044",
		-- 	colors = {
		-- 		Color3.fromRGB(255, 255, 255), -- pure radiant white
		-- 		Color3.fromRGB(255, 223, 128), -- glowing gold
		-- 		Color3.fromRGB(180, 128, 255), -- mystical violet highlight
		-- 		Color3.fromRGB(128, 255, 234), -- celestial aqua accent
		-- 	},
		-- 	color = Color3.fromRGB(128, 255, 234),
		-- 	colorSequence = ColorSequence.new({
		-- 		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), -- start pure white
		-- 		ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 223, 128)), -- golden glow
		-- 		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(180, 128, 255)), -- violet shine
		-- 		ColorSequenceKeypoint.new(1, Color3.fromRGB(128, 255, 234)), -- aqua highlight
		-- 	}),
		-- 	rarityIndex = 7,
		-- },

		vip = {
			name = "VIP",
			colors = {
				Color3.fromRGB(235, 220, 0),
				Color3.fromRGB(255, 170, 0),
			},
			color = Color3.fromRGB(235, 220, 0),
			colorSequence = ColorSequence.new(Color3.fromRGB(235, 220, 0), Color3.fromRGB(255, 170, 0)),
			rarityIndex = 7,
		},

		limited = {
			name = "Limited",
			image = "rbxassetid://111770198864336",
			colors = {
				Color3.fromRGB(255, 0, 4),
				Color3.fromRGB(255, 170, 0),
				Color3.fromRGB(255, 255, 0),
				Color3.fromRGB(85, 255, 0),
				Color3.fromRGB(0, 170, 255),
				Color3.fromRGB(170, 85, 255),
			},
			color = Color3.fromRGB(255, 0, 0),
			colorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 4)),
				ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 170, 0)),
				ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(0.6, Color3.fromRGB(85, 255, 0)),
				ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 170, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 85, 255)),
			}),
			rarityIndex = 8,
		},
	},
}
