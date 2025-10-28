return {
	keys = {
		-- Combat perks
		"adrenalineMelee",
		"bluntForce",
		"rapidStrikes",
		"enduranceTraining",
		"sharpshooter",

		-- Survival perks
		"ironLungs",
		"hpRegen",
		"thickSkin",
		"painTolerance",
		"lastStand",

		-- Resource perks
		"efficientMiner",
		"efficientLumberjack",
		"efficientCrafter",
		"packMule",
		"ammoSaver",

		-- Utility perks
		"packRat",
		"quickFeet",
		"swiftHands",
		"medicTraining",
		"quickLearner",
	},
	byType = {
		combat = {
			"adrenalineMelee",
			"bluntForce",
			"rapidStrikes",
			"enduranceTraining",
			"sharpshooter",
		},
		survival = {
			"ironLungs",
			"hpRegen",
			"thickSkin",
			"painTolerance",
			"lastStand",
		},
		resource = {
			"efficientMiner",
			"efficientLumberjack",
			"efficientCrafter",
			"packMule",
			"ammoSaver",
		},
		utility = {
			"packRat",
			"quickFeet",
			"swiftHands",
			"medicTraining",
			"quickLearner",
		},
	},
	byKey = {
		-- Combat perks
		adrenalineMelee = { name = "Adrenaline Melee", type = "combat", description = "Gain 20 stamina on melee kill" },
		bluntForce = {
			name = "Blunt Force",
			type = "combat",
			description = "Melee weapons deal 15% more damage",
			value = 0.15,
		},
		rapidStrikes = {
			name = "Rapid Strikes",
			type = "combat",
			description = "Melee attacks are 15% faster",
			value = 0.15,
		},
		enduranceTraining = {
			name = "Endurance Training",
			type = "combat",
			description = "Sprinting drains 10% less stamina",
			value = 0.1,
		},
		sharpshooter = {
			name = "Zombie Slayer",
			type = "combat",
			description = "Afflict +10% ranged damage to zombies",
			value = 0.1,
		},

		-- Survival perks
		ironLungs = { name = "Iron Lungs", type = "survival", description = "+25 stamina", value = 25 },
		hpRegen = { name = "HP Regen", type = "survival", description = "+10% HP regeneration speed", value = 0.1 },
		thickSkin = {
			name = "Thick Skin",
			type = "survival",
			description = "Reduce incoming damage by 5%",
			value = 0.05,
		},
		painTolerance = {
			name = "Pain Tolerance",
			type = "survival",
			description = "50% less fall damage taken",
			value = 0.5,
		},
		lastStand = {
			name = "Last Stand",
			type = "survival",
			description = "Deal 20% more damage when below 20% HP",
			value = 0.2,
		},

		-- Resource perks
		efficientMiner = { name = "Efficient Miner", type = "resource", description = "Mine 15% faster", value = 0.15 },
		efficientLumberjack = {
			name = "Efficient Lumberjack",
			type = "resource",
			description = "Chop 15% faster",
			value = 0.15,
		},
		efficientCrafter = {
			name = "Efficient Crafter",
			type = "resource",
			description = "Crafting costs 20% less resources",
			value = 0.2,
		},
		packMule = { name = "Pack Mule", type = "resource", description = "+100 inventory capacity", value = 100 },
		ammoSaver = {
			name = "Ammo Saver",
			type = "resource",
			description = "5% chance of not consuming ammo",
			value = 0.05,
		},

		-- Utility perks
		packRat = { name = "Pack Rat", type = "utility", description = "+3 hotbar slots", value = 3 },
		quickFeet = { name = "Quick Feet", type = "utility", description = "+15% movement speed", value = 0.15 },
		swiftHands = { name = "Swift Hands", type = "utility", description = "+15% reload speed", value = 0.15 },
		medicTraining = {
			name = "Medic Training",
			type = "utility",
			description = "Revive teammates 40% faster",
			value = 0.4,
		},
		quickLearner = { name = "Quick Learner", type = "utility", description = "Gain 10% more XP", value = 0.1 },
	},
}
