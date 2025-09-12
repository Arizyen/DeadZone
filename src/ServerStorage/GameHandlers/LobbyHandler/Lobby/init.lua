local Lobby = {}
Lobby.__index = Lobby

-- Services ------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

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

local States = script.States

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine.Utils)
local Waiting = require(States.Waiting)
local Creating = require(States.Creating)
local Starting = require(States.Starting)
local Teleporting = require(States.Teleporting)

-- Handlers --------------------------------------------------------------------
local PlayerHandler = require(GameHandlers.PlayerHandler)

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
local LobbyTypes = require(ReplicatedTypes.Lobby)

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
local states = {
	Waiting = Waiting,
	Creating = Creating,
	Starting = Starting,
	Teleporting = Teleporting,
}
local playersLobbyId = {} :: { [number]: string } -- UserId: lobbyId

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Lobby.new(lobbyModel: Model)
	local self = setmetatable({}, Lobby)

	-- Booleans
	self._destroyed = false

	-- Strings
	self._id = lobbyModel.Name

	-- Tables
	self.players = {} :: { Player }
	self.settings = {} :: LobbyTypes.LobbySettings?

	-- Instances
	self._lobbyModel = lobbyModel
	self._billboardGui = lobbyModel.PrimaryPart.BillboardGui
	self._currentState = nil :: typeof(Waiting) | typeof(Creating) | typeof(Starting) | typeof(Teleporting) | nil

	-- Signals
	self.playersUpdated = Utils.Signals.Create() -- Fires {Player}
	self.lobbyUpdated = Utils.Signals.Create() -- Fires LobbyState

	-- Connections
	self._wallTouchConnections = {} :: { RBXScriptConnection }

	self:_Init()

	return self
end

function Lobby:_Init()
	-- Connections
	Utils.Connections.Add(
		self,
		"PlayerRemoving",
		Utils.Signals.Connect("PlayerRemoving", function(player: Player)
			self:_RemovePlayer(player)
		end)
	)
	Utils.Connections.Add(
		self,
		"PlayerDied",
		Utils.Signals.Connect("PlayerDied", function(player: Player)
			self:_RemovePlayer(player)
		end)
	)
	Utils.Connections.Add(
		self,
		"PlayersUpdated",
		self.playersUpdated:Connect(function(players: { Player })
			if #players == 0 then
				self:ChangeState("Waiting")
			end
		end)
	)

	self:ChangeState("Waiting")
end

function Lobby:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)

	-- Cleanup
	self.playersUpdated:Destroy()
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- EVENTS ----------------------------------------------------------------------------------------------------

function Lobby:_FireLobbyUpdated()
	self.lobbyUpdated:Fire(self:GetLobbyState())
end

-- PLAYER MANAGEMENT ---------------------------------------------------------------------------------------------------

function Lobby:_PlayersUpdated()
	self.playersUpdated:Fire(self.players)
	self:_FireLobbyUpdated()
end

function Lobby:_AddPlayer(player: Player): boolean
	if playersLobbyId[player.UserId] or player:GetAttribute("isDead") then
		return false
	end

	-- Check settings
	if self.settings then
		if #self.players >= (self.settings.maxPlayers or 1) then
			return false
		end
		if self.settings.friendsOnly then
			local owner = self.players[1]
			if owner and owner.UserId ~= player.UserId and not owner:IsFriendsWith(player.UserId) then
				return false
			end
		end
	end

	playersLobbyId[player.UserId] = self._id
	table.insert(self.players, player)
	self:_PlayersUpdated()

	-- Teleport player inside of lobby
	PlayerHandler.Teleport(player, { part = self._lobbyModel.PrimaryPart })

	return true
end

function Lobby:_RemovePlayer(player: Player): boolean
	if playersLobbyId[player.UserId] ~= self._id then
		return false
	end

	local index = table.find(self.players, player)
	if not index then
		return false
	end

	playersLobbyId[player.UserId] = nil
	table.remove(self.players, index)
	self:_PlayersUpdated()

	-- Teleport player outside of lobby
	if not player:GetAttribute("isDead") then
		PlayerHandler.Teleport(
			player,
			{ position = (self._lobbyModel.PrimaryPart.CFrame * CFrame.new(0, 0, -15)).Position }
		)
	end

	return true
end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- GETTERS/SETTERS --------------------------------------------------------------------------------------------------

function Lobby:GetLobbyState(): LobbyTypes.LobbyState
	return {
		id = self._id,
		players = self.players,
		settings = self.settings,
		state = self._currentState and self._currentState.type or "Unknown",
	}
end

function Lobby:SetSettings(settings: LobbyTypes.LobbySettings?)
	self.settings = settings
	self:_FireLobbyUpdated()
end

function Lobby:HasPlayer(player: Player): boolean
	return playersLobbyId[player.UserId] == self._id
end

Lobby.RemovePlayer = Lobby._RemovePlayer

-- UI MANAGEMENT ----------------------------------------------------------------------------------------------------

function Lobby:ShowFrame(frameName: string)
	for _, child in pairs(self._billboardGui:GetChildren()) do
		if child:IsA("Frame") then
			child.Visible = child.Name == frameName
		end
	end
end

function Lobby:UpdateFrameChildren(frameName: string, updateFunc: (frame: Frame) -> ())
	local frame = self._billboardGui:FindFirstChild(frameName)
	if frame and frame:IsA("Frame") then
		updateFunc(frame)
	end
end

-- CONNECTIONS ----------------------------------------------------------------------------------------------------

function Lobby:AddTouchConnections()
	self:DestroyTouchConnections()
	for _, child in pairs(self._lobbyModel:GetChildren()) do
		if child:IsA("BasePart") and child.Name == "Wall" then
			table.insert(
				self._wallTouchConnections,
				child.Touched:Connect(function(hit)
					local character = hit.Parent
					if character and character:FindFirstChildWhichIsA("Humanoid") then
						local player = game.Players:GetPlayerFromCharacter(character)
						if player then
							self:_AddPlayer(player)
						end
					end
				end)
			)
		end
	end
end

function Lobby:DestroyTouchConnections()
	for _, connection in pairs(self._wallTouchConnections) do
		connection:Disconnect()
	end
	self._wallTouchConnections = {}
end

-- STATE MANAGEMENT ----------------------------------------------------------------------------------------------------

function Lobby:ChangeState(newState: string)
	if self._currentState and self._currentState.type == newState then
		return
	end

	if self._currentState then
		self._currentState:Destroy()
		self._currentState = nil
	end

	local stateClass = states[newState]
	if stateClass then
		self._currentState = stateClass.new(self)
	end
end

-- LOBBY CREATING ------------------------------------------------------------------------------------------------------

function Lobby:Create(playerFired: Player, lobbySettings: LobbyTypes.LobbySettings): boolean
	if #self.players == 0 or self.players[1] ~= playerFired or self._currentState.type ~= "Creating" then
		return false
	end

	return self._currentState:Create(playerFired, lobbySettings)
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Lobby
