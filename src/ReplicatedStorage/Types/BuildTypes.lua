local BuildTypes = {}

export type Build = {
	key: string, -- BuildInfo key
	cframe: CFrame, -- Serialized CFrame
	hp: number,
}

return BuildTypes
