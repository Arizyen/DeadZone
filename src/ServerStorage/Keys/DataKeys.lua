local Keys = {
	-- VALUES ----------------------------------
	numbers = {
		"rebirths",

		-- "hp", -- In Default DataKeys
		-- "maxHp", -- In Default DataKeys
		"energy",
		"maxEnergy",
	},
	booleans = {},
	strings = {},
	tables = {
		"saves",
		"inventoryPVP",
		"inventory",
		"playerStatePVP",
		"playerState", -- health, energy, thirst, position, etc.
	},

	-- CONFIGS ----------------------------------
	defaultValues = {},
	onLeaveValues = {
		inventory = {},
	},
	keysToResetOnLoad = {
		"inventory", -- Inventory is initialized on load (depending on save or if in PVP game)
		"playerState", -- Player state is initialized on load (depending on save or if in PVP game)
	},
	keysNotToReplicate = {},
	keysToShareWithOthers = {},
}

return Keys
