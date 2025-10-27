return {
	keys = { "Maple", "Palm", "Pine" },
	byType = { tree = { "Maple", "Palm", "Pine" } },
	byKey = {
		Maple = {
			key = "Maple",
			type = "tree",
			name = "Maple Tree",
			hp = 150,
			growthTimeFactor = 1.5, -- Grows 1.5 times slower than normal
		},
		Palm = {
			key = "Palm",
			type = "tree",
			name = "Palm Tree",
			hp = 105,
			growthTimeFactor = 1.25, -- Grows 1.25 times slower than normal
		},
		Pine = {
			key = "Pine",
			type = "tree",
			name = "Pine Tree",
			hp = 84,
			growthTimeFactor = 1,
		},
	},
}
