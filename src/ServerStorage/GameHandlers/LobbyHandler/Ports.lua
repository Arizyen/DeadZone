local ReplicatedSource = game:GetService("ReplicatedStorage").Source
local ReplicatedTypes = ReplicatedSource.Types
local LobbyTypes = require(ReplicatedTypes.Lobby)

export type Ports = {
	FireLobbyStateUpdate: (state: LobbyTypes.LobbyState) -> (),
}

local Ports = {
	FireLobbyStateUpdate = function(_) end,
} :: Ports

return Ports
