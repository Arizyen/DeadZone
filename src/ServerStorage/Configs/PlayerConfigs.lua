local PlayerConfigs = {}

-- Services ------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage.Packages
local ReplicatedSource = ReplicatedStorage.Source
local ServerSource = ServerStorage.Source
local ReplicatedPlaywooEngine = ReplicatedSource.PlaywooEngine
local PlaywooEngine = ServerSource.PlaywooEngine
local ReplicatedBaseModules = ReplicatedPlaywooEngine.BaseModules
local ReplicatedConfigs = ReplicatedSource.Configs
local Configs = ServerSource.Configs
local ReplicatedInfo = ReplicatedSource.Info
local ReplicatedTypes = ReplicatedSource.Types
local BaseModules = PlaywooEngine.BaseModules
local GameModules = ServerSource.GameModules
local BaseServices = PlaywooEngine.BaseServices
local GameServices = ServerSource.GameServices

-- Modulescripts -------------------------------------------------------------------
local HumanoidManager = require(BaseModules.HumanoidManager)

-- KnitServices --------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local MapConfigs = require(ReplicatedConfigs.MapConfigs)
PlayerConfigs.DEFAULT_COLLISION_GROUP = "PlayersNoCollide"
PlayerConfigs.AUTO_RESPAWN = true
PlayerConfigs.AUTO_RESPAWN_DELAY = 3

PlayerConfigs.RIG_TYPE = "R6" -- R6 or R15

-- Types ---------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function PlayerConfigs.GetPlayerMaxHP(player: Player): number
	if not player or not player:IsA("Player") then
		return 100
	end

	return 100
end

function PlayerConfigs.Spawn(player: Player): boolean
	if not player or not player:IsA("Player") then
		return false
	end

	local playerHumanoidDescription = HumanoidManager.GetPlayerHumanoidDescription(player.UserId)

	--TODO: Update humanoid description based on player data (clothing, accessories, etc.)

	if not playerHumanoidDescription then
		player:LoadCharacter()
	else
		player:LoadCharacterWithHumanoidDescription(playerHumanoidDescription)
	end

	return true
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
Players.CharacterAutoLoads = false

return PlayerConfigs
