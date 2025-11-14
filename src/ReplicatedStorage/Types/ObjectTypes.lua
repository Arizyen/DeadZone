--!strict

local ObjectTypes = {}

-- Object info

type ObjectBase = {
	id: string, -- Unique identifier for this specific object instance
	key: string, -- Unique key identifying the object info
	type: string,
	category: string,
	name: string,
	description: string,
	stackable: boolean,
	image: string,
	weightPerUnit: number,
	canStore: boolean, -- whether the object can be placed in inventory (example a chest or backpack cannot be placed inside another chest or backpack or inside inventory)
	quantity: number?, -- If no quantity is provided, it is assumed to be 1
}
type ItemFields = {
	type: "item",
	category: "material" | "ammo" | "other",
	quantity: number,
}
type ToolFields = {
	type: "tool",
	category: "weapon" | "harvesting" | "hybrid" | "utility" | "consumable", -- hybrid = both weapon and harvesting
	attackType: ("melee" | "ranged")?, -- required if weapon or hybrid
	resourceType: string?, -- required if harvesting ("trees", "ores", "any")
	durabilityLossPerUse: number?, -- a value between 0 and 1 representing percentage of durability lost per use
	useDelay: number?, -- delay between uses in seconds
	useRange: number?, -- maximum range of use in studs
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
type InventoryFields = {
	storageCapacity: number, -- maximum weight capacity of the storage
	capacityUsed: number, -- current weight in the storage
	storage: { [string]: string }, -- slotId = objectId
	objects: { [string]: ObjectCopy }, -- objectId = object
	objectsCategorized: { [string]: { string } }, -- key = { objectId }
	objectCounts: { [string]: number }, -- key = quantity
}

-- A copy of the object with only key and editable fields -------------------------------------------------------------
type ObjectBaseCopy = {
	id: string, -- Unique identifier for this specific object instance
	key: string, -- Unique key identifying the object info
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
type InventoryFieldsCopy = {
	capacityUsed: number, -- current weight in the inventory
	inventory: { [string]: string }, -- slotId = objectId
	objects: { [string]: ObjectCopy }, -- objectId = object
	objectsCategorized: { [string]: { string } }, -- key = { objectId }
}

export type Object = ObjectBase & (ItemFields | ToolFields | WearableFields) & (InventoryFields?)
export type Item = Object & { type: "item" }
export type Tool = Object & { type: "tool" }
export type Wearable = Object & { type: "wearable" }

export type ObjectCopy = ObjectBaseCopy & (ItemFieldsCopy | ToolFieldsCopy | WearableFieldsCopy) & (InventoryFieldsCopy?)
export type ItemCopy = ObjectCopy & { type: "item" }
export type ToolCopy = ObjectCopy & { type: "tool" }
export type WearableCopy = ObjectCopy & { type: "wearable" }

export type BackpackCopy =
	ObjectBaseCopy
	& WearableFieldsCopy
	& InventoryFieldsCopy
	& { type: "wearable", category: "accessory" }

return ObjectTypes
