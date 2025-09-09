local LevelConfigs = {}

LevelConfigs.STARTING_XP = 1000
LevelConfigs.XP_LVL_RATIO = 1.05

-- FUNCTIONS ----------------------------------------------------------------------------------------------------
function LevelConfigs.GetLevel(totalXP: number): number
	local level = 1
	while totalXP >= LevelConfigs.STARTING_XP * (LevelConfigs.XP_LVL_RATIO ^ (level - 1)) do
		totalXP -= LevelConfigs.STARTING_XP * (LevelConfigs.XP_LVL_RATIO ^ (level - 1))
		level += 1
	end
	return level
end

return LevelConfigs
