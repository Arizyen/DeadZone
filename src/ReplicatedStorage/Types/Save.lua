local SaveTypes = {}

export type SaveInfo = {
	id: string, -- Player UserId .. _ .. save # .. _ .. save cycle id
	chunks: number, -- Number of data chunks --> Player USerId .. _ .. save # .. _ .. save cycle id .. _ .. chunk #
	name: string,
	difficulty: number,
	nightsSurvived: number,
	playtime: number,
	createdAt: number,
	updatedAt: number,
	creatorId: number,
}

return SaveTypes
