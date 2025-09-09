local DailyConfigs = {}

-- Services ------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage.Packages
local ReplicatedSource = ReplicatedStorage.Source
local ServerSource = ServerStorage.Source
local ReplicatedPlaywooEngine = ReplicatedSource.PlaywooEngine
local PlaywooEngine = ServerSource.PlaywooEngine
local ReplicatedBaseModules = ReplicatedPlaywooEngine.BaseModules
local ReplicatedConfigs = ReplicatedSource.Configs
local ReplicatedInfo = ReplicatedSource.Info
local ReplicatedTypes = ReplicatedSource.Types
local BaseModules = PlaywooEngine.BaseModules
local GameModules = ServerSource.GameModules
local BaseServices = PlaywooEngine.BaseServices
local GameServices = ServerSource.GameServices
local BaseHandlers = PlaywooEngine.BaseHandlers

-- Modulescripts -------------------------------------------------------------------
local ReplicatedDailyRewardConfigs = require(ReplicatedConfigs.DailyRewardConfigs)

-- Handlers --------------------------------------------------------------------
local PlayerDataHandler = require(BaseHandlers.PlayerDataHandler)

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------
local DailyRewardsInfo = require(ReplicatedInfo.Rewards.DailyRewardsInfo)

-- Configs -------------------------------------------------------------------------
DailyConfigs.MIN_WAIT_TIME = ReplicatedDailyRewardConfigs.MIN_WAIT_TIME
DailyConfigs.MAX_WAIT_TIME = ReplicatedDailyRewardConfigs.MAX_WAIT_TIME
DailyConfigs.MAX_DAILY_REWARDS = #DailyRewardsInfo

-- Types ---------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function DailyConfigs.GivePlayerDayReward(player: Player, day: number): boolean
	if not DailyRewardsInfo[day] then
		return false
	end
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return DailyConfigs
