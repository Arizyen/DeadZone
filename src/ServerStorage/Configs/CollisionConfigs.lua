return {
	COLLISION_GROUPS = {
		"PlayersCollide",
		"PlayersNoCollide",
		"PlayersNoCollideRaycast",
		"PlayersDead",
		"NPCNoCollide",
		"CollideOnlyWithPlayers",
		"ObjectsNoCollideWithAll",
		"Resource",
		"Zombie",
	}, -- Must place these in order (loops through all collision groups and sets collision to false if not included in the list)
	COLLISION_GROUP_COLLIDABLE = {
		PlayersCollide = { "Default", "PlayersCollide" },
		PlayersNoCollide = { "Default" },
		PlayersNoCollideRaycast = { "PlayersNoCollide" },
		NPCNoCollide = { "Default" },
		CollideOnlyWithPlayers = { "PlayersCollide", "PlayersNoCollide" },
		ObjectsNoCollideWithAll = {},
		PlayersDead = { "Default", "PlayersDead", "PlayersCollide", "PlayersNoCollide" },
		Resource = { "Default", "Resource", "PlayersCollide", "PlayersNoCollide" },
		Zombie = { "Default", "Zombie", "Resource", "PlayersCollide", "PlayersNoCollide" },
	},
}
