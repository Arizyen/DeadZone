--!strict

local ObjectTypes = {}

type ObjectBase = {
	id: string,
	key: string, -- Unique key identifying the object
	name: string,
	description: string,
	stackable: boolean,
	image: string,
	weightPerUnit: number,
	location: string?, -- e.g., "inventory", "hotbar", "loadout", etc.
	slotId: string?, -- e.g., "slot1", "slot2", etc.
}

type ItemFields = {
	type: "item",
	category: "material" | "clothing" | "accessory" | "other",
	quantity: number,
}

type ToolFields = {
	type: "tool",
	category: "weapon" | "harvesting" | "hybrid" | "utility" | "consumable", -- hybrid = both weapon and harvesting
	damage: number?, -- required if weapon or hybrid
	ammo: number?,
}

export type Object = ObjectBase & (ItemFields | ToolFields)

export type Item = Object & { type: "item" }
export type Tool = Object & { type: "tool" }

return ObjectTypes
