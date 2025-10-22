local InventoryHandler = {}

-- Services ------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HTTPService = game:GetService("HttpService")

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

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function CreateObject(object: ObjectTypes.Object)
	local id = HTTPService:GenerateGUID(false):gsub("-", "")
	return Utils.Table.Dictionary.mergeDeep(object, { id = id })
end

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function InventoryHandler.Register(ports: Ports.Ports)
	Utils.Table.Dictionary.mergeMut(Ports, ports)
end

function InventoryHandler.AddObject(
	player: Player,
	objectCopy: ObjectTypes.ObjectCopy,
	location: ("inventory" | "hotbar" | "loadout")?
): (boolean, string?)
	assert(objectCopy and objectCopy.key, "InventoryHandler.AddObject: Invalid object provided")
	assert(ObjectsInfo.byKey[objectCopy.key], "InventoryHandler.AddObject: Object key not found in ObjectsInfo")

	location = location or "inventory"
	local freeSlotKey

	-- Find free slot based on desired location
	if location == "hotbar" then
		local hotbar = PlayerDataHandler.GetPathValue(player.UserId, { "hotbar" })
		local hotbarSlots = PlayerDataHandler.GetPathValue(player.UserId, { "stats", "hotbarSlots" })

		for i = 1, hotbarSlots do
			local slotKey = "slot" .. tostring(i)
			if not hotbar[slotKey] then
				freeSlotKey = slotKey
				break
			end
		end

		-- No free hotbar slot found
		if not freeSlotKey then
			location = "inventory"
		end
	end

	if location == "inventory" then
		local inventory = PlayerDataHandler.GetPathValue(player.UserId, { "inventory" })
		local inventorySlots = PlayerDataHandler.GetPathValue(player.UserId, { "stats", "inventorySlots" })

		for i = 1, inventorySlots do
			local slotKey = "slot" .. tostring(i)
			if not inventory[slotKey] then
				freeSlotKey = slotKey
				break
			end
		end
	end

	if not freeSlotKey then
		return false, "Inventory is full" -- No free slot found
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
		local locationTable = PlayerDataHandler.GetPathValue(player.UserId, { location })
		if locationTable[slotId] == objectId then
			PlayerDataHandler.SetPathValue(player.UserId, { location, slotId }, nil)
		end
	end

	-- Remove from categorized list
	PlayerDataHandler.RemoveAtPathValue(player.UserId, { "objectsCategorized", object.key }, objectId)

	-- Remove from objects
	PlayerDataHandler.SetPathValue(player.UserId, { "objects", objectId }, nil)

	return true
end

function InventoryHandler.MoveObject(
	player: Player,
	objectId: string,
	newLocation: ("inventory" | "hotbar" | "loadout")?,
	newSlotId: string
): (boolean, string?)
	local objects = PlayerDataHandler.GetPathValue(player.UserId, { "objects" })
	local object = objects[objectId]
	if not object then
		return false, "Object not found"
	end

	-- Get object info
	local objectInfo = ObjectsInfo.byKey[object.key]
	if not objectInfo then
		return false, "Object info not found"
	end

	-- Confirm it can go to the new location
	newLocation = newLocation or "inventory"
	if newLocation == "hotbar" and objectInfo.type ~= "tool" then
		return false, "Only tools can be placed in the hotbar"
	elseif newLocation == "loadout" and objectInfo.type ~= "wearable" then
		return false, "Only wearables can be placed in the loadout"
	end

	-- Place the new slot's item in the object's current location
	local locationTable = PlayerDataHandler.GetPathValue(player.UserId, { newLocation })
	if locationTable[newSlotId] then
		-- Verify if an object exists in the new slot
		local occupyingObjectId = locationTable[newSlotId]
		local occupyingObject = objects[occupyingObjectId]
		if occupyingObject then
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

	-- Clear old location
	local oldLocation = object.location
	local oldSlotId = object.slotId
	if oldLocation and oldSlotId then
		local oldLocationTable = PlayerDataHandler.GetPathValue(player.UserId, { oldLocation })
		if oldLocationTable[oldSlotId] == objectId then
			PlayerDataHandler.SetPathValue(player.UserId, { oldLocation, oldSlotId }, nil)
		end
	end

	-- Set new location
	PlayerDataHandler.SetPathValue(player.UserId, { newLocation, newSlotId }, objectId)

	-- Update object data
	object = table.clone(object)
	object.location = newLocation
	object.slotId = newSlotId
	PlayerDataHandler.SetPathValue(player.UserId, { "objects", objectId }, object)

	return true
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return InventoryHandler
