export type Ports = {
	Teleport: (player: Player, cframe: CFrame) -> (),
	AddStamina: (player: Player, amount: number) -> (),
}

local Ports = {} :: Ports

Ports.Teleport = function(_, _) end
Ports.AddStamina = function(_, _) end

return Ports
