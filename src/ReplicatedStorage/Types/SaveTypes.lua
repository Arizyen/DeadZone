local SaveTypes = {}

local ObjectTypes = require(script.Parent.ObjectTypes)

export type SaveInfo = {
	id: string?, -- Player UserId .. _ .. save # .. _ .. save cycle #
	chunksCount: number?, -- Number of data chunks --> Player USerId .. _ .. save # .. _ .. save cycle # .. _ .. chunk #
	name: string?,
	placeId: number,
	difficulty: number,
	nightsSurvived: number?,
	zombiesLeft: number?,
	playtime: number?,
	createdAt: number?,
	updatedAt: number?,
	creatorId: number?,

	-- Supplementary info
	clockTime: number?, -- Time of day in a ratio of 24 (0-24)
}

export type PlayerState = {
	hp: number,
	position: string?, -- Serialized Vector3
}

export type PlayerSave = {
	userId: number, -- Player UserId
	hotbar: { [string]: string }, -- slotId (slot1) = objectId
	inventory: { [string]: string }, -- slotId (slot1) = objectId
	loadout: { [string]: string }, -- slotName = itemName
	objects: { [string]: ObjectTypes.Object }, -- objectId = object
	objectsCategorized: { [string]: { string } }, -- key = { objectId }
	state: PlayerState, -- Player state (hp, position, etc.)
	zombieKills: number, -- Number of zombies killed
}

export type Save = {
	info: SaveInfo,
	builds: table, -- All players builds (placed items, structures, etc.)
	playersSave: { [number]: PlayerSave }, -- Key is player UserId
}

return SaveTypes
