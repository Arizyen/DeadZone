local Lobby = {}
Lobby.__index = Lobby

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

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
local states = {
	Waiting = Waiting,
	Creating = Creating,
	Starting = Starting,
	Teleporting = Teleporting,
}

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

	-- Tables
	self._players = {} :: { Player }
	self._ignorePlayers = {} :: { [number]: Player } -- UserId: boolean

	-- Instances
	self._lobbyModel = lobbyModel
	self._billboardGui = lobbyModel.PrimaryPart.BillboardGui
	self._currentState = nil :: typeof(Waiting) | typeof(Creating) | typeof(Starting) | typeof(Teleporting) | nil

	-- Signals
	self.playersUpdated = Utils.Signals.Create() -- Fires {Player}

	self:_Init()

	return self
end

function Lobby:_Init()
	self:_AddTouchConnections()

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

-- CONSTRUCTORS ----------------------------------------------------------------------------------------------------

function Lobby:GetPlayers(): { Player }
	return self._players
end

-- CONNECTIONS ----------------------------------------------------------------------------------------------------

function Lobby:_AddTouchConnections()
	for _, child in pairs(self._lobbyModel:GetChildren()) do
		if child:IsA("BasePart") and child.Name == "Wall" then
			child.Touched:Connect(function(hit)
				local character = hit.Parent
				if character and character:FindFirstChildWhichIsA("Humanoid") then
					local player = game.Players:GetPlayerFromCharacter(character)
					if player then
						self:_AddPlayer(player)
					end
				end
			end)
		end
	end
end

-- PLAYER MANAGEMENT ---------------------------------------------------------------------------------------------------

function Lobby:_PlayersUpdated()
	self.playersUpdated:Fire(self._players)
end

function Lobby:_AddPlayer(player: Player)
	if self._ignorePlayers[player.UserId] or player:GetAttribute("isDead") then
		return
	end

	self._ignorePlayers[player.UserId] = true
	table.insert(self._players, player)
	self:_PlayersUpdated()

	-- Teleport player inside of lobby
	PlayerHandler.Teleport(player, { part = self._lobbyModel.PrimaryPart })
end

function Lobby:_RemovePlayer(player: Player)
	local index = table.find(self._players, player)
	if not index then
		return
	end

	self._ignorePlayers[player.UserId] = nil
	table.remove(self._players, index)
	self:_PlayersUpdated()

	-- Teleport player outside of lobby
	if not player:GetAttribute("isDead") then
		PlayerHandler.Teleport(
			player,
			{ position = (self._lobbyModel.PrimaryPart.CFrame * CFrame.new(0, 0, -15)).Position }
		)
	end
end

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

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

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

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Lobby
