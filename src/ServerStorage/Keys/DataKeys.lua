local Keys = {
	-- VALUES ----------------------------------
	numbers = {
		"rebirths",
	},
	booleans = {},
	strings = {},
	tables = {
		"saves",
		"playerSavePVP",
		"playerState", -- health, energy, thirst, position, etc.
		"inventory",
		"loadout",
		"hotbar",
	},

	-- CONFIGS ----------------------------------
	defaultValues = {
		vitals = {
			hp = 100,
			maxHP = 100,
			energy = 100,
			maxEnergy = 100,
		},
	},
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
