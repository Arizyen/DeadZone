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

-- Types ---------------------------------------------------------------------------
local GameTypes = require(ReplicatedTypes:WaitForChild("GameTypes"))

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local GameStateReducer = Rodux.createReducer({
	difficulty = 1,
	isDay = false,
	nightsSurvived = 0,
	zombiesLeft = 0,
	skipVotes = 0,
}, {
	SetGameState = function(state, action: { value: GameTypes.GameState })
		return Utils.Table.Dictionary.merge(state, action.value)
	end,
})

return GameStateReducer
