local DayManager = {}
DayManager.__index = DayManager

-- Services ------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

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
local MessageHandler = require(BaseHandlers.MessageHandler)

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local TimeConfigs = require(ReplicatedConfigs.TimeConfigs)

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function DayManager.new(game)
	local self = setmetatable({}, DayManager)

	-- Booleans
	self._destroyed = false
	self._isDay = false
	self._nightCompleted = false

	-- Tables
	self._skipVotes = {} :: { [number]: boolean } -- UserId -> true

	-- Numbers
	self._dayDuration = game.difficultyInfo.dayDuration or TimeConfigs.DAY_DURATION

	-- Metatables
	self.game = game :: typeof(require(script.Parent))

	-- Events
	self.votesChanged = Utils.Signals.Create()
	self.dayStarted = Utils.Signals.Create()
	self.nightStarted = Utils.Signals.Create()
	self.nightSurvived = Utils.Signals.Create()

	self:_Init()

	return self
end

function DayManager:_Init()
	-- Connections
	Utils.Connections.Add(
		self,
		"PlayerRemoving",
		Players.PlayerRemoving:Connect(function(player)
			self:_PlayerLeft(player)
		end)
	)

	-- Initialize clock time
	Lighting.ClockTime = GameStateManager.GetKeyValue("clockTime") or TimeConfigs.DAY_START_TIME
	self:_StartClock()

	-- Observe game state changes
	GameStateManager.ObserveKey("zombiesLeft", function(newValue: number, oldValue: number)
		if newValue <= 0 and oldValue > 0 then
			-- All zombies have been eliminated for the night
			self:_NightCompleted()
		end
	end)
end

function DayManager:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)

	-- Destroy events
	self.votesChanged:Destroy()
	self.dayStarted:Destroy()
	self.nightStarted:Destroy()
	self.nightSurvived:Destroy()
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- EVENTS ----------------------------------------------------------------------------------------------------

function DayManager:_PlayerLeft(player: Player)
	local playerUserId = player.UserId

	if self._skipVotes[playerUserId] then
		self._skipVotes[playerUserId] = nil

		self:_VotesUpdated()
	end
end

function DayManager:_VotesUpdated()
	self.votesChanged:Fire()

	local totalPlayers = #Players:GetPlayers()

	local currentVotes = 0
	for _ in pairs(self._skipVotes) do
		currentVotes += 1
	end

	if currentVotes >= totalPlayers then
		-- Enough votes to skip the night
		self:_SkipDay()
	end
end

function DayManager:_SkipDay()
	if not self._isDay then
		-- Can only skip during day time
		return
	end

	MessageHandler.SendMessageToPlayers(Players:GetPlayers(), "The day has been skipped!")

	self:_StartNight()
end

function DayManager:_StartClock()
	-- Start day/night cycle timer

	if Lighting.ClockTime >= TimeConfigs.DAY_START_TIME and Lighting.ClockTime < TimeConfigs.DAY_END_TIME then
		-- Day time
		self._isDay = true
		self._nightCompleted = true
		self.dayStarted:Fire()

		-- Tween to night time over day duration
		local timeLeft = self._dayDuration
			* (
				(TimeConfigs.DAY_END_TIME - Lighting.ClockTime)
				/ (TimeConfigs.DAY_END_TIME - TimeConfigs.DAY_START_TIME)
			)

		Utils.Tween(
			Lighting,
			timeLeft,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out,
			{ ClockTime = TimeConfigs.DAY_END_TIME }
		).Completed
			:Connect(function(state)
				if state ~= Enum.PlaybackState.Completed then
					return
				end

				-- Start night time
				self:_StartNight()
			end)
	else
		-- Night time
		self:_StartNight()
	end
end

function DayManager:_StartNight()
	self._isDay = false
	self._nightCompleted = false

	if Lighting.ClockTime ~= TimeConfigs.NIGHT_START_TIME then
		-- Tween to night start time first
		Utils.Tween(
			Lighting,
			3, -- Quick transition to night start time
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out,
			{ ClockTime = TimeConfigs.NIGHT_START_TIME }
		).Completed
			:Connect(function()
				self.nightStarted:Fire()
			end)
	else
		self.nightStarted:Fire()
	end
end

function DayManager:_NightCompleted()
	if self._isDay or self._nightCompleted then
		return
	end
	self._nightCompleted = true

	self._skipVotes = {}

	-- Tween to day start time
	Utils.Tween(
		Lighting,
		3, -- Quick transition to day start time
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out,
		{ ClockTime = TimeConfigs.DAY_START_TIME }
	).Completed
		:Connect(function()
			-- Start day time
			self:_StartClock()
		end)

	self.nightSurvived:Fire()
end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- GETTERS ----------------------------------------------------------------------------------------------------

function DayManager:IsDay(): boolean
	return self._isDay
end

function DayManager:GetSkipVotesCount(): number
	return Utils.Table.Dictionary.length(self._skipVotes)
end

function DayManager:VoteSkipDay(player: Player): boolean
	if not self._isDay then
		-- Can only vote to skip during day time
		return false
	end

	local playerUserId = player.UserId

	if self._skipVotes[playerUserId] then
		-- Player has already voted
		return true
	end

	self._skipVotes[playerUserId] = true

	self:_VotesUpdated()

	return true
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return DayManager
