local Creating = {}
Creating.__index = Creating

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
local t = require(Packages.t)

-- Handlers --------------------------------------------------------------------
local PlayerDataHandler = require(BaseHandlers.PlayerDataHandler)
local MessageHandler = require(BaseHandlers.MessageHandler)

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local LobbyConfigs = require(ReplicatedConfigs.LobbyConfigs)

-- Types ---------------------------------------------------------------------------
local LobbyTypes = require(ReplicatedTypes.Lobby)
local ILobbySettings = t.strictInterface({
	difficulty = t.number,
	maxPlayers = t.number,
	friendsOnly = t.boolean,
	saveId = t.optional(t.string),
})

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Creating.new(lobby: table)
	local self = setmetatable({}, Creating)

	-- Booleans
	self._destroyed = false

	-- Strings
	self.type = "Creating"

	-- Instances
	self.lobby = lobby

	self:_Init()

	return self
end

function Creating:_Init()
	self.lobby:DestroyTouchConnections()
	self:Update()
end

function Creating:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)
end

function Creating:Update()
	-- Update frame
	self.lobby:UpdateFrameChildren("Creating", function(frame)
		local player = self.lobby.players[1]

		frame.TextLabelPlayer.Text = player and player.Name or "???"
	end)
	self.lobby:ShowFrame("Creating")
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Creating:Create(playerFired: Player, lobbySettings: LobbyTypes.LobbySettings): boolean
	if not ILobbySettings(lobbySettings) then
		warn("[Lobby][Creating] - Invalid lobby settings provided to Create.")
		return false
	end

	-- Review settings
	lobbySettings.difficulty =
		math.clamp(lobbySettings.difficulty or 1, LobbyConfigs.MIN_DIFFICULTY, LobbyConfigs.MAX_DIFFICULTY)
	lobbySettings.maxPlayers = math.clamp(lobbySettings.maxPlayers, LobbyConfigs.MIN_PLAYERS, LobbyConfigs.MAX_PLAYERS)

	-- Get save data if saveId is provided
	if lobbySettings.saveId then
		local saveInfo = PlayerDataHandler.GetKeyValue(playerFired.UserId, "SavesInfo", lobbySettings.saveId)
		if not saveInfo then
			MessageHandler.SendMessageToPlayer(playerFired, "Error: could not find the save.", "Error")
			return false
		end

		lobbySettings.difficulty = saveInfo.difficulty or lobbySettings.difficulty
	end

	self.lobby:SetSettings(lobbySettings)
	self.lobby:ChangeState("Starting")

	return true
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Creating
