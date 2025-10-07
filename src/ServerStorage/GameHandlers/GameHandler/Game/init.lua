local Game = {}
Game.__index = Game

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
local Ports = require(script.Parent.Ports)

-- Handlers --------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
local SaveTypes = require(ReplicatedTypes.SaveTypes)
local GameTypes = require(ReplicatedTypes.GameTypes)

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------
local DifficultiesInfo = require(ReplicatedInfo.DifficultiesInfo)

-- Configs -------------------------------------------------------------------------
local MapConfigs = require(ReplicatedConfigs.MapConfigs)
local TimeConfigs = require(ReplicatedConfigs.TimeConfigs)

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
local defaultSaveInfo = {
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

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Game.new(saveInfo: SaveTypes.SaveInfo?, builds: {}): typeof(Game)
	local self = setmetatable({}, Game)

	-- Booleans
	self._destroyed = false

	-- Numbers
	self._lastSaveTime = os.time()

	-- Tables
	self.saveInfo = Utils.Table.Dictionary.merge(defaultSaveInfo, saveInfo or {}) :: SaveTypes.SaveInfo
	self.builds = table.clone(builds or {}) :: table
	self.difficultyInfo = DifficultiesInfo.byKey[DifficultiesInfo.keys[table.find(
		DifficultiesInfo.keys,
		self.saveInfo.difficulty
	) or 1]] :: DifficultiesInfo.DifficultyInfo

	-- Metatables
	self.dayManager = require(script.DayManager).new(self)

	self:_Init()

	return self
end

function Game:_Init()
	self:_FireGameState()

	-- Connections
	Utils.Connections.Add(
		self,
		"nightSurvived",
		self.dayManager.nightSurvived:Connect(function()
			self:_NightSurvived()
		end)
	)

	Utils.Connections.Add(
		self,
		"nightStarted",
		self.dayManager.nightStarted:Connect(function()
			self:_FireGameState()
		end)
	)

	Utils.Connections.Add(
		self,
		"dayStarted",
		self.dayManager.dayStarted:Connect(function()
			self:_FireGameState()
		end)
	)

	Utils.Connections.Add(
		self,
		"votesChanged",
		self.dayManager.votesChanged:Connect(function()
			self:_FireGameState()
		end)
	)
end

function Game:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)

	self.dayManager:Destroy()
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- SERIALIZATION ----------------------------------------------------------------------------------------------------

-- Serializes the game for saving
function Game:_Serialize(): SaveTypes.Save
	return {
		info = self:_GetSaveInfo(),
		builds = {}, -- TODO: Implement builds serialization
		playersSave = {}, -- TODO: Implement player saves serialization
	}
end

function Game:_GetSaveInfo(): SaveTypes.SaveInfo
	-- Make updates required before returning full state
	local currentTime = os.time()
	self.saveInfo.playtime += currentTime - self._lastSaveTime
	self.saveInfo.updatedAt = currentTime
	self._lastSaveTime = currentTime

	return Utils.Table.Dictionary.deepCopy(self.saveInfo)
end

-- REPLICATIONS ----------------------------------------------------------------------------------------------------

function Game:_FireGameState()
	Ports.SetGameState(self:GetGameState())
end

function Game:_NightSurvived()
	self.saveInfo.nightsSurvived += 1
	self.saveInfo.zombiesLeft = 0 -- Reset zombies left for new night

	self:_FireGameState()
end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Game:GetGameState(): GameTypes.GameState
	return {
		difficulty = self.saveInfo.difficulty,
		isDay = self.dayManager:IsDay(),
		nightsSurvived = self.saveInfo.nightsSurvived,
		zombiesLeft = self.saveInfo.zombiesLeft,
		skipVotes = self.dayManager:GetSkipVotesCount(),
	}
end

function Game:VoteSkipDay(player: Player): boolean
	return self.dayManager:VoteSkipDay(player)
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Game
