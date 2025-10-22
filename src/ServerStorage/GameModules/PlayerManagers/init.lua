local PlayerManagers = {}

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
local Configs = ServerSource.Configs
local ReplicatedInfo = ReplicatedSource.Info
local Info = ServerSource.Info
local ReplicatedTypes = ReplicatedSource.Types
local Types = ServerSource.Types
local BaseModules = PlaywooEngine.BaseModules
local GameModules = ServerSource.GameModules
local BaseHandlers = PlaywooEngine.BaseHandlers
local GameHandlers = ServerSource.GameHandlers

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine.Utils)

-- Handlers --------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
local SaveTypes = require(ReplicatedTypes.SaveTypes)

-- Instances -----------------------------------------------------------------------

-- Info ----------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Events --------------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
local managers = {
	StateManager = script.StateManager,
	StatsResolver = script.StatsResolver,
	ToolsManager = script.ToolsManager,
} -- Required inside PlayerAdded to avoid circular dependency
local playersManagers = {} :: { [number]: { [string]: table } }

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function PlayerAdded(player: Player)
	playersManagers[player.UserId] = playersManagers[player.UserId] or {}

	for _, manager in pairs(managers) do
		if not playersManagers[player.UserId][manager.Name] then
			playersManagers[player.UserId][manager.Name] = require(manager).new(player)
		end
	end
end

local function PlayerRemoving(player: Player)
	if not playersManagers[player.UserId] then
		return
	end

	for _, manager in pairs(playersManagers[player.UserId]) do
		manager:Destroy()
	end

	playersManagers[player.UserId] = nil
end

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- Retrieves the StateManager for a player, creating it if it doesn't exist
function PlayerManagers.GetManager(player: Player, managerName: string): table?
	if not playersManagers[player.UserId] then
		warn("PlayerManagers.GetManager: No managers found for player:", player.UserId)
		return nil
	elseif not managers[managerName] then
		warn("PlayerManagers.GetManager: Manager not found:", managerName)
		return nil
	end

	return playersManagers[player.UserId][managerName]
end

function PlayerManagers.UpdateStateManager(player: Player, playerState: SaveTypes.PlayerState?)
	if playersManagers[player.UserId] and playersManagers[player.UserId].StateManager then
		playersManagers[player.UserId].StateManager:Update(playerState)
		return playersManagers[player.UserId].StateManager
	end

	playersManagers[player.UserId] = playersManagers[player.UserId] or {}
	playersManagers[player.UserId].StateManager = require(managers.StateManager).new(player, playerState)
	return playersManagers[player.UserId].StateManager
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
Utils.Signals.Connect("PlayerLoaded", PlayerAdded)
Utils.Signals.Connect("PlayerRemoving", PlayerRemoving)

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return PlayerManagers
