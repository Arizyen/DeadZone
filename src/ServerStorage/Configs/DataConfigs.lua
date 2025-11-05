local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedSource = ReplicatedStorage.Source
local ReplicatedTypes = ReplicatedSource.Types
local ReplicatedConfigs = ReplicatedSource.Configs

local SaveTypes = require(ReplicatedTypes.SaveTypes)
local ObjectTypes = require(ReplicatedTypes.ObjectTypes)
local MovementConfigs = require(ReplicatedConfigs.MovementConfigs)
local GameConfigs = require(ReplicatedConfigs.GameConfigs)

local DataConfigs = {
	-- Default data is set on each player data load if the key does not exist
	DEFAULT_DATA = {
		_inUse = true,

		achievements = {
			claimed = {} :: { [string]: boolean },
			claimable = {} :: { [string]: boolean },
		},
		ads = {
			shownTimes = {} :: { [string]: number }, -- adType = timesShown
		},
		avatarAssets = {
			owned = {} :: { [string]: boolean }, -- tostring(assetId) = true
			purchased = {} :: { [string]: boolean }, -- tostring(assetId) = true
		},
		badges = {} :: { [string]: boolean },
		currencies = {
			coins = 0,
			gems = 0,
		},
		dailyRewards = {
			streak = 0,
			claimed = {} :: { [string]: number }, -- day1, day2, etc... = timestamp claimed
		},
		gamepasses = {} :: { [string]: boolean },

		-- Inventory keys
		capacityUsed = 0, -- current weight in the inventory
		hotbar = {} :: { [string]: string }, -- slotId (slot1) = objectId
		inventory = {} :: { [string]: string }, -- slotId (slot1) = objectId
		backpack = {} :: ObjectTypes.WearableCopy, -- currently equipped backpack
		loadout = {} :: { [string]: string }, -- slotId = itemName
		objects = {} :: { [string]: ObjectTypes.ObjectCopy }, -- objectId = object
		objectsCategorized = {} :: { [string]: { string } }, -- key = { objectId }

		moderation = {
			kickedReasons = {} :: { string },
			permanentBan = false,
			-- bannedV<version> = timestamp
			-- exploitingIntV<version> = timestamp
			playersBanned = {} :: { number: number }, -- playerUserId = timestamp
		},
		playerState = {} :: SaveTypes.PlayerState,
		playTimeRewards = {
			claimed = {} :: { [number]: boolean },
			lastUpdatedTime = function()
				return os.time()
			end,
			timeResetting = 0, -- After user completes the play time rewards, they are given a delay before it resets
			timeAccumulated = 0,
		},
		profile = {
			newPlayer = true,
			createdAt = function()
				return os.time()
			end,
			lastLogin = function()
				return os.time()
			end,
			dayLoggedInStreak = 0,
			dayLoggedInTimes = {},
			-- Data store save timestamps
			lastSavedTimes = {} :: { [string]: number }, -- dataStoreName = timestamp
		},
		saves = {} :: { [number]: SaveTypes.SaveInfo }, -- saveNumber = SaveInfo
		sessionState = {
			gameStartAt = function()
				return os.time()
			end,
			gameEndAt = function()
				return os.time()
			end,

			newSave = false,

			-- Session statistics
			zombieKills = 0,
		},
		settings = {
			musicVolume = 55,
			soundEffectsVolume = 100,
			rainbowNametagEnabled = true,
			hideOthersNametag = false,
			hideLocalNametag = true,
		},
		specialRewards = {
			groupRewardClaimed = false,
			premiumRewardClaimed = false,
		},
		stats = {
			level = 1,
			xp = 0,
			maxXP = 1000,
			rebirths = 0,

			-- Stamina
			maxStamina = MovementConfigs.STAMINA,
			staminaConsumptionRate = MovementConfigs.STAMINA_CONSUMPTION_RATE,

			-- HP
			hpRegenFactor = 1, -- Multiplier (1 = normal regen)
			damageFactor = 1, -- Multiplier (1 = normal damage taken)
			fallDamageFactor = 1, -- Multiplier (1 = normal fall damage)

			-- Speed
			sprintSpeed = MovementConfigs.MAX_WALK_SPEED,
			reloadSpeedFactor = 1, -- Multiplier (1 = normal speed)
			meleeSpeedFactor = 1, -- Multiplier (1 = normal speed)

			-- Attack
			meleeDamageFactor = 1, -- Multiplier (1 = normal damage)
			rangedDamageFactor = 1, -- Multiplier (1 = normal damage)

			-- XP
			xpFactor = 1, -- Multiplier (1 = normal xp gain)

			-- Resource
			miningSpeedFactor = 1, -- Multiplier (1 = normal speed)
			choppingSpeedFactor = 1, -- Multiplier (1 = normal speed)
			craftingCostFactor = 1, -- Multiplier (1 = normal cost)

			-- Inventory
			inventoryCapacity = GameConfigs.INVENTORY_CAPACITY, -- Maximum weight capacity
			hotbarSlots = GameConfigs.HOTBAR_SLOTS, -- Number of hotbar slots unlocked

			-- Miscellaneous
			revivalTimeFactor = 1, -- Multiplier (1 = normal speed)
			ammoSaveLuck = 0, -- Percentage (0 = normal chance)
		},
		perks = {} :: { [string]: boolean }, -- perkName = true
		statistics = {
			-- Playtime statistics
			gameStartTime = function()
				return os.time()
			end,
			gameEndTime = function()
				return os.time()
			end,
			totalSessions = 1,
			totalPlayTime = 0,
			totalPlayTimeOnStart = function(data)
				return data.defaultStatistics and data.defaultStatistics.totalPlayTime or 0
			end,

			-- Currencies statistics
			totalCoins = 0,
			totalGems = 0,

			-- Spending statistics
			robux = 0,
			robuxWeekly = 0,

			-- Survival statistics
			daysSurvivedEasy = 0,
			daysSurvivedEasyWeekly = 0,
			daysSurvivedMid = 0,
			daysSurvivedMidWeekly = 0,
			daysSurvivedHard = 0,
			daysSurvivedHardWeekly = 0,

			-- Combat statistics
			zombiesKilled = 0,
			meleeKills = 0,
			rangedKills = 0,
		},
	},

	-- Values to reset when player's data is loaded (this lets DEFAULT_DATA set default values)
	ON_LOAD_RESET_PATHS = {
		{ "_inUse" },
		{ "sessionState", "gameStartAt" },
		{ "sessionState", "newSave" },
		{ "sessionState", "zombieKills" },
		{ "statistics", "totalPlayTimeOnStart" },
		{ "hotbar" },
		{ "inventory" },
		{ "objects" },
		{ "objectsCategorized" },
		{ "loadout" },
		{ "playerState" },
	},

	-- Values to set when player leaves
	ON_LEAVE_PATH_VALUES = {
		{ path = { "_inUse" }, value = false },
		{
			path = { "profile", "lastLogin" },
			value = function(data)
				return data.sessionState and data.sessionState.gameStartAt or os.time()
			end,
		},
		{
			path = { "statistics", "gameEndTime" },
			value = function()
				return os.time()
			end,
		},
	},

	-- Values/paths to share with other players
	SHARED_PATHS = {
		-- { "stats" },
		-- { "statistics", "createdAt" },
		-- { "statistics", "totalPlayTime" },
		{ "gamepasses" },
	},
	SHARABLE_PATHS_CONCATENATED = {} :: { [string]: boolean }, -- Populated on module load

	-- Non-replicated values/paths (these will not be sent to the player)
	NON_REPLICATED_PATHS = {},
	NON_REPLICATED_PATHS_CONCATENATED = {} :: { [string]: boolean }, -- Populated on module load
}

-- FUNCTIONS ----------------------------------------------------------------------------------------------------

-- Populates concatenated paths for faster lookup
local function PopulateConcatenatedPaths()
	for _, path in pairs(DataConfigs.SHARED_PATHS) do
		DataConfigs.SHARABLE_PATHS_CONCATENATED[table.concat(path)] = true
	end

	for _, path in pairs(DataConfigs.NON_REPLICATED_PATHS) do
		DataConfigs.NON_REPLICATED_PATHS_CONCATENATED[table.concat(path)] = true
	end
end

PopulateConcatenatedPaths()

return DataConfigs
