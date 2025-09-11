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
local ReplicatedBaseHandlers = ReplicatedPlaywooEngine:WaitForChild("BaseHandlers")

-- Modules -------------------------------------------------------------------
local Rodux = require(Packages:WaitForChild("Rodux"))
local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))

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

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local LobbyReducer = Rodux.createReducer({
	nil,
}, {
	UpdateLobbyState = function(state, action: { value: LobbyTypes.LobbyState })
		local newState = Utils.Table.Dictionary.copy(state) :: { [string]: LobbyTypes.LobbyState }
		newState[action.value.id] = Utils.Table.Dictionary.merge(newState[action.value.id] or {}, action.value)

		return newState
	end,

	UpdateLobbyStates = function(state, action: { value: { [string]: LobbyTypes.LobbyState } })
		local newState = Utils.Table.Dictionary.copy(state) :: { [string]: LobbyTypes.LobbyState }
		for id, lobbyState in pairs(action.value) do
			newState[id] = Utils.Table.Dictionary.merge(newState[id] or {}, lobbyState)
		end

		return newState
	end,
})

return LobbyReducer
