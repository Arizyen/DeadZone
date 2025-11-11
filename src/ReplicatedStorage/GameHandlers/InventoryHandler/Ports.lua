local ReplicatedSource = game:GetService("ReplicatedStorage"):WaitForChild("Source")
local ReplicatedTypes = ReplicatedSource:WaitForChild("Types")
export type Ports = {
	ObjectAdded: (player: Player, key: string, quantity: number) -> (),
	ObjectRemoved: (player: Player, key: string, quantity: number) -> (),
}

local Ports = {} :: Ports

return Ports
