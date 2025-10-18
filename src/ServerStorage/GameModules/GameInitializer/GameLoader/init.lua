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
local DataStore = require(BaseModules.DataStore)

-- Handlers --------------------------------------------------------------------
local GameHandler = require(GameHandlers.GameHandler)
local PlayerDataHandler = require(BaseHandlers.PlayerDataHandler)

-- Types ---------------------------------------------------------------------------
local SaveTypes = require(ReplicatedTypes.SaveTypes)

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local DataStoreConfigs = require(Configs.DataStoreConfigs)
local MapConfigs = require(ReplicatedConfigs.MapConfigs)

-- Variables -----------------------------------------------------------------------
local gameSavesDatastore = DataStore.GetDataStore(DataStoreConfigs.GAME_SAVES_DATASTORE_KEY)
local gotJoinData = false
local loadedSaveData = false
local isSavedGame = false
local saveLoadFailed = false

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

local function SpawnPlayer(player: Player)
	local spawnLocation = GetSpawnLocation()
	PlayerManager.Spawn(player, spawnLocation)
end

-- Loads a player's state and inventory based on their save data
local function LoadPlayer(player: Player, playerSave: SaveTypes.PlayerSave?)
	PlayerStateManager.Create(player, playerSave) -- Ensure StateManager is created for player

	if playerSave then
		-- Set player's data based on save
		PlayerDataHandler.SetKeyValue(player.UserId, "objects", playerSave.objects or {})
		PlayerDataHandler.SetKeyValue(player.UserId, "objectsCategorized", playerSave.objectsCategorized or {})
		PlayerDataHandler.SetKeyValue(player.UserId, "hotbar", playerSave.hotbar or {})
		PlayerDataHandler.SetKeyValue(player.UserId, "inventory", playerSave.inventory or {})
		PlayerDataHandler.SetKeyValue(player.UserId, "loadout", playerSave.loadout or {})
		PlayerDataHandler.SetPathValue(player.UserId, { "sessionState", "zombieKills" }, playerSave.zombieKills or 0)

		-- Spawn player at saved position
		if playerSave.state.position then
			local position = Vector3.new(table.unpack(string.split(playerSave.state.position, ",")))
			PlayerManager.Spawn(player, position)
		else
			SpawnPlayer(player)
		end

		-- Set player vitals
		PlayerManager.SetVital(player, "hp", playerSave.state.hp or 100)

		SaveData.playersSave[player.UserId] = nil -- Clear loaded save data to free memory
	else
		-- Initialize player as new player
		PlayerDataHandler.SetPathValue(player.UserId, { "sessionState", "newSave" }, true)
		SpawnPlayer(player)
	end
end

local function LoadSave(id: string, chunksCount: number): boolean
	local chunks = {}

	for chunkIndex = 1, chunksCount do
		local chunkKey = id .. "_" .. chunkIndex
		local chunkData, success = DataStore.Load(gameSavesDatastore, chunkKey)
		if not success or not chunkData then
			warn("Failed to load chunk " .. chunkIndex .. " for save ID: " .. id)
			return false
		end
		table.insert(chunks, chunkData)
	end

	-- Combine chunks into a single save data table
	SaveData = Utils.Table.Tree.joinChunks(chunks)

	return true
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
			if saveInfo.id and saveInfo.chunksCount then
				isSavedGame = true

				if not LoadSave(saveInfo.id, saveInfo.chunksCount) then
					saveLoadFailed = true

					for _, player in pairs(game.Players:GetPlayers()) do
						if player.Parent == game.Players then
							player:Kick(
								"There was a problem loading the save. Please rejoin the game. Servers might be down."
							)
						end
					end

					return
				end

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

function GameLoader.LoadPlayer(player: Player): boolean
	if isSavedGame and not loadedSaveData then
		repeat
			task.wait(0.1)
		until loadedSaveData or saveLoadFailed
	end

	if saveLoadFailed then
		if player.Parent == game.Players then
			player:Kick("There was a problem loading the save. Please rejoin the game. Servers might be down.")
		end
		return false
	end

	-- Load player into game
	if isSavedGame then
		-- Load player based on save data
		LoadPlayer(player, SaveData.playersSave and SaveData.playersSave[player.UserId] or nil)
	else
		-- Load player as new player
		LoadPlayer(player, nil)
	end

	return true
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return GameLoader
