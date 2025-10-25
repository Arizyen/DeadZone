local GameSaveData = {}

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
local GameStateManager = require(GameModules.GameStateManager)

-- Handlers --------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
local SaveTypes = require(ReplicatedTypes.SaveTypes)

-- Instances -----------------------------------------------------------------------

-- Info ----------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Events --------------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
local saveData = {
	info = {} :: SaveTypes.SaveInfo,
	builds = {},
	resources = {},
	playersSave = {} :: { [number]: SaveTypes.PlayerSave },
} :: SaveTypes.Save

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function GameSaveData.Load(newSaveData: SaveTypes.Save)
	saveData = newSaveData
	GameStateManager.Load(newSaveData.info)
end

-- BUILDS ----------------------------------------------------------------------------------------------------

function GameSaveData.GetBuilds()
	return saveData.builds
end

-- Clears all saved builds from memory after it's been loaded
function GameSaveData.ClearBuilds()
	saveData.builds = {}
end

-- Resources ----------------------------------------------------------------------------------------------------

function GameSaveData.GetResources()
	return saveData.resources
end

-- Clears all saved resources from memory after it's been loaded
function GameSaveData.ClearResources()
	saveData.resources = {}
end

-- PLAYERS SAVE ----------------------------------------------------------------------------------------------------

function GameSaveData.GetPlayersSave()
	return saveData.playersSave
end

function GameSaveData.GetPlayerSave(userId: number)
	return saveData.playersSave[userId]
end

-- Clears the saved data for a specific player from memory after it's been loaded
function GameSaveData.ClearPlayerSave(userId: number)
	saveData.playersSave[userId] = nil
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return GameSaveData
