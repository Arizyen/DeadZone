local SaveTypes = {}

export type SaveInfo = {
	id: string, -- Player UserId .. _ .. save #
	chunks: number, -- Number of data chunks --> Player USerId .. _ .. save # .. _ .. chunk #
	name: string,
	difficulty: number,
	nightsSurvived: number,
	playtime: number,
	createdAt: number,
	updatedAt: number,
	creatorId: number,
}

return SaveTypes
