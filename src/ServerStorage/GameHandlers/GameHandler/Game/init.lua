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
local GameStateManager = require(GameModules.GameStateManager)

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

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Game.new(): typeof(Game)
	local self = setmetatable({}, Game)

	-- Booleans
	self._destroyed = false

	-- Numbers

	-- Tables
	self.difficultyInfo = DifficultiesInfo.byKey[DifficultiesInfo.keys[table.find(
		DifficultiesInfo.keys,
		GameStateManager.GetKey("difficulty")
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

-- REPLICATIONS ----------------------------------------------------------------------------------------------------

function Game:_FireGameState()
	Ports.SetGameState(self:GetGameState())
end

function Game:_FireGameStateKey(key: string)
	Ports.SetGameStateKey(key, self:GetGameState()[key])
end

function Game:_NightSurvived()
	GameStateManager.SetKeyValue("nightsSurvived", GameStateManager.GetKey("nightsSurvived") + 1)

	self:_FireGameState()
end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Game:GetGameState(): GameTypes.GameState
	return {
		difficulty = GameStateManager.GetKey("difficulty"),
		isDay = self.dayManager:IsDay(),
		nightsSurvived = GameStateManager.GetKey("nightsSurvived"),
		zombiesLeft = GameStateManager.GetKey("zombiesLeft"),
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
