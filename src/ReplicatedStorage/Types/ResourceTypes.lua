local ResourceTypes = {}

export type ResourceInfo = {
	key: string, -- Resource type key (e.g., "Maple", "Palm", "Pine")
	type: string, -- Resource type (e.g., "tree")
	name: string, -- Display name
	hp: number, -- Health points
	growthTimeFactor: number, -- Growth time multiplier (1 = normal speed)
}

export type Resource = {
	key: string, -- Resource key (e.g., "Maple", "Palm", "Pine") - Used to get the ResourceInfo
	id: string, -- Unique identifier for this specific resource instance
	cframe: string, -- Serialized CFrame
	scaleFactor: number, -- Scale factor of the resource (1 = normal size) (0.8 - 1.05)
	hp: number, -- Current health points
	stageIndex: number, -- Growth stage index
	stageProgress: number?, -- Progress within the current growth stage (0-1)
	planted: boolean?, -- Whether the resource was planted by a player
}

export type Resources = { [string]: { Resource } } -- Key is resource type

return ResourceTypes
