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
			image = nil,
			weightPerUnit = 2,
			type = "tool",
			category = "hybrid",
			useDelay = 1,
			damage = 5,
			animations = {
				idle = "rbxassetid://107469312851840",
				attack = "rbxassetid://76047539306094",
			},
		},

		-- Items
		Logs = {
			key = "Logs",
			name = "Logs",
			description = "Wooden logs obtained from chopping down trees.",
			stackable = true,
			image = nil,
			weightPerUnit = 1,
		},
	},
}
