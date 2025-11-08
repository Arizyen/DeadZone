local ReplicatedSource = game:GetService("ReplicatedStorage"):WaitForChild("Source")
local ReplicatedTypes = ReplicatedSource:WaitForChild("Types")
export type Ports = {
	AddToBackpack: (objectId: string) -> boolean,
}

local Ports = {} :: Ports

return Ports
