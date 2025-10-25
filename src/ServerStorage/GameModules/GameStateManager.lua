local GameStateManager = {}

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
local TableObserver = require(ReplicatedBaseModules.TableObserver)

-- Handlers --------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
local SaveTypes = require(ReplicatedTypes.SaveTypes)

-- Instances -----------------------------------------------------------------------

-- Info ----------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local MapConfigs = require(ReplicatedConfigs.MapConfigs)
local TimeConfigs = require(ReplicatedConfigs.TimeConfigs)

-- Variables -----------------------------------------------------------------------

-- Events --------------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
local gameState = {
	placeId = MapConfigs.PVE_PLACE_IDS[#MapConfigs.PVE_PLACE_IDS],
	difficulty = 1,
	nightsSurvived = 0,
	zombiesLeft = 0,
	playtime = 0,
	createdAt = os.time(),
	updatedAt = os.time(),
	creatorId = 0,

	clockTime = TimeConfigs.DAY_START_TIME, -- Day time ratio (0-24)
} :: SaveTypes.SaveInfo

local tableObserver = TableObserver.new(gameState)

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function GameStateManager.Load(saveInfo: SaveTypes.SaveInfo)
	tableObserver:Set(saveInfo)
end

-- GET/SET ----------------------------------------------------------------------------------------------------

function GameStateManager.Get()
	return tableObserver:Get()
end

function GameStateManager.GetKey(key: string)
	return tableObserver:GetKey(key)
end

function GameStateManager.SetKey(key: string, value: any)
	tableObserver:SetKey(key, value)
end

function GameStateManager.ObserveKey(key: string, callback: (newValue: any, oldValue: any) -> ())
	return tableObserver:ObserveKey(key, callback)
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return GameStateManager
