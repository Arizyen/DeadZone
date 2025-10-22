--!strict

local ObjectTypes = {}

-- Object info

type ObjectBase = {
	key: string, -- Unique key identifying the object
	name: string,
	description: string,
	stackable: boolean,
	image: string,
	weightPerUnit: number,
	quantity: number?,
}
type ItemFields = {
	type: "item",
	category: "material" | "other",
}
type ToolFields = {
	type: "tool",
	category: "weapon" | "harvesting" | "hybrid" | "utility" | "consumable", -- hybrid = both weapon and harvesting
	durabilityLossPerUse: number, -- a value between 0 and 1 representing percentage of durability lost per use
	hitDelay: number?, -- delay between uses in seconds
	reloadTime: number?, -- time taken to reload in seconds
	damage: number?, -- required if weapon or hybrid
	maxAmmo: number?,
	animations: { [string]: string }?,
}
type WearableFields = {
	type: "wearable",
	category: "clothing" | "accessory",
	hp: number?, -- amount of HP this wearable provides
}

-- A copy of the object with only key and editable fields -------------------------------------------------------------
type ObjectBaseCopy = {
	id: string, -- Unique identifier for this specific object instance
	key: string, -- Unique key identifying the object
	quantity: number?,
	location: string?, -- e.g., "inventory", "hotbar", "loadout", etc.
	slotId: string?, -- e.g., "slot1", "slot2", etc.
}
type ItemFieldsCopy = {
	quantity: number,
}
type ToolFieldsCopy = {
	durability: number, -- Current durability value between 0 and 1
	ammo: number?, -- Current ammo count
	ammoKey: string?, -- Key of the ammo type currently loaded
	damageBonus: number?, -- Bonus damage applied to base damage
	maxAmmoBonus: number?, -- Bonus max ammo applied to base max ammo
}
type WearableFieldsCopy = {
	hpBonus: number?, -- Bonus HP applied to base HP
}

export type Object = ObjectBase & (ItemFields | ToolFields | WearableFields)
export type Item = Object & { type: "item" }
export type Tool = Object & { type: "tool" }
export type Wearable = Object & { type: "wearable" }

export type ObjectCopy = ObjectBaseCopy & (ItemFieldsCopy | ToolFieldsCopy | WearableFieldsCopy)
export type ItemCopy = ObjectCopy & { type: "item" }
export type ToolCopy = ObjectCopy & { type: "tool" }
export type WearableCopy = ObjectCopy & { type: "wearable" }

return ObjectTypes
