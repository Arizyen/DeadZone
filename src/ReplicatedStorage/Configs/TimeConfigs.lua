local TimeConfigs = {
	DAY_START_TIME = 7, -- 7:00 AM
	DAY_END_TIME = 18, -- 6:00 PM
	NIGHT_START_TIME = 24, -- Midnight
}

TimeConfigs.TOTAL_DAY_DURATION = TimeConfigs.DAY_END_TIME - TimeConfigs.DAY_START_TIME -- In hours

return TimeConfigs
