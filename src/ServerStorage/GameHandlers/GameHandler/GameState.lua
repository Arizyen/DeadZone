local GameState = {}

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

-- Handlers --------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
local SaveTypes = require(ReplicatedTypes.Save)

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local MapConfigs = require(ReplicatedConfigs.MapConfigs)

-- Variables -----------------------------------------------------------------------
local lastInitTime = os.time()

-- Tables --------------------------------------------------------------------------
local gameState = {
	placeId = MapConfigs.PVE_PLACE_IDS[#MapConfigs.PVE_PLACE_IDS],
	difficulty = 1,
	nightsSurvived = 0,
	playtime = 0,
	createdAt = os.time(),
	updatedAt = os.time(),
	creatorId = 0,

	clockTime = 12, -- Day time ratio (0-24)
} :: SaveTypes.SaveInfo

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function GameState.Init(saveInfo: SaveTypes.SaveInfo?)
	Utils.Table.Dictionary.merge(gameState, saveInfo or {})
	lastInitTime = os.time()
end

function GameState.Get(key: string?)
	if key then
		return gameState[key]
	end

	-- Make updates required before returning full state
	local currentTime = os.time()
	gameState.playtime += currentTime - lastInitTime
	gameState.updatedAt = currentTime
	lastInitTime = currentTime

	return gameState
end

function GameState.Set(key: string, value: any)
	gameState[key] = value
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return GameState
