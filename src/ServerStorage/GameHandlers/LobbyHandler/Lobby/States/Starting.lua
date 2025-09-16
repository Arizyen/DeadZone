local Starting = {}
Starting.__index = Starting

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
local BaseHandlers = PlaywooEngine.BaseHandlers
local GameHandlers = ServerSource.GameHandlers

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine.Utils)

-- Handlers --------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------
local DifficultiesInfo = require(ReplicatedInfo.DifficultiesInfo)

-- Configs -------------------------------------------------------------------------
local LobbyConfigs = require(ReplicatedConfigs.LobbyConfigs)

-- Types ---------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Starting.new(lobby: table)
	local self = setmetatable({}, Starting)

	-- Booleans
	self._destroyed = false

	-- Strings
	self.type = "Starting"

	-- Instances
	self.lobby = lobby

	-- Numbers
	self._timeStarting = os.clock() + LobbyConfigs.START_TIME_WAIT

	self:_Init()

	return self
end

function Starting:_Init()
	self.lobby:SetStartTime(game.Workspace:GetServerTimeNow() + LobbyConfigs.START_TIME_WAIT)

	-- Connections
	Utils.Connections.Add(
		self,
		"PlayersUpdated",
		self.lobby.playersUpdated:Connect(function()
			self:Update()
		end)
	)

	self.lobby:AddTouchConnections()
	self:Update()
	self:_StartTimer()
end

function Starting:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)
end

function Starting:Update()
	-- Update frames
	local lobbyDifficultyInfo =
		DifficultiesInfo.byKey[DifficultiesInfo.allKeys[self.lobby.settings and self.lobby.settings.difficulty or 1]]

	self.lobby:UpdateFrameChildren("Starting", function(frame)
		frame.TextLabelDifficulty.Text =
			LobbyConfigs.DIFFICULTY_NAMES[self.lobby.settings and self.lobby.settings.difficulty or 1]
		frame.TextLabelDifficulty.UIGradient.Color = Utils.Color.Configs.colorSequences[lobbyDifficultyInfo.colorName]

		frame.TextLabelPlayerCount.Text = #self.lobby.players
			.. " / "
			.. (self.lobby.settings and self.lobby.settings.maxPlayers or "???")
		frame.TextLabelFriendsOnly.Visible = self.lobby.settings and self.lobby.settings.friendsOnly or false
		frame.TextLabelTeleportTimer.Text = tostring(math.ceil(self._timeStarting - os.clock())) .. "s"
	end)
	self.lobby:ShowFrame("Starting")
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Starting:_StartTimer()
	task.spawn(function()
		while os.clock() < self._timeStarting and not self._destroyed do
			self:Update()
			task.wait(1)
		end

		if self._destroyed then
			return
		end

		-- Time's up, start the game
		self.lobby:ChangeState("Teleporting")
	end)
end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Starting
