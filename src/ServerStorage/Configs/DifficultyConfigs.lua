local DifficultyConfigs = {
	EASY = {
		DAY_TIME_LIMIT = 15 * 60, -- 15 minutes
		DECAY_RATE_PER_SECOND = 0.5, -- 50% slower decay rate
	},
	NORMAL = {
		DAY_TIME_LIMIT = 10 * 60, -- 10 minutes
		DECAY_RATE_PER_SECOND = 1, -- Normal decay rate
	},
	HARD = {
		DAY_TIME_LIMIT = 5 * 60, -- 5 minutes
		DECAY_RATE_PER_SECOND = 1.5, -- 50% faster decay rate
	},
}

return DifficultyConfigs
