export type Ports = {
	Teleport: (player: Player, cframe: CFrame) -> (),
}

local Ports = {} :: Ports

Ports.Teleport = function(_, _) end

return Ports
