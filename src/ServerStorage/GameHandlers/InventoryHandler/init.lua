local InventoryHandler = {}

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
local ReplicatedTypes = ReplicatedSource.Types
local BaseModules = PlaywooEngine.BaseModules
local GameModules = ServerSource.GameModules
local BaseHandlers = PlaywooEngine.BaseHandlers
local GameHandlers = ServerSource.GameHandlers

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine.Utils)
local Ports = require(script.Ports)

-- Handlers --------------------------------------------------------------------
local PlayerDataHandler = require(BaseHandlers.PlayerDataHandler)

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------
local ObjectTypes = require(ReplicatedTypes.ObjectTypes)
local ObjectsInfo = require(ReplicatedInfo.ObjectsInfo)

-- Configs -------------------------------------------------------------------------
local GameConfigs = require(ReplicatedConfigs.GameConfigs)

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function CreateObject(object: ObjectTypes.Object)
	local id = HttpService:GenerateGUID(false):gsub("-", "")
	return Utils.Table.Dictionary.mergeDeep(object, { id = id })
end

local function GetFreeSlotId(player: Player, location: "inventory" | "hotbar"): string?
	local freeSlotId

	-- Find free slot based on desired location
	if location == "hotbar" then
		local hotbar = PlayerDataHandler.GetPathValue(player.UserId, { "hotbar" })
		local hotbarSlots = PlayerDataHandler.GetPathValue(player.UserId, { "stats", "hotbarSlots" })

		for i = 1, hotbarSlots do
			local slotId = "slot" .. tostring(i)
			if not hotbar[slotId] then
				freeSlotId = slotId
				break
			end
		end
	elseif location == "inventory" then
		local inventory = PlayerDataHandler.GetPathValue(player.UserId, { "inventory" })

		for i = 1, GameConfigs.MAX_INVENTORY_SLOTS do
			local slotId = "slot" .. tostring(i)
			if not inventory[slotId] then
				freeSlotId = slotId
				break
			end
		end
	end

	return freeSlotId
end

local function ObjectCanGoToLocation(
	objectInfo: ObjectTypes.Object,
	location: "inventory" | "hotbar" | "loadout"
): (boolean, string?)
	if location == "hotbar" and objectInfo.type ~= "tool" then
		return false, "Only tools can be placed in the hotbar"
	elseif location == "loadout" and objectInfo.type ~= "wearable" then
		return false, "Only wearables can be placed in the loadout"
	end

	return true
end

local function HasCapacityForObject(
	player: Player,
	objectInfo: ObjectTypes.Object,
	quantity: number,
	inBackpack: boolean
): (boolean, string?)
	if objectInfo.weightPerUnit then
		if inBackpack and not PlayerDataHandler.GetPathValue(player.UserId, { "backpack" }) then
			return false, "No backpack equipped"
		end

		local inventoryCapacity = PlayerDataHandler.GetPathValue(
			player.UserId,
			{ (inBackpack and "backpack" or "stats"), "inventoryCapacity" }
		) or 0
		local capacityUsed = PlayerDataHandler.GetPathValue(
			player.UserId,
			inBackpack and { "backpack", "capacityUsed" } or { "capacityUsed" }
		) or 0
		local additionalWeight = objectInfo.weightPerUnit * quantity

		if capacityUsed + additionalWeight > inventoryCapacity then
			return false, "Not enough inventory capacity"
		end
	end

	return true
end

local function GetQuantityCapacityLeft(player: Player, objectInfo: ObjectTypes.Object, inBackpack: boolean): number
	if objectInfo.weightPerUnit then
		if inBackpack and not PlayerDataHandler.GetPathValue(player.UserId, { "backpack" }) then
			return 0
		end

		local inventoryCapacity = PlayerDataHandler.GetPathValue(
			player.UserId,
			{ (inBackpack and "backpack" or "stats"), "inventoryCapacity" }
		) or 0
		local capacityUsed = PlayerDataHandler.GetPathValue(
			player.UserId,
			inBackpack and { "backpack", "capacityUsed" } or { "capacityUsed" }
		) or 0
		local capacityLeft = inventoryCapacity - capacityUsed

		return math.floor(capacityLeft / objectInfo.weightPerUnit)
	end

	return math.huge
end

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function InventoryHandler.Register(ports: Ports.Ports)
	Utils.Table.Dictionary.mergeMut(Ports, ports)
end

-- Adds a new object to the player's inventory, hotbar, or loadout
function InventoryHandler.AddObject(
	player: Player,
	objectCopy: ObjectTypes.ObjectCopy,
	location: ("inventory" | "hotbar" | "loadout" | "backpack")?
): (boolean, string?)
	assert(objectCopy and objectCopy.key, "InventoryHandler.AddObject: Invalid object provided")
	assert(ObjectsInfo.byKey[objectCopy.key], "InventoryHandler.AddObject: Object key not found in ObjectsInfo")

	location = location or "inventory"

	local freeSlotKey = GetFreeSlotId(player, location)
	if not freeSlotKey and location == "hotbar" then
		location = "inventory"
		freeSlotKey = GetFreeSlotId(player, location)
	end

	if not freeSlotKey then
		return false, "No slots available in inventory" -- No free slot found
	end

	-- Create and add object
	local newObject = CreateObject(objectCopy)
	newObject.location = location
	newObject.slotId = freeSlotKey

	PlayerDataHandler.SetPathValue(player.UserId, { "objects", newObject.id }, newObject)
	PlayerDataHandler.InsertAtPathValue(player.UserId, { "objectsCategorized", newObject.key }, newObject.id)
	PlayerDataHandler.SetPathValue(player.UserId, { location, freeSlotKey }, newObject.id)

	return true
end

-- Removes an object from the player's inventory, hotbar, or loadout
function InventoryHandler.RemoveObject(player: Player, objectId: string): boolean
	local objects = PlayerDataHandler.GetPathValue(player.UserId, { "objects" })
	local object = objects[objectId]
	if not object then
		return false -- Object not found
	end

	-- Remove from location
	local location = object.location
	local slotId = object.slotId
	if location and slotId then
		local locationSlotObjectId = PlayerDataHandler.GetPathValue(player.UserId, { location, slotId })
		if locationSlotObjectId == objectId then
			PlayerDataHandler.SetPathValue(player.UserId, { location, slotId }, nil)
		end
	end

	-- Remove from categorized list
	PlayerDataHandler.RemoveAtPathValue(player.UserId, { "objectsCategorized", object.key }, objectId)

	-- Remove from objects
	PlayerDataHandler.SetPathValue(player.UserId, { "objects", objectId }, nil)

	return true
end

-- Moves an object to a new location and slot in the player's inventory, hotbar, or loadout
function InventoryHandler.MoveObject(
	player: Player,
	objectId: string,
	newLocation: ("inventory" | "hotbar" | "loadout" | "backpack")?,
	newSlotId: string?
): (boolean, string?)
	local objects = PlayerDataHandler.GetPathValue(player.UserId, { "objects" })
	local object = objects[objectId]
	if not object then
		return false, "Object not found"
	end
	object = table.clone(object)

	-- Get object info
	local objectInfo = ObjectsInfo.byKey[object.key]
	if not objectInfo then
		return false, "Object info not found"
	end

	newLocation = newLocation or "inventory"

	-- Confirm it can go to the new location
	if not ObjectCanGoToLocation(objectInfo, newLocation) then
		return ObjectCanGoToLocation(objectInfo, newLocation)
	end

	if newSlotId then
		-- Confirm slot id is valid
		local slotNumber = tonumber(newSlotId:match("slot(%d+)"))
		if not slotNumber or slotNumber < 1 then
			return false, "Invalid slot ID"
		elseif slotNumber > GameConfigs.MAX_INVENTORY_SLOTS then
			return false, "Slot ID exceeds maximum inventory slots"
		end

		-- Place the new slot's item in the object's current location
		local newLocationObjectId = PlayerDataHandler.GetPathValue(player.UserId, { newLocation, newSlotId })
		if newLocationObjectId then
			-- Verify if an object exists in the new slot
			local occupyingObjectId = newLocationObjectId
			local occupyingObject = objects[occupyingObjectId]

			if occupyingObject then
				local occupyingObjectInfo = ObjectsInfo.byKey[occupyingObject.key]
				if not occupyingObjectInfo then
					warn(
						"InventoryHandler.MoveObject: Occupying object info not found for key: "
							.. tostring(occupyingObject.key)
					)
					return false, "Occupying object info not found"
				end

				if occupyingObjectInfo.key == objectInfo.key and occupyingObjectInfo.stackable then
					-- If the occupying object is the same and stackable, increment quantity of object and destroy occupying object
					object.quantity += occupyingObject.quantity or 0

					-- Remove occupying object
					InventoryHandler.RemoveObject(player, occupyingObjectId)
				else
					-- Confirm the occupying object can go to the original object's location
					if not ObjectCanGoToLocation(occupyingObjectInfo, object.location) then
						return ObjectCanGoToLocation(occupyingObjectInfo, object.location)
					end

					local occupyingObjectCopy = table.clone(occupyingObject)
					-- Place it in the original object's location
					occupyingObjectCopy.location = object.location
					occupyingObjectCopy.slotId = object.slotId
					PlayerDataHandler.SetPathValue(player.UserId, { "objects", occupyingObjectId }, occupyingObjectCopy)

					-- Update the location table with the occupying object
					if occupyingObjectCopy.location and occupyingObjectCopy.slotId then
						PlayerDataHandler.SetPathValue(
							player.UserId,
							{ occupyingObjectCopy.location, occupyingObjectCopy.slotId },
							occupyingObjectId
						)
					end
				end
			end
		end
	else
		-- Find free slot based on desired location
		newSlotId = GetFreeSlotId(player, newLocation)
		if not newSlotId then
			return false, "No slots available in " .. newLocation
		end
	end

	-- Clear old location if hasn't been occupied by another object
	local oldLocation = object.location
	local oldSlotId = object.slotId
	if oldLocation and oldSlotId then
		local oldLocationSlotObjectId = PlayerDataHandler.GetPathValue(player.UserId, { oldLocation, oldSlotId })
		if oldLocationSlotObjectId == objectId then
			PlayerDataHandler.SetPathValue(player.UserId, { oldLocation, oldSlotId }, nil)
		end
	end

	-- Update object data
	object.location = newLocation
	object.slotId = newSlotId
	PlayerDataHandler.SetPathValue(player.UserId, { "objects", objectId }, object)

	-- Set new location
	PlayerDataHandler.SetPathValue(player.UserId, { newLocation, newSlotId }, objectId)

	return true
end

-- Increments or decrements the quantity of an object in the player's inventory, hotbar, or loadout
function InventoryHandler.IncrementObject(player: Player, objectId: string, amount: number): (boolean, string?)
	local objects = PlayerDataHandler.GetPathValue(player.UserId, { "objects" })
	local object = objects[objectId]
	if not object then
		return false, "Object not found"
	elseif type(object.quantity) ~= "number" then
		return false, "Object is not stackable"
	elseif object.quantity + amount < 0 then
		return false, "Insufficient quantity to decrement"
	end

	-- Update quantity
	object = table.clone(object)
	object.quantity += amount
	if object.quantity <= 0 then
		InventoryHandler.RemoveObject(player, objectId)
	else
		PlayerDataHandler.SetPathValue(player.UserId, { "objects", objectId }, object)
	end

	return true
end

-- Adds a new stackable object or increments an existing object's quantity in the player's inventory, hotbar, or loadout
function InventoryHandler.AddOrIncrementObject(player: Player, objectCopy: ObjectTypes.ObjectCopy): (boolean, string?)
	assert(objectCopy and objectCopy.key, "InventoryHandler.AddOrIncrementObject: Invalid object provided")
	assert(type(objectCopy.quantity) == "number", "InventoryHandler.AddOrIncrementObject: Quantity must be provided")
	assert(
		ObjectsInfo.byKey[objectCopy.key],
		"InventoryHandler.AddOrIncrementObject: Object key not found in ObjectsInfo"
	)

	-- Check for existing stackable object
	local objectsCategorized = PlayerDataHandler.GetPathValue(player.UserId, { "objectsCategorized", objectCopy.key })
	for _, existingObjectId in pairs(objectsCategorized or {}) do
		local existingObject = PlayerDataHandler.GetPathValue(player.UserId, { "objects", existingObjectId })
		if existingObject and type(existingObject.quantity) == "number" then
			-- Increment existing object
			return InventoryHandler.IncrementObject(player, existingObjectId, objectCopy.quantity)
		end
	end

	-- Add new object
	return InventoryHandler.AddObject(player, objectCopy)
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return InventoryHandler
