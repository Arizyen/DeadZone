local ItemTypes = {}

export type Item = {
	key: string,
	type: "item",
	category: "Material" | "Consumable" | "Clothing" | "Accessory" | "Other",
	quantity: number,
}

export type Tool = {
	key: string,
	type: "tool",
	category: "Weapon" | "Harvesting" | "Utility",
	ammo: number?,
}

export type Items = Item | Tool

return ItemTypes
