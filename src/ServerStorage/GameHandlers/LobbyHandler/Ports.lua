local ReplicatedSource = game:GetService("ReplicatedStorage").Source
local ReplicatedTypes = ReplicatedSource.Types
local LobbyTypes = require(ReplicatedTypes.LobbyTypes)

export type Ports = {
	FireLobbyStateUpdate: (state: LobbyTypes.LobbyState, playersLobbyId: { [number]: string }) -> (),
}

local Ports = {
	FireLobbyStateUpdate = function(_, _) end,
} :: Ports

return Ports
