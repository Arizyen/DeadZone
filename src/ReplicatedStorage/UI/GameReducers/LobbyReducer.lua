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
local LobbyTypes = require(ReplicatedTypes:WaitForChild("LobbyTypes"))

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local LobbyReducer = Rodux.createReducer({
	lobbyStates = {} :: { [string]: LobbyTypes.LobbyState },
	lobbyCreationTimeLimit = 0 :: number, -- os.clock() time
	playersLobbyId = {} :: { [string]: string }, -- ["player.UserId"] = lobbyId
	currentLobbyId = nil :: string?,
}, {
	UpdateLobbyState = function(state, action: { value: LobbyTypes.LobbyState })
		local newState = table.clone(state)

		-- Merge the existing lobby state with the new state
		newState.lobbyStates = table.clone(state.lobbyStates)
		newState.lobbyStates[action.value.id] = Utils.Table.Dictionary.merge(
			newState.lobbyStates[action.value.id] or {},
			action.value
		) :: { [string]: LobbyTypes.LobbyState }

		return newState
	end,

	UpdateLobbyStates = function(state, action: { value: { [string]: LobbyTypes.LobbyState } })
		local newState = table.clone(state)
		for id, lobbyState in pairs(action.value) do
			newState.lobbyStates[id] =
				Utils.Table.Dictionary.merge(newState.lobbyStates[id] or {}, lobbyState) :: { [string]: LobbyTypes.LobbyState }
		end

		return newState
	end,

	UpdatePlayersLobbyId = function(state, action: { value: { [string]: string } })
		local newState = table.clone(state)
		newState.playersLobbyId = table.clone(action.value)
		newState.currentLobbyId = action.value[tostring(game.Players.LocalPlayer.UserId)]

		return newState
	end,

	SetLobbyCreationTimeLimit = function(state, action: { value: number })
		local newState = table.clone(state)
		newState.lobbyCreationTimeLimit = action.value

		return newState
	end,
})

return LobbyReducer
