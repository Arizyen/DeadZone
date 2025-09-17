local SaveTypes = {}

export type SaveInfo = {
	id: string, -- Player UserId .. _ .. save # .. _ .. save cycle id
	placeId: number,
	chunks: number, -- Number of data chunks --> Player USerId .. _ .. save # .. _ .. save cycle id .. _ .. chunk #
	name: string,
	difficulty: number,
	nightsSurvived: number,
	playtime: number,
	createdAt: number,
	updatedAt: number,
	creatorId: number,
}

export type PlayerState = {
	health: number,
	hunger: number,
	thirst: number,
	position: Vector3,
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
