local ItemTypes = {}

export type Item = {
	id: string,
	key: string,
	type: "item",
	category: "Material" | "Consumable" | "Clothing" | "Accessory" | "Other",
	quantity: number,
}

export type Tool = {
	id: string,
	key: string,
	type: "tool",
	category: "Weapon" | "Harvesting" | "Utility",
	ammo: number?,
}

export type Object = Item | Tool

return ItemTypes
