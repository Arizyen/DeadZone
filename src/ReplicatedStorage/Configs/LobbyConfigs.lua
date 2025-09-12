local LobbyConfigs = {
	MIN_PLAYERS = 1,
	MAX_PLAYERS = 12,

	DEFAULT_DIFFICULTY = 1,
	MIN_DIFFICULTY = 1,
	MAX_DIFFICULTY = 3,

	DIFFICULTY_NAMES = {
		[1] = "Easy",
		[2] = "Normal",
		[3] = "Hard",
	},

	MAX_TIME_WAIT_LOBBY_CREATION = 25, -- Seconds
}

return LobbyConfigs
