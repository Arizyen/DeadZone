local LobbyHandler = {}

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

local LobbyMap = ServerStorage.Maps.Lobby

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine.Utils)
local Ports = require(script.Ports)
local Lobby = require(script.Lobby)

-- Handlers --------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
local LobbyTypes = require(ReplicatedTypes.Lobby)

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
local lobbies = {} :: { [string]: typeof(Lobby) }

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function LobbyHandler.Register(ports: Ports.Ports)
	Utils.Table.Dictionary.mergeMut(Ports, ports)
end

function LobbyHandler.Activate()
	LobbyMap.Parent = game.Workspace

	for _, lobby in pairs(LobbyMap.Lobbies:GetChildren()) do
		local newLobby = Lobby.new(lobby)

		newLobby.lobbyUpdated:Connect(function(state: LobbyTypes.LobbyState, playersLobbyId: { [number]: string })
			Ports.FireLobbyStateUpdate(state, playersLobbyId)
		end)

		lobbies[lobby.Name] = newLobby
	end
end

function LobbyHandler.GetAllLobbiesState(): { [string]: LobbyTypes.LobbyState }
	local states = {}

	for id, lobby in pairs(lobbies) do
		states[id] = lobby:GetLobbyState()
	end

	return states
end

function LobbyHandler.LeaveLobby(player: Player): boolean
	for _, lobby in pairs(lobbies) do
		if lobby:RemovePlayer(player) then
			return true
		end
	end

	return false
end

function LobbyHandler.CreateLobby(player: Player, settings: LobbyTypes.LobbySettings): (boolean, string?)
	if not (settings.difficulty and settings.maxPlayers and settings.friendsOnly ~= nil) then
		return false
	end

	-- Find the player's lobby
	for _, lobby in pairs(lobbies) do
		if lobby:HasPlayer(player) then
			return lobby:Create(player, settings)
		end
	end

	return false
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return LobbyHandler
