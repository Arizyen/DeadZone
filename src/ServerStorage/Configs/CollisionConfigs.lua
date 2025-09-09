return {
	COLLISION_GROUPS = {
		"PlayersCollide",
		"PlayersNoCollide",
		"PlayersNoCollideRaycast",
		"PlayersDead",
		"NPCNoCollide",
		"CollideOnlyWithPlayers",
		"ObjectsNoCollideWithAll",
		"Tower",
		"TowerRaycast",
		"Lava",
	}, -- Must place these in order (loops through all collision groups and sets collision to false if not included in the list)
	COLLISION_GROUP_COLLIDABLE = {
		PlayersCollide = { "Default", "PlayersCollide" },
		PlayersNoCollide = { "Default" },
		PlayersNoCollideRaycast = { "PlayersNoCollide" },
		NPCNoCollide = { "Default" },
		CollideOnlyWithPlayers = { "PlayersCollide", "PlayersNoCollide" },
		ObjectsNoCollideWithAll = {},
		Tower = { "Default", "PlayersNoCollide", "PlayersCollide" },
		TowerRaycast = { "Tower" },
		PlayersDead = { "Default", "PlayersNoCollide", "PlayersCollide" },
		Lava = { "PlayersDead" },
	},
}
