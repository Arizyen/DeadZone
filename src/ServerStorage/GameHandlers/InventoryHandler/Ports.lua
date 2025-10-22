local ReplicatedSource = game:GetService("ReplicatedStorage").Source
local ServerSource = game:GetService("ServerStorage").Source
local ReplicatedTypes = ReplicatedSource.Types
local Types = ServerSource.Types

export type Ports = {
	MoveObject: (objectId: string, newLocation: string, newSlotId: string) -> (boolean, string?),
}

local Ports = {} :: Ports

return Ports
