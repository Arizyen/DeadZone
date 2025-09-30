return {
	allKeys = {
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
		"lightweight",
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
			"lightweight",
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
		bluntForce = { name = "Blunt Force", type = "combat", description = "Melee weapons deal 15% more damage" },
		rapidStrikes = { name = "Rapid Strikes", type = "combat", description = "Melee attacks are 15% faster" },
		enduranceTraining = {
			name = "Endurance Training",
			type = "combat",
			description = "Sprinting drains 10% less stamina",
		},
		sharpshooter = {
			name = "Zombie Slayer",
			type = "combat",
			description = "Afflict +10% ranged damage to zombies",
		},

		-- Survival perks
		ironLungs = { name = "Iron Lungs", type = "survival", description = "+20 stamina" },
		hpRegen = { name = "HP Regen", type = "survival", description = "+10% HP regeneration speed" },
		thickSkin = { name = "Thick Skin", type = "survival", description = "Reduce incoming damage by 5%" },
		painTolerance = {
			name = "Pain Tolerance",
			type = "survival",
			description = "50% less fall damage taken",
		},
		lastStand = { name = "Last Stand", type = "survival", description = "Deal 20% more damage when below 20% HP" },

		-- Resource perks
		efficientMiner = { name = "Efficient Miner", type = "resource", description = "Mine 15% faster" },
		efficientLumberjack = { name = "Efficient Lumberjack", type = "resource", description = "Chop 15% faster" },
		efficientCrafter = {
			name = "Efficient Crafter",
			type = "resource",
			description = "Crafting costs 20% less resources",
		},
		lightweight = { name = "Lightweight", type = "resource", description = "+10 inventory slots" },
		ammoSaver = { name = "Ammo Saver", type = "resource", description = "5% chance of not consuming ammo" },

		-- Utility perks
		packRat = { name = "Pack Rat", type = "utility", description = "+3 hotbar slots" },
		quickFeet = { name = "Quick Feet", type = "utility", description = "+15% movement speed" },
		swiftHands = { name = "Swift Hands", type = "utility", description = "+15% reload speed" },
		medicTraining = { name = "Medic Training", type = "utility", description = "Revive teammates 40% faster" },
		quickLearner = { name = "Quick Learner", type = "utility", description = "Gain 10% more XP" },
	},
}
