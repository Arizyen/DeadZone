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
	windowsCustomMessageProperties = {
		Inventory = {
			Position = UDim2.fromScale(0.7, 1.05),
			Size = UDim2.fromScale(0.4, 0.1),
		},
	},
	windowsCustomMessageEndPosition = {
		Inventory = UDim2.fromScale(0.7, 0.685),
	},
	inGameWindowsCustomMessageEndPosition = {
		Achievements = UDim2.fromScale(0.5, 0.8),
		Statistics = UDim2.fromScale(0.5, 0.8),
		Store = UDim2.fromScale(0.5, 0.8),
		Skills = UDim2.fromScale(0.5, 0.8),
		DailyReward = UDim2.fromScale(0.5, 0.8),
		Settings = UDim2.fromScale(0.5, 0.8),
		GroupReward = UDim2.fromScale(0.5, 0.8),
	},
	notInGameWindowsCustomMessageEndPosition = {
		Achievements = UDim2.fromScale(0.5, 0.85),
		Statistics = UDim2.fromScale(0.5, 0.85),
		Store = UDim2.fromScale(0.5, 0.85),
		Skills = UDim2.fromScale(0.5, 0.85),
		DailyReward = UDim2.fromScale(0.5, 0.85),
		Settings = UDim2.fromScale(0.5, 0.85),
		GroupReward = UDim2.fromScale(0.5, 0.85),
	},
}
