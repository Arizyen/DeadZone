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
local MessageHandler = require(ReplicatedBaseHandlers:WaitForChild("MessageHandler"))

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local LobbyConfigs = require(ReplicatedConfigs:WaitForChild("LobbyConfigs"))

-- Types ---------------------------------------------------------------------------
local LobbyTypes = require(ReplicatedTypes:WaitForChild("LobbyTypes"))

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

function LobbyHandler.UpdateLobbyState(lobbyState: LobbyTypes.LobbyState, playersLobbyId: { [number]: string })
	Utils.Signals.Fire("DispatchAction", {
		type = "UpdateLobbyState",
		value = lobbyState,
	})
	Utils.Signals.Fire("DispatchAction", {
		type = "UpdatePlayersLobbyId",
		value = playersLobbyId,
	})

	-- Show CreateLobby window if player is in a lobby that is in "Creating" state
	if
		lobbyState.state == "Creating"
		and lobbyState.players[1] == game.Players.LocalPlayer
		and not lobbyState.settingsUpdated
	then
		Utils.Signals.Fire("DispatchAction", {
			type = "SetLobbyCreationTimeLimit",
			value = os.clock() + LobbyConfigs.MAX_TIME_WAIT_LOBBY_CREATION,
		})
		Utils.Signals.Fire("DispatchAction", {
			type = "ShowWindow",
			value = "LobbyCreate",
		})
	end
end

function LobbyHandler.LeaveLobby()
	Ports.LeaveLobby():andThen(function(success: boolean)
		if not success then
			MessageHandler.ShowMessage("Failed to leave lobby.", "Error")
		end
	end)
end

function LobbyHandler.CreateLobby(settings: LobbyTypes.LobbySettings)
	Ports.CreateLobby(settings):andThen(function(success: boolean)
		if success then
			Utils.Signals.Fire("DispatchAction", {
				type = "CloseWindow",
				value = "LobbyCreate",
			})
			Utils.Signals.Fire("DispatchAction", {
				type = "CloseWindow",
				value = "LobbyNew",
			})
			Utils.Signals.Fire("DispatchAction", {
				type = "CloseWindow",
				value = "LobbyLoad",
			})
		else
			MessageHandler.ShowMessage("Failed to create lobby.", "Error")
		end
	end)
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
