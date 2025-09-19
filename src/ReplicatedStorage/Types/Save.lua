local SaveTypes = {}

export type SaveInfo = {
	id: string?, -- Player UserId .. _ .. save # .. _ .. save cycle id
	chunks: number?, -- Number of data chunks --> Player USerId .. _ .. save # .. _ .. save cycle id .. _ .. chunk #
	name: string?,
	placeId: number,
	difficulty: number,
	nightsSurvived: number?,
	playtime: number?,
	createdAt: number?,
	updatedAt: number?,
	creatorId: number?,

	-- Supplementary info
	clockTime: number?, -- Time of day in a ratio of 24 (0-24)
}

export type PlayerState = {
	health: number,
	energy: number,
	position: Vector3?,
}

export type PlayerSave = {
	inventory: table, -- Player inventory
	state: PlayerState, -- Player state (health, position, etc.)
}

export type Save = {
	info: SaveInfo,
	builds: table, -- All players builds (placed items, structures, etc.)
	playersSave: { [number]: PlayerSave }, -- Key is player UserId
}

return SaveTypes
