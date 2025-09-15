local ReplicatedSource = game:GetService("ReplicatedStorage"):WaitForChild("Source")
local ReplicatedTypes = ReplicatedSource:WaitForChild("Types")
local LobbyTypes = require(ReplicatedTypes:WaitForChild("Lobby"))

export type Ports = {
	GetAllLobbiesState: () -> { [string]: LobbyTypes.LobbyState },
	LeaveLobby: () -> (),
	CreateLobby: (settings: LobbyTypes.LobbySettings) -> (),
}

local Ports = {} :: Ports

return Ports
