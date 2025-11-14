return {
	keys = { "Rock" },
	byType = {
		tool = { "Rock" },
		item = {},
		wearable = {},
	},
	byKey = {
		-- Tools
		Rock = {
			key = "Rock",
			name = "Rock",
			description = "A simple rock that can be used as a weapon or harvesting tool.",
			stackable = false,
			image = "rbxassetid://103411188810140",
			weightPerUnit = 0.5,
			type = "tool",
			category = "hybrid",
			attackType = "melee",
			resourceType = "any",
			durabilityLossPerUse = 0.002, -- 500 uses
			useDelay = 1,
			useRange = 3,
			damage = 5,
			animations = {
				idle = "rbxassetid://107469312851840",
				attack = "rbxassetid://76047539306094",
			},
		},

		-- Items
		Log = {
			key = "Log",
			name = "Log",
			description = "Wooden logs obtained from chopping down trees.",
			stackable = true,
			image = nil,
			weightPerUnit = 0.3,
			quantity = 1,
			type = "item",
			category = "material",
		},

		MapleSapling = {
			key = "MapleSapling",
			name = "Maple Sapling",
			description = "A young maple tree sapling. Can be planted to grow a maple tree.",
			stackable = true,
			image = nil,
			weightPerUnit = 0.2,
			quantity = 1,
			type = "item",
			category = "other",
		},

		PineSapling = {
			key = "PineSapling",
			name = "Pine Sapling",
			description = "A young pine tree sapling. Can be planted to grow a pine tree.",
			stackable = true,
			image = nil,
			weightPerUnit = 0.2,
			quantity = 1,
			type = "item",
			category = "other",
		},

		PalmSapling = {
			key = "PalmSapling",
			name = "Palm Sapling",
			description = "A young palm tree sapling. Can be planted to grow a palm tree.",
			stackable = true,
			image = nil,
			weightPerUnit = 0.2,
			quantity = 1,
			type = "item",
			category = "other",
		},
	},
}
