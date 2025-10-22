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
local PlayerManagers = require(GameModules.PlayerManagers)

-- KnitServices --------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local MapConfigs = require(ReplicatedConfigs.MapConfigs)
PlayerConfigs.DEFAULT_COLLISION_GROUP = "PlayersNoCollide"
PlayerConfigs.AUTO_RESPAWN = game.PlaceId == MapConfigs.MAPS_PLACE_ID.Lobby
PlayerConfigs.AUTO_RESPAWN_DELAY = 3

PlayerConfigs.RIG_TYPE = "R15" -- R6 or R15

-- Types ---------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function GetPSM(player: Player)
	if not player or not player:IsA("Player") then
		return nil
	end

	return PlayerManagers.GetManager(player, "StateManager")
end

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function PlayerConfigs.GetStartingVital(player: Player, vitalKey: string): number
	if not player or not player:IsA("Player") then
		return 0
	end

	if vitalKey == "hp" then
		return GetPSM(player):GetStartingHP()
	end

	return 0
end

function PlayerConfigs.GetMaxVital(player: Player, vitalKey: string): number
	if not player or not player:IsA("Player") then
		return 0
	end

	if vitalKey == "hp" then
		return GetPSM(player):GetMaxHP()
	end

	return 0
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
Players.CharacterAutoLoads = false

return PlayerConfigs
