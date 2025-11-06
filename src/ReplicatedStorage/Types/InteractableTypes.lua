local InteractableTypes = {}

local ObjectTypes = require(script.Parent.ObjectTypes)

export type Interactable = {
	type: string, -- Type of interactable (e.g., "Backpack", "Container", "Workbench", etc.)
	key: string, -- InteractableInfo key
	cframe: CFrame, -- Serialized CFrame
}

export type Container = Interactable & {
	storageCapacity: number, -- maximum weight capacity of the inventory
	capacityUsed: number, -- current weight in the inventory
	inventory: { [string]: string }, -- slotId = objectId
	objects: { [string]: ObjectTypes.ObjectCopy }, -- objectId = object
	objectsCategorized: { [string]: { string } }, -- key = { objectId }
}

return InteractableTypes
