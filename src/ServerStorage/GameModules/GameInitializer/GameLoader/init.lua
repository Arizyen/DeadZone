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
local SaveTypes = require(ReplicatedTypes.SaveTypes)

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local MapConfigs = require(ReplicatedConfigs.MapConfigs)

-- Variables -----------------------------------------------------------------------
local gotJoinData = false
local loadedSaveData = false
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
	PlayerStateManager.Create(player, playerSave) -- Ensure StateManager is created for player

	if playerSave then
		-- Set player's data based on save
		--TODO: Load save data of player and spawn player at saved position

		SaveData.playersSave[player.UserId] = nil -- Clear loaded save data to free memory
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

				GameHandler.Init(SaveData.info, SaveData.builds) -- SaveData.info contains all settings of the saved game

				SaveData.info = nil -- Clear loaded save data to free memory
				SaveData.builds = nil -- Clear loaded builds data to free memory

				loadedSaveData = true
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
	if isSavedGame and not loadedSaveData then
		repeat
			task.wait(0.1)
		until loadedSaveData
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
