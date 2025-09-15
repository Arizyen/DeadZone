local LobbyTypes = {}

export type LobbySettings = {
	difficulty: number,
	maxPlayers: number,
	friendsOnly: boolean,
	saveIndex: number?,
}

export type LobbyState = {
	id: string,
	players: { Player },
	settings: LobbySettings?,
	state: "Waiting" | "Creating" | "Starting" | "Teleporting",
}

return LobbyTypes
