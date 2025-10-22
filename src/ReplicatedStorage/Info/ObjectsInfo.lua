return {
	keys = { "Rock" },
	byType = {
		tool = { "Rock" },
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
			attackDelay = 1,
			damage = 5,
			animations = {
				idle = "rbxassetid://107469312851840",
				attack = "rbxassetid://76047539306094",
			},
		},
	},
}
