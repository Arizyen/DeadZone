local GameInitializer = {}

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

-- Modulescripts -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine.Utils)
local GameLoader = require(script.GameLoader)

-- KnitServices --------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local MapConfigs = require(ReplicatedConfigs.MapConfigs)

-- Types ---------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function LoadInPlayer(player: Player)
	GameLoader.GetJoinData(player)
	GameLoader.LoadPlayer(player)
	Utils.Instantiator.Create("BoolValue", { Parent = player, Name = "PlayerLoaded", Value = true })
end

local function Init()
	if not table.find(MapConfigs.PVE_PLACE_IDS, game.PlaceId) then
		return
	end

	-- Place map in workspace
	local mapName = Utils.Table.Dictionary.getKeyByValue(MapConfigs.MAPS_PLACE_ID, game.PlaceId)
	local map = ServerStorage.Maps[mapName]
	map.Name = "Map"
	map.Parent = game.Workspace

	-- Load in players
	for _, player in pairs(game.Players:GetPlayers()) do
		task.spawn(LoadInPlayer, player)
	end
	Utils.Signals.Connect("PlayerLoaded", function(player)
		LoadInPlayer(player)
	end)
end

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
Utils.Signals.Connect("KnitStarted", Init)

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return GameInitializer
