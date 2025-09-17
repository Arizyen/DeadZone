local Keys = {
	-- VALUES ----------------------------------
	numbers = {
		"rebirths",
	},
	booleans = {},
	strings = {},
	tables = {
		"saves",
		"backpackPVP",
		"backpack",
	},

	-- CONFIGS ----------------------------------
	defaultValues = {},
	onLeaveValues = {
		backpack = {},
	},
	keysToResetOnLoad = {
		"backpack", -- Backpack is initialized on load (depending on save or if in PVP game)
	},
	keysNotToReplicate = {},
	keysToShareWithOthers = {},
}

return Keys
