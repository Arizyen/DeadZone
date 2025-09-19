local DifficultyConfigs = require(script.Parent.DifficultyConfigs)

local StateConfigs = {
	HP_DECAY_RATE = 1 / DifficultyConfigs.NORMAL.DAY_TIME_LIMIT, -- 1 complete day time to decay completely
	ENERGY_DECAY_RATE = 1 / (DifficultyConfigs.NORMAL.DAY_TIME_LIMIT * 2), -- 2 days to decay completely
	HP_REGAIN_WAIT = 10, -- Wait 10 seconds after not taking damage to start regaining HP
	HP_REGAIN_RATE = 1, -- 1 HP per second when resting
	MAX_HP = 100,
	MAX_ENERGY = 100,
}

return StateConfigs
