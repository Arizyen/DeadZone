local GameTypes = {}

export type GameState = {
	difficulty: number,
	isDay: boolean,
	nightsSurvived: number,
	zombiesLeft: number,
	skipVotes: number,
}

return GameTypes
