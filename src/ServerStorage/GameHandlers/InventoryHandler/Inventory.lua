local Inventory = {}
Inventory.__index = Inventory

-- Services ------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage.Packages
local ReplicatedSource = ReplicatedStorage.Source
local ServerSource = ServerStorage.Source
local ReplicatedPlaywooEngine = ReplicatedSource.PlaywooEngine
local PlaywooEngine = ServerSource.PlaywooEngine
local ReplicatedBaseModules = ReplicatedPlaywooEngine.BaseModules
local ReplicatedConfigs = ReplicatedSource.Configs
local Configs = ServerSource.Configs
local ReplicatedInfo = ReplicatedSource.Info
local Info = ServerSource.Info
local ReplicatedTypes = ReplicatedSource.Types
local Types = ServerSource.Types
local BaseModules = PlaywooEngine.BaseModules
local GameModules = ServerSource.GameModules
local BaseHandlers = PlaywooEngine.BaseHandlers
local GameHandlers = ServerSource.GameHandlers

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine.Utils)
local TableObserver = require(ReplicatedBaseModules.TableObserver)

-- Handlers --------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
local ObjectTypes = require(ReplicatedTypes.ObjectTypes)

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------
local ObjectsInfo = require(ReplicatedInfo.ObjectsInfo)

-- Configs -------------------------------------------------------------------------
local GameConfigs = require(ReplicatedConfigs.GameConfigs)

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
local inventories = {} :: { [string | number]: typeof(Inventory) }

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function GiveObjectId(object: ObjectTypes.ObjectCopy): ObjectTypes.ObjectCopy
	local id = HttpService:GenerateGUID(false):gsub("-", "")
	return Utils.Table.Dictionary.mergeDeep(object, { id = id })
end

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Inventory.GetInventory(id: string | number): typeof(Inventory)?
	return inventories[id]
end

function Inventory.new(
	tableObserver: typeof(ReplicatedBaseModules.TableObserver),
	id: string | number,
	isAnInteractable: boolean?
)
	local self = setmetatable({}, Inventory)

	-- Booleans
	self._destroyed = false
	self._isAnInteractable = isAnInteractable or false
	self._hasBackpackEquipped = false

	-- Strings
	self._id = id

	-- Instances
	self._tableObserver = tableObserver :: typeof(TableObserver)
	self._player = not self._isAnInteractable and game.Players:GetPlayerByUserId(self._id)

	self:_Init()

	return self
end

function Inventory:_Init()
	inventories[self._id] = self

	self._hasBackpackEquipped = not self._isAnInteractable
		and type(self._tableObserver:GetPathValue({ "storage", "objects" })) == "table"

	-- Connections
	if not self._isAnInteractable then
		Utils.Connections.Add(
			self,
			"backpackEquipped",
			self._tableObserver:ObserveKey("storage", function(newValue)
				self._hasBackpackEquipped = type(newValue) == "table" and type(newValue.objects) == "table"
			end)
		)
	end
end

function Inventory:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true
	inventories[self._id] = nil

	Utils.Connections.DisconnectKeyConnections(self)
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- UTILITIES ----------------------------------------------------------------------------------------------------

function Inventory:_GetFreeSlotId(location: string?): string?
	location = location or "inventory"

	if location == "inventory" then
		local inventory = self._tableObserver:GetKeyValue("inventory") or {}

		for i = 1, GameConfigs.INVENTORY_SLOTS do
			local slotId = "slot" .. tostring(i)
			if not inventory[slotId] then
				return slotId
			end
		end
	elseif not self._isAnInteractable then
		if location == "hotbar" then
			local hotbar = self._tableObserver:GetKeyValue("hotbar") or {}
			local hotbarSlots = self._tableObserver:GetPathValue({ "stats", "hotbarSlots" }) or GameConfigs.HOTBAR_SLOTS

			for i = 1, hotbarSlots do
				local slotId = "slot" .. tostring(i)
				if not hotbar[slotId] then
					return slotId
				end
			end
		elseif location == "storage" then
			local backpack = self._tableObserver:GetKeyValue({ "storage" })
			if not backpack then
				return nil
			end

			for i = 1, GameConfigs.INVENTORY_SLOTS do
				local slotId = "slot" .. tostring(i)
				if not backpack[slotId] then
					return slotId
				end
			end
		end
	end

	return nil
end

function Inventory:_LocationIsInBackpack(location: string): boolean
	return location == "storage" and not self._isAnInteractable
end

function Inventory:_GetSlotIdObjectId(location: string, slotId: string): string?
	if self:_LocationIsInBackpack(location) then
		return self._tableObserver:GetKeyValue({ location, "inventory", slotId })
	else
		return self._tableObserver:GetKeyValue({ location, slotId })
	end

	return nil
end

function Inventory:_SetSlotIdObjectId(location: string, slotId: string, objectId: string?): boolean
	if self:_LocationIsInBackpack(location) then
		self._tableObserver:SetPathValue({ location, "inventory", slotId }, objectId)
	else
		self._tableObserver:SetPathValue({ location, slotId }, objectId)
	end

	return true
end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- GETTERS ----------------------------------------------------------------------------------------------------

function Inventory:GetPlayer(): Player?
	return self._player
end

function Inventory:GetQuantityCapacityLeft(objectInfo: ObjectTypes.Object, inBackpack: boolean): number
	if inBackpack and self._isAnInteractable then
		warn("Cannot check backpack capacity on interactable inventories.")
		return 0
	end

	if objectInfo.weightPerUnit then
		if inBackpack and not self._tableObserver:GetPathValue({ "storage" }) then
			return 0
		end

		local storageCapacity = self._tableObserver:GetPathValue({
			(inBackpack and "storage" or "stats"),
			"storageCapacity",
		}) or 0
		local capacityUsed = self._tableObserver:GetPathValue(
			inBackpack and { "storage", "capacityUsed" } or { "capacityUsed" }
		) or 0
		local capacityLeft = storageCapacity - capacityUsed

		return math.floor(capacityLeft / objectInfo.weightPerUnit)
	end

	return math.huge
end

function Inventory:GetObjectOfKey(objectKey: string): ObjectTypes.ObjectCopy?
	local objectsCategorized = self._tableObserver:GetKeyValue("objectsCategorized") or {}
	local objectIds = objectsCategorized[objectKey] or {}
	if #objectIds > 0 then
		return self._tableObserver:GetPathValue({ "objects", objectIds[1] })
	end

	if not self._isAnInteractable then
		local backpack = self._tableObserver:GetPathValue({ "storage" })
		if backpack then
			local backpackObjectsCategorized = backpack.objectsCategorized or {}
			local backpackObjectIds = backpackObjectsCategorized[objectKey] or {}
			if #backpackObjectIds > 0 then
				return self._tableObserver:GetPathValue({ "storage", "objects", backpackObjectIds[1] })
			end
		end
	end

	return nil
end

function Inventory:GetObject(objectId: string, inBackpack: boolean?): ObjectTypes.ObjectCopy?
	if inBackpack then
		return self._tableObserver:GetPathValue({ "storage", "objects", objectId })
	else
		return self._tableObserver:GetPathValue({ "objects", objectId })
	end
end

function Inventory:GetTotalQuantity(objectKey: string): number
	local totalQuantity = 0

	-- Check main inventory
	local objectsCategorized = self._tableObserver:GetKeyValue("objectsCategorized") or {}
	local objectIds = objectsCategorized[objectKey] or {}
	local objects = self._tableObserver:GetKeyValue("objects") or {}

	for _, objectId in ipairs(objectIds) do
		local object: ObjectTypes.ObjectCopy? = objects[objectId]
		if object and object.quantity then
			totalQuantity = totalQuantity + object.quantity
		end
	end

	-- Check backpack
	if not self._isAnInteractable then
		local backpack = self._tableObserver:GetKeyValue({ "storage" })
		if backpack then
			local backpackObjectsCategorized = backpack.objectsCategorized or {}
			local backpackObjectIds = backpackObjectsCategorized[objectKey] or {}
			objects = backpack.objects or {}

			for _, objectId in ipairs(backpackObjectIds) do
				local object: ObjectTypes.ObjectCopy? = objects[objectId]
				if object and object.quantity then
					totalQuantity = totalQuantity + object.quantity
				end
			end
		end
	end

	return totalQuantity
end

-- CHECKS ----------------------------------------------------------------------------------------------------

function Inventory:CanPlayerAccess(player: Player): boolean
	if self._isAnInteractable then
		return self._tableObserver:IsPlayerAListener(player)
	else
		return self._tableObserver:GetPlayer() == player
	end
end

function Inventory:CanObjectGoToLocation(
	objectInfo: ObjectTypes.Object,
	object: ObjectTypes.ObjectCopy,
	location: string
): (boolean, string?)
	if location == "inventory" then
		if type(object.capacityUsed) == "number" and object.capacityUsed > 0 then
			return false, "Containers cannot be placed in the inventory unless empty"
		end
	elseif not self._isAnInteractable then
		if location == "hotbar" and objectInfo.type == "wearable" then
			return false, "Wearables cannot be placed in the hotbar"
		elseif location == "loadout" and objectInfo.type ~= "wearable" then
			return false, "Only wearables can be placed in the loadout"
		end
	end

	return true
end

function Inventory:CanAddAllQuantity(
	objectInfo: ObjectTypes.Object,
	object: ObjectTypes.ObjectCopy,
	inBackpack: boolean?
): boolean
	if object.quantity and object.quantity > 0 then
		local quantityCapacityLeft = self:GetQuantityCapacityLeft(objectInfo, inBackpack)
		if quantityCapacityLeft >= object.quantity then
			return true
		else
			return false
		end
	end

	return true
end

function Inventory:CanAddSingleUnit(objectInfo: ObjectTypes.Object, inBackpack: boolean?): boolean
	local quantityCapacityLeft = self:GetQuantityCapacityLeft(objectInfo, inBackpack)
	if quantityCapacityLeft >= 1 then
		return true
	else
		return false
	end
end

-- SETTERS ----------------------------------------------------------------------------------------------------

-- Adds a new object to the player's inventory, hotbar, or loadout
function Inventory:AddObject(
	objectCopy: ObjectTypes.ObjectCopy,
	location: ("inventory" | "hotbar" | "loadout" | "storage")?,
	slotId: string?
): (boolean, string?)
	assert(objectCopy and objectCopy.key, "InventoryHandler.AddObject: Invalid object provided")

	local objectInfo = ObjectsInfo.byKey[objectCopy.key] :: ObjectTypes.Object
	assert(objectInfo, "InventoryHandler.AddObject: Object key not found in ObjectsInfo")

	location = location or (not self._isAnInteractable and "inventory" or "storage")
	if self._isAnInteractable and location ~= "storage" then
		return false, "Invalid location provided"
	end

	local objectQuantity = objectCopy.quantity or 0
	local quantityCapacityLeft = 0

	if slotId then
		-- Confirm slotId is empty
		local existingObjectId = self:_GetSlotIdObjectId(location, slotId)
		if existingObjectId then
			return false, "Slot already occupied"
		end

		-- Confirm the slotId is valid
		local slotNumber = tonumber(slotId:match("slot(%d+)"))
		if not slotNumber then
			return false, "Invalid slotId"
		end

		if location == "inventory" or location == "storage" then
			if slotNumber < 1 or slotNumber > GameConfigs.INVENTORY_SLOTS then
				return false, "Invalid slotId"
			end
		elseif location == "hotbar" then
			local hotbarSlots = self._tableObserver:GetPathValue({ "stats", "hotbarSlots" }) or GameConfigs.HOTBAR_SLOTS
			if slotNumber < 1 or slotNumber > hotbarSlots then
				return false, "Invalid slotId"
			end
		elseif location == "loadout" then
			if slotNumber < 1 or slotNumber > GameConfigs.LOADOUT_SLOTS then
				return false, "Invalid slotId"
			end
		end

		-- Confirm capacity left
		quantityCapacityLeft = self:GetQuantityCapacityLeft(objectInfo, self:_LocationIsInBackpack(location))
		if quantityCapacityLeft <= 0 then
			return false, "No capacity left!"
		end
	else
		-- Find free slotId
		slotId = self:_GetFreeSlotId(location)

		-- Check in inventory
		if not slotId and location == "hotbar" then
			location = "inventory"
			slotId = self:_GetFreeSlotId(location)
		end

		-- Confirm capacity left in inventory (hotbar/inventory/loadout all use main inventory capacity)
		if slotId then
			quantityCapacityLeft = self:GetQuantityCapacityLeft(objectInfo)
			if quantityCapacityLeft <= 0 then
				return false, "No capacity left!"
			elseif quantityCapacityLeft < objectQuantity then
				if self._hasBackpackEquipped then
					slotId = nil -- try backpack next
				end
			end
		end

		-- Check in backpack
		if not slotId and self._hasBackpackEquipped then
			location = "storage"
			slotId = self:_GetFreeSlotId(location)

			-- Confirm capacity left (backpack has a separate inventory capacity)
			if slotId then
				quantityCapacityLeft = self:GetQuantityCapacityLeft(objectInfo, self:_LocationIsInBackpack(location))
				if quantityCapacityLeft <= 0 then
					return false, "No capacity left!"
				end
			end
		end

		if not slotId then
			return false, "No slots available. Please free up some space." -- No free slot found
		end
	end

	-- Create and add object
	local newObject = GiveObjectId(objectCopy)
	newObject.location = location
	newObject.slotId = slotId

	-- Update quantity
	if newObject.quantity then
		if newObject.quantity > quantityCapacityLeft then
			newObject.quantity = quantityCapacityLeft
		end
	end

	if self:_LocationIsInBackpack(location) then
		self._tableObserver:SetPathValue({ "storage", "objects", newObject.id }, newObject)
		self._tableObserver:InsertAtPathValue({ "storage", "objectsCategorized", newObject.key }, newObject.id)
		self._tableObserver:IncrementPathValue(
			{ "storage", "capacityUsed" },
			(objectInfo.weightPerUnit or 0) * (newObject.quantity or 1)
		)
	else
		self._tableObserver:SetPathValue({ "objects", newObject.id }, newObject)
		self._tableObserver:InsertAtPathValue({ "objectsCategorized", newObject.key }, newObject.id)
		self._tableObserver:IncrementKeyValue(
			"capacityUsed",
			(objectInfo.weightPerUnit or 0) * (newObject.quantity or 1)
		)
	end

	self:_SetSlotIdObjectId(location, slotId, newObject.id)

	return true
end

function Inventory:RemoveObject(objectId: string, inBackpack: boolean?): (boolean, string?)
	local object = self:GetObject(objectId, inBackpack)
	if not object then
		return false, "Object not found!"
	end

	local objectInfo = ObjectsInfo.byKey[object.key] :: ObjectTypes.Object

	-- Remove objectId from slotId
	local location = inBackpack and "storage" or object.location
	local slotId = object.slotId
	if location and slotId then
		local locationSlotObjectId = self:_GetSlotIdObjectId(location, slotId)
		if locationSlotObjectId == objectId then
			self:_SetSlotIdObjectId(location, slotId, nil)
		end
	end

	if inBackpack then
		self._tableObserver:RemoveAtPathValue({ "storage", "objectsCategorized", object.key }, objectId)
		self._tableObserver:SetPathValue({ "storage", "objects", objectId }, nil)
		self._tableObserver:IncrementPathValue(
			{ "storage", "capacityUsed" },
			-1 * (objectInfo.weightPerUnit or 0) * (object.quantity or 1)
		)
	else
		self._tableObserver:RemoveAtPathValue({ "objectsCategorized", object.key }, objectId)
		self._tableObserver:SetPathValue({ "objects", objectId }, nil)
		self._tableObserver:IncrementKeyValue(
			"capacityUsed",
			-1 * (objectInfo.weightPerUnit or 0) * (object.quantity or 1)
		)
	end

	return true
end

-- Increments the quantity of a stackable object in the inventory or backpack.
-- Amount must be greater than zero.
-- If the amount exceeds capacity, it will fail.
-- Returns true if successful, false and an error message otherwise.
function Inventory:IncrementObject(objectId: string, amount: number, inBackpack: boolean?): (boolean, string?)
	if amount <= 0 then
		return false, "Amount must be greater than zero!"
	end

	local object: ObjectTypes.ObjectCopy? = self:GetObject(objectId, inBackpack)
	if not object then
		return false, "Object not found!"
	end

	local objectInfo = ObjectsInfo.byKey[object.key] :: ObjectTypes.Object

	-- Confirm object is stackable
	if not objectInfo then
		return false, "Object info not found!"
	elseif not objectInfo.stackable then
		return false, "Object is not stackable!"
	end

	-- Check capacity
	local quantityCapacityLeft = self:GetQuantityCapacityLeft(objectInfo, inBackpack)
	if quantityCapacityLeft < amount then
		return false, "Not enough capacity!"
	end

	-- Update quantity
	self._tableObserver:IncrementPathValue(
		inBackpack and { "storage", "objects", objectId, "quantity" } or { "objects", objectId, "quantity" },
		amount
	)

	-- Update capacity used
	if inBackpack then
		self._tableObserver:IncrementPathValue({ "storage", "capacityUsed" }, (objectInfo.weightPerUnit or 0) * amount)
	else
		self._tableObserver:IncrementKeyValue("capacityUsed", (objectInfo.weightPerUnit or 0) * amount)
	end

	return true
end

-- Decrements the quantity of a stackable object in the inventory.
-- Amount must be greater than zero.
function Inventory:DecrementObjectTotal(objectKey: string, amount: number): (boolean, string?)
	if amount <= 0 then
		return false, "Amount must be greater than zero!"
	end

	local objectInfo = ObjectsInfo.byKey[objectKey] :: ObjectTypes.Object
	if not objectInfo then
		return false, "Object info not found!"
	elseif not objectInfo.stackable then
		return false, "Object is not stackable!"
	end

	-- Decrement from main inventory first
	local objectsCategorized = self._tableObserver:GetKeyValue("objectsCategorized") or {}
	local objectIds = objectsCategorized[objectKey] or {}
	local objects = self._tableObserver:GetKeyValue("objects") or {}

	for _, objectId in ipairs(objectIds) do
		if amount <= 0 then
			break
		end

		local object: ObjectTypes.ObjectCopy? = objects[objectId]
		if object and object.quantity then
			if object.quantity > amount then
				-- Just decrement quantity
				self._tableObserver:IncrementPathValue({ "objects", objectId, "quantity" }, -amount)
				self._tableObserver:IncrementKeyValue("capacityUsed", -1 * (objectInfo.weightPerUnit or 0) * amount)
				amount = 0
			else
				-- Remove entire object
				local qtyToRemove = object.quantity
				local success, errMsg = self:RemoveObject(objectId)
				if not success then
					return false, errMsg
				end
				amount -= qtyToRemove
			end
		end
	end

	-- Decrement from backpack if needed
	if amount > 0 and not self._isAnInteractable then
		local backpack = self._tableObserver:GetKeyValue({ "storage" })
		if backpack then
			local backpackObjectsCategorized = backpack.objectsCategorized or {}
			local backpackObjectIds = backpackObjectsCategorized[objectKey] or {}
			objects = backpack.objects or {}

			for _, objectId in ipairs(backpackObjectIds) do
				if amount <= 0 then
					break
				end

				local object: ObjectTypes.ObjectCopy? = objects[objectId]
				if object and object.quantity then
					if object.quantity > amount then
						-- Just decrement quantity
						self._tableObserver:IncrementPathValue({ "storage", "objects", objectId, "quantity" }, -amount)
						self._tableObserver:IncrementPathValue(
							{ "storage", "capacityUsed" },
							-1 * (objectInfo.weightPerUnit or 0) * amount
						)
						amount = 0
					else
						-- Remove entire object
						local qtyToRemove = object.quantity
						local success, errMsg = self:RemoveObject(objectId, true)
						if not success then
							return false, errMsg
						end
						amount -= qtyToRemove
					end
				end
			end
		end
	end

	return true
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Inventory
