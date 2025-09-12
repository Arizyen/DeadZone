local LobbyHandler = {}

-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local ReplicatedSource = ReplicatedStorage:WaitForChild("Source")
local ReplicatedPlaywooEngine = ReplicatedSource:WaitForChild("PlaywooEngine")
local ReplicatedConfigs = ReplicatedSource:WaitForChild("Configs")
local ReplicatedInfo = ReplicatedSource:WaitForChild("Info")
local ReplicatedTypes = ReplicatedSource:WaitForChild("Types")
local ReplicatedBaseModules = ReplicatedPlaywooEngine:WaitForChild("BaseModules")
local ReplicatedGameModules = ReplicatedSource:WaitForChild("GameModules")
local ReplicatedBaseHandlers = ReplicatedPlaywooEngine:WaitForChild("BaseHandlers")
local ReplicatedGameHandlers = ReplicatedSource:WaitForChild("GameHandlers")

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))
local Ports = require(script:WaitForChild("Ports"))

-- Handlers ----------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
local LobbyTypes = require(ReplicatedTypes:WaitForChild("Lobby"))

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function GetAllLobbiesState()
	Ports.GetAllLobbiesState():andThen(function(states: { [string]: LobbyTypes.LobbyState })
		Utils.Signals.Fire("DispatchAction", {
			type = "UpdateLobbyStates",
			value = states,
		})
	end)
end

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function LobbyHandler.Register(ports)
	Utils.Table.Dictionary.mergeMut(Ports, ports)
end

function LobbyHandler.Activate() end

function LobbyHandler.UpdateLobbyState(lobbyState: LobbyTypes.LobbyState)
	Utils.Signals.Fire("DispatchAction", {
		type = "UpdateLobbyState",
		value = lobbyState,
	})

	-- Show CreateLobby window if player is in a lobby that is in "Creating" state
	if lobbyState.state == "Creating" and lobbyState.players[1] == game.Players.LocalPlayer then
		Utils.Signals.Fire("DispatchAction", {
			type = "ShowWindow",
			value = "CreateLobby",
		})
	end
end

function LobbyHandler.LeaveLobby()
	Ports.LeaveLobby()
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
Utils.Signals.Once("ClientStarted", function()
	GetAllLobbiesState()
end)

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return LobbyHandler
