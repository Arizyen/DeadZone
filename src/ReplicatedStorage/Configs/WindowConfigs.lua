local ThemeConfigs = require(script.Parent.ThemeConfigs)

return {
	maxWindowSizeX = ThemeConfigs.maxWindowSizeX or 0.58,
	maxWindowSizeY = ThemeConfigs.maxWindowSizeY or 0.68,
	menuWindowNames = {
		"Inventory",
		"Rewards",
		"Settings",
		"Shop",
		"GroupReward",
		"Statistics",
	},
	shopWindows = {},
	inventoryWindows = {},

	windowsRequiringBlur = {
		"StartScreen",
		"Teleporting",
		"GameOver",
	},
	windowsBlurSize = {} :: { [string]: number },
	defaultWindowBlurSize = 10,

	windowsAnimatingFOV = {
		"StartScreen",
		"Teleporting",
		"GameOver",
	},
	windowsFOVSize = {} :: { [string]: number },
	defaultWindowFOVSize = 80,

	windowsHidingHUD = {
		"StartScreen",
		"Teleporting",
		"GameOver",
	},
}
