export type DifficultyInfo = {
	name: string,
	description: string,
	index: number,
	dayDuration: number, -- In seconds
	spawnRateFactor: number,
	hpFactor: number,
	damageFactor: number,
	colorName: string,
}

local DifficultiesInfo = {
	keys = { "easy", "normal", "hard" },
	byKey = {
		easy = {
			name = "Easy",
			description = "A gentle start with fewer zombies and lighter danger.",
			index = 1,
			dayDuration = 10 * 60, -- 10 minutes
			spawnRateFactor = 0.75,
			hpFactor = 0.75,
			damageFactor = 0.75,
			colorName = "green",
		},
		normal = {
			name = "Normal",
			description = "A balanced challenge with steady spawns and fair fights.",
			index = 2,
			dayDuration = 7.5 * 60, -- 7.5 minutes
			spawnRateFactor = 1.0,
			hpFactor = 1.0,
			damageFactor = 1.0,
			colorName = "yellow",
		},
		hard = {
			name = "Hard",
			description = "Intense waves of stronger zombies for seasoned players.",
			index = 3,
			dayDuration = 5 * 60, -- 5 minutes
			spawnRateFactor = 1.35,
			hpFactor = 1.35,
			damageFactor = 1.35,
			colorName = "orange",
		},
	},
}

return DifficultiesInfo
