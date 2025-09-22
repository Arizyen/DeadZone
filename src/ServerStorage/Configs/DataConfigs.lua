local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedSource = ReplicatedStorage:WaitForChild("Source")
local ReplicatedTypes = ReplicatedSource:WaitForChild("Types")
local SaveTypes = require(ReplicatedTypes:WaitForChild("Save"))

return {
	-- Default data is set on each player data load if the key does not exist
	DEFAULT_DATA = {
		_inUse = true, -- Prevents data from being loaded on multiple servers at once

		achievements = {
			claimedAchievements = {} :: { [string]: boolean },
			claimableAchievements = {} :: { [string]: boolean },
		},
		badges = {} :: { [string]: boolean },
		dailyRewards = {
			dayStreak = 0,
			rewardsClaimed = {} :: { [string]: number }, -- day1, day2, etc... = timestamp claimed
		},
		gamepasses = {} :: { [string]: boolean },
		hotbar = {} :: { [number]: string }, -- index = itemName
		inventory = {} :: { [string]: number }, -- itemName = amount
		loadout = {} :: { [string]: string }, -- slotName = itemName
		moderation = {
			kickedReasons = {} :: { string },
		},
		playTimeRewards = {
			timeResetting = 0, -- After user completes the play time rewards, they are given a delay before it resets
			rewardsClaimed = {} :: { [number]: boolean },
			timeAccumulated = 0,
			lastUpdatedTime = function()
				return os.time()
			end,
		},
		saves = {} :: { [number]: SaveTypes.Save }, -- saveNumber = Save
		settings = {
			musicVolume = 55,
			soundEffectsVolume = 100,
			rainbowNametagEnabled = true,
		},
		specialRewards = {
			groupRewardClaimed = false,
			premiumRewardClaimed = false,
		},
		stats = {
			level = 1,
			xp = 0,
			maxXP = 1000,
			energy = 100,
			maxEnergy = 100,
			rebirths = 0,
			playerState = {} :: SaveTypes.PlayerState,
		},
		statistics = {
			-- Playtime stats
			firstPlayedTime = function()
				return os.time()
			end,
			gameStartTime = function()
				return os.time()
			end,
			gameEndTime = function()
				return os.time()
			end,
			previousGameStartTime = function()
				return os.time()
			end,
			totalPlayTime = 0,
			totalPlayTimeOnStart = function(data)
				return data.defaultStatistics and data.defaultStatistics.totalPlayTime or 0
			end,

			-- Day streak
			dayLoggedInStreak = 0,
			dayLoggedInTimes = {},

			-- Data store save timestamps
			lastSavedTimes = {} :: { [string]: number }, -- dataStoreName = timestamp
		},
		vitals = {
			hp = 100,
			maxHP = 100,
		},
	},

	-- Values to set when player leaves
	ON_LEAVE_PATH_VALUES = {
		{ path = { "_inUse" }, value = false },
		{
			path = { "statistics", "previousGameStartTime" },
			value = function(data)
				return data.statistics and data.statistics.gameStartTime or os.time()
			end,
		},
		{
			path = { "statistics", "gameEndTime" },
			value = function()
				return os.time()
			end,
		},
	},

	-- Values to reset when player's data is loaded (this lets DEFAULT_DATA set default values)
	ON_LOAD_RESET_PATHS = {
		{ "_inUse" },
		{ "statistics", "gameStartTime" },
		{ "statistics", "totalPlayTimeOnStart" },
		{ "inventory" },
		{ "hotbar" },
		{ "loadout" },
		{ "stats", "playerState" },
	},

	-- Values/paths to share with other players
	PATHS_TO_SHARE_WITH_OTHERS = {
		stats = true,
		statistics = {
			firstPlayedTime = true,
			totalPlayTime = true,
		},
		gamepasses = true,
	},

	-- Non-replicated values/paths (these will not be sent to the player)
	NON_REPLICATED_PATHS = {},
}
