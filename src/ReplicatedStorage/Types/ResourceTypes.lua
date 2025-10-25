local ResourceTypes = {}

export type Resource = {
	key: string, -- Resource type key (e.g., "tree_maple", "rock_pine") - Used to get the ResourceInfo
	cframe: string, -- Serialized CFrame
	scaleFactor: number, -- Scale factor of the resource (1 = normal size) (0.8 - 1.05)
	stageIndex: number, -- Growth stage index
	stageProgress: number?, -- Progress within the current growth stage (0-1)
	planted: boolean?, -- Whether the resource was planted by a player
}

export type Resources = { [string]: Resource } -- Key is resource type

return ResourceTypes
