local GameLoader = {}

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
local SaveData = require(script.SaveData)
local PlayerManager = require(BaseModules.PlayerManager)
local PlayerStateManager = require(GameModules.PlayerStateManager)

-- Handlers --------------------------------------------------------------------
local GameHandler = require(GameHandlers.GameHandler)
local PlayerDataHandler = require(BaseHandlers.PlayerDataHandler)

-- Types ---------------------------------------------------------------------------
local SaveTypes = require(ReplicatedTypes.Save)

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local MapConfigs = require(ReplicatedConfigs.MapConfigs)

-- Variables -----------------------------------------------------------------------
local gotJoinData = false
local gotSaveData = false
local isSavedGame = false

local chosenSpawnLocation = nil :: SpawnLocation?

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function GetSpawnLocation()
	if chosenSpawnLocation then
		return chosenSpawnLocation
	end

	chosenSpawnLocation = Utils.Table.Array.getRandomValue(game.Workspace.Map.SpawnLocations:GetChildren())
	return chosenSpawnLocation
end

-- Loads a player's state and inventory based on their save data
local function LoadPlayer(player: Player, playerSave: SaveTypes.PlayerSave?)
	if MapConfigs.IS_PVE_PLACE then
		PlayerStateManager.Create(player, playerSave) -- Ensure StateManager is created for player
	else
		playerSave =
			PlayerDataHandler.GetPathValue(player.UserId, { "profile", "playerSavePVP" }) :: SaveTypes.PlayerSave?
		PlayerStateManager.Create(player, playerSave) -- Ensure StateManager is created for player
	end

	if playerSave then
		-- Set player's data based on save
		--TODO: Load save data of player
	else
		-- Initialize player as new player
		local spawnLocation = GetSpawnLocation()
		PlayerManager.Spawn(player, spawnLocation)
	end
end

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function GameLoader.GetJoinData(playerJoined: Player)
	if gotJoinData then
		return
	end

	gotJoinData = true

	local joinData = playerJoined:GetJoinData()
	if joinData and type(joinData.TeleportData) == "table" then
		if joinData.TeleportData.saveInfo then
			local saveInfo = joinData.TeleportData.saveInfo
			if saveInfo.id then
				isSavedGame = true

				--TODO: Load save data

				GameHandler.Init(SaveData.info) -- SaveData.info contains all settings of the saved game
			else
				GameHandler.Init(saveInfo) -- saveInfo contains settings of the new game
			end
		end
	else
		GameHandler.Init() -- New game with default settings
	end

	return joinData
end

function GameLoader.LoadPlayer(player: Player)
	if isSavedGame and not gotSaveData then
		repeat
			task.wait(0.1)
		until gotSaveData
	end

	-- Load player into game
	if isSavedGame then
		-- Load player based on save data
		LoadPlayer(player, SaveData.playersSave and SaveData.playersSave[player.UserId] or nil)
	else
		-- Load player as new player
		LoadPlayer(player, nil)
	end
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return GameLoader
