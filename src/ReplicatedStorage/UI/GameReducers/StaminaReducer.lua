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

local StaminaReducer = Rodux.createReducer({
	stamina = 100,
	isHoldingSprint = false,
}, {
	SetStaminaState = function(state, action: { value: { stamina: number, isHoldingSprint: boolean } })
		return Utils.Table.Dictionary.merge(state, action.value)
	end,
})

return StaminaReducer
