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
	settings: LobbySettings?,
	state: "Waiting" | "Creating" | "Starting" | "Teleporting",
}

return LobbyTypes
