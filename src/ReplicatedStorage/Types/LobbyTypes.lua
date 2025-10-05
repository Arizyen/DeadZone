local LobbyTypes = {}

export type LobbySettings = {
	difficulty: number,
	maxPlayers: number,
	friendsOnly: boolean,
	saveId: string?,
}

export type LobbyState = {
	id: string,
	players: { Player },
	state: "Waiting" | "Creating" | "Starting" | "Teleporting",
	settings: LobbySettings,
	settingsUpdated: boolean,
	serverStartTime: number?,
}

return LobbyTypes
