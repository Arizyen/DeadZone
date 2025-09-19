local DifficultiesInfo = {
	allKeys = { "Easy", "Normal", "Hard" },
	byKey = {
		Easy = {
			name = "Easy",
			description = "A gentle start with fewer zombies and lighter danger.",
			difficultyIndex = 1,
			spawnRateMultiplier = 0.75,
			healthMultiplier = 0.75,
			damageMultiplier = 0.75,
			colorName = "green",
		},
		Normal = {
			name = "Normal",
			description = "A balanced challenge with steady spawns and fair fights.",
			difficultyIndex = 2,
			spawnRateMultiplier = 1.0,
			healthMultiplier = 1.0,
			damageMultiplier = 1.0,
			colorName = "yellow",
		},
		Hard = {
			name = "Hard",
			description = "Intense waves of stronger zombies for seasoned players.",
			difficultyIndex = 3,
			spawnRateMultiplier = 1.5,
			healthMultiplier = 1.5,
			damageMultiplier = 1.5,
			colorName = "orange",
		},
	},
}

return DifficultiesInfo
