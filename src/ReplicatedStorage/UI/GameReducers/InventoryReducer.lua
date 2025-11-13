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

local InventoryLogReducer = Rodux.createReducer({
	added = {} :: { [string]: number }, -- [key: string]: number }
	removed = {} :: { [string]: number }, -- [key: string]: number }
}, {
	ObjectAdded = function(state, action: { key: string, quantity: number })
		local newState = table.clone(state)

		newState.added = table.clone(newState.added) or {}
		newState.added[action.key] = (newState.added[action.key] or 0) + action.quantity

		return newState
	end,

	ObjectRemoved = function(state, action: { key: string, quantity: number })
		local newState = table.clone(state)

		newState.removed = table.clone(newState.removed) or {}
		newState.removed[action.key] = (newState.removed[action.key] or 0) + action.quantity

		return newState
	end,

	ClearObjectAddedLog = function(state, action: { key: string })
		local newState = table.clone(state)

		if newState.added[action.key] then
			newState.added = table.clone(newState.added) or {}
			newState.added[action.key] = nil
		end

		return newState
	end,

	ClearObjectRemovedLog = function(state, action: { key: string })
		local newState = table.clone(state)

		if newState.removed[action.key] then
			newState.removed = table.clone(newState.removed) or {}
			newState.removed[action.key] = nil
		end

		return newState
	end,
})

return InventoryLogReducer
