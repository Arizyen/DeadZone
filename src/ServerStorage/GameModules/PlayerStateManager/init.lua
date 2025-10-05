local PlayerStateManager = {}

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
local ReplicatedTypes = ReplicatedSource.Types
local BaseModules = PlaywooEngine.BaseModules
local GameModules = ServerSource.GameModules
local BaseHandlers = PlaywooEngine.BaseHandlers
local GameHandlers = ServerSource.GameHandlers

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine.Utils)
local StateManager = require(script.StateManager)

-- Handlers --------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
local SaveTypes = require(ReplicatedTypes.SaveTypes)

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
local playersStateManager = {} :: { [number]: typeof(StateManager) }

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- Creates or retrieves the StateManager for a player with optional initial state
-- If the StateManager already exists, it updates it with the provided state
function PlayerStateManager.Create(player: Player, playerState: SaveTypes.PlayerState?): typeof(StateManager)
	if playersStateManager[player.UserId] then
		playersStateManager[player.UserId]:Update(playerState)
		return playersStateManager[player.UserId]
	end

	playersStateManager[player.UserId] = StateManager.new(player, playerState)
	return playersStateManager[player.UserId]
end

-- Retrieves the StateManager for a player, creating it if it doesn't exist
function PlayerStateManager.Get(player: Player): typeof(StateManager)
	if playersStateManager[player.UserId] then
		return playersStateManager[player.UserId]
	end

	playersStateManager[player.UserId] = StateManager.new(player)
	return playersStateManager[player.UserId]
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
Utils.Signals.Connect("PlayerRemoving", function(player: Player)
	if playersStateManager[player.UserId] then
		playersStateManager[player.UserId]:Destroy()
		playersStateManager[player.UserId] = nil
	end
end)

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return PlayerStateManager
