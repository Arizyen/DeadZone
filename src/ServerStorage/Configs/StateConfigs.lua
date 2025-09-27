local DifficultyConfigs = require(script.Parent.DifficultyConfigs)

-- Updated by GameState
local StateConfigs = {
	HP_DECAY_RATE = 1 / DifficultyConfigs.NORMAL.DAY_TIME_LIMIT, -- 1 complete day time to decay completely
	ENERGY_DECAY_RATE = 1 / (DifficultyConfigs.NORMAL.DAY_TIME_LIMIT * 2), -- 2 days to decay completely
	ENERGY_DECAY_RATE_RUNNING = 0.3, -- 0.3 energy decay/second when running
	HP_REGAIN_WAIT = 3, -- Wait 3 seconds after not taking damage to start regaining HP
	HP_REGAIN_PERCENTAGE = 5, -- 5% HP per second when resting
	HP_MAX = 100,
}

return StateConfigs
