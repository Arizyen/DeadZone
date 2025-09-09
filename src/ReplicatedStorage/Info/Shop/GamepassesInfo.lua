local GamepassesInfo = {
	allKeys = {
		"vip",
		"superLucky",
		"vote3x",
		"lucky",
	},
	byKey = {
		vip = {
			key = "vip",
			name = "VIP",
			description = "2X rewards<br/>VIP cannon/tile skins<br/>Rainbow name tag!",
			price = 349,
			image = "rbxassetid://102219142938632",
			id = 1265202345,
			colorSequence = ColorSequence.new(Color3.fromRGB(254, 226, 38), Color3.fromRGB(253, 168, 9)),
			layoutOrder = 1,
		},
		superLucky = {
			key = "superLucky",
			name = "Super Lucky",
			description = "Super luck! <br/>(Stacks with lucky)",
			price = 329,
			image = "rbxassetid://125601257166531",
			id = 1354558789,
			colorSequence = ColorSequence.new(Color3.fromRGB(254, 232, 84), Color3.fromRGB(253, 188, 13)),
			layoutOrder = 2,
		},
		vote3x = {
			key = "vote3x",
			name = "3X Vote",
			description = "Your vote counts 3 times!",
			price = 179,
			image = "rbxassetid://72569926986271",
			id = 1341501827,
			colorSequence = ColorSequence.new(Color3.fromRGB(150, 219, 255), Color3.fromRGB(55, 185, 255)),
			layoutOrder = 3,
		},
		lucky = {
			key = "lucky",
			name = "Lucky",
			description = "Better luck with chest unlocking!",
			price = 179,
			image = "rbxassetid://133261861697084",
			id = 1265080487,
			colorSequence = ColorSequence.new(Color3.fromRGB(101, 214, 102), Color3.fromRGB(254, 232, 84)),
			layoutOrder = 4,
		},
	},
}

return GamepassesInfo
