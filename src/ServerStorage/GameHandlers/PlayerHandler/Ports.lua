export type Ports = {
	Teleport: (player: Player, cframe: CFrame) -> (),
	AddStamina: (player: Player, amount: number) -> (),
	ReplicatePlayerAxes: (player: Player, pitchRad: number, yawRad: number) -> (),
}

local Ports = {} :: Ports

return Ports
