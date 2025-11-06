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
local Inventory = require(script.Inventory)

-- Handlers --------------------------------------------------------------------
local PlayerDataHandler = require(BaseHandlers.PlayerDataHandler)
local MessageHandler = require(BaseHandlers.MessageHandler)

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

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function InventoryHandler.Register(ports: Ports.Ports)
	Utils.Table.Dictionary.mergeMut(Ports, ports)
end

-- Adds a new object to the player's inventory, hotbar, or loadout
function InventoryHandler.AddObject(
	inventoryId: string | number,
	objectCopy: ObjectTypes.ObjectCopy,
	location: ("inventory" | "hotbar" | "loadout" | "storage")?
): (boolean, string?)
	local inventory = Inventory.GetInventory(inventoryId)
	if not inventory then
		return false, "Inventory not found"
	end

	return inventory:AddObject(objectCopy, location)
end

-- Removes an object from the player's inventory, hotbar, or loadout
function InventoryHandler.RemoveObject(inventoryId: string | number, objectId: string, inBackpack: boolean?): boolean
	local inventory = Inventory.GetInventory(inventoryId)
	if not inventory then
		return false, "Inventory not found"
	end

	return inventory:RemoveObject(objectId, inBackpack)
end

-- Moves an object to a new location and slot in the player's inventory, hotbar, or loadout
-- function InventoryHandler.MoveObject(
-- 	player: Player,
-- 	objectId: string,
-- 	newLocation: ("inventory" | "hotbar" | "loadout" | "storage")?,
-- 	newSlotId: string?
-- ): (boolean, string?)
-- 	local objects = PlayerDataHandler.GetPathValue(player.UserId, { "objects" })
-- 	local object = objects[objectId]
-- 	if not object then
-- 		return false, "Object not found"
-- 	end
-- 	object = table.clone(object)

-- 	-- Get object info
-- 	local objectInfo = ObjectsInfo.byKey[object.key]
-- 	if not objectInfo then
-- 		return false, "Object info not found"
-- 	end

-- 	newLocation = newLocation or "inventory"

-- 	-- Confirm it can go to the new location
-- 	if not ObjectCanGoToLocation(objectInfo, newLocation) then
-- 		return ObjectCanGoToLocation(objectInfo, newLocation)
-- 	end

-- 	if newSlotId then
-- 		-- Confirm slot id is valid
-- 		local slotNumber = tonumber(newSlotId:match("slot(%d+)"))
-- 		if not slotNumber or slotNumber < 1 then
-- 			return false, "Invalid slot ID"
-- 		elseif slotNumber > GameConfigs.INVENTORY_SLOTS then
-- 			return false, "Slot ID exceeds maximum inventory slots"
-- 		end

-- 		-- Place the new slot's item in the object's current location
-- 		local newLocationObjectId = PlayerDataHandler.GetPathValue(player.UserId, { newLocation, newSlotId })
-- 		if newLocationObjectId then
-- 			-- Verify if an object exists in the new slot
-- 			local occupyingObjectId = newLocationObjectId
-- 			local occupyingObject = objects[occupyingObjectId]

-- 			if occupyingObject then
-- 				local occupyingObjectInfo = ObjectsInfo.byKey[occupyingObject.key]
-- 				if not occupyingObjectInfo then
-- 					warn(
-- 						"InventoryHandler.MoveObject: Occupying object info not found for key: "
-- 							.. tostring(occupyingObject.key)
-- 					)
-- 					return false, "Occupying object info not found"
-- 				end

-- 				if occupyingObjectInfo.key == objectInfo.key and occupyingObjectInfo.stackable then
-- 					-- If the occupying object is the same and stackable, increment quantity of object and destroy occupying object
-- 					object.quantity += occupyingObject.quantity or 0

-- 					-- Remove occupying object
-- 					InventoryHandler.RemoveObject(player, occupyingObjectId)
-- 				else
-- 					-- Confirm the occupying object can go to the original object's location
-- 					if not ObjectCanGoToLocation(occupyingObjectInfo, object.location) then
-- 						return ObjectCanGoToLocation(occupyingObjectInfo, object.location)
-- 					end

-- 					local occupyingObjectCopy = table.clone(occupyingObject)
-- 					-- Place it in the original object's location
-- 					occupyingObjectCopy.location = object.location
-- 					occupyingObjectCopy.slotId = object.slotId
-- 					PlayerDataHandler.SetPathValue(player.UserId, { "objects", occupyingObjectId }, occupyingObjectCopy)

-- 					-- Update the location table with the occupying object
-- 					if occupyingObjectCopy.location and occupyingObjectCopy.slotId then
-- 						PlayerDataHandler.SetPathValue(
-- 							player.UserId,
-- 							{ occupyingObjectCopy.location, occupyingObjectCopy.slotId },
-- 							occupyingObjectId
-- 						)
-- 					end
-- 				end
-- 			end
-- 		end
-- 	else
-- 		-- Find free slot based on desired location
-- 		newSlotId = GetFreeSlotId(player, newLocation)
-- 		if not newSlotId then
-- 			return false, "No slots available in " .. newLocation
-- 		end
-- 	end

-- 	-- Clear old location if hasn't been occupied by another object
-- 	local oldLocation = object.location
-- 	local oldSlotId = object.slotId
-- 	if oldLocation and oldSlotId then
-- 		local oldLocationSlotObjectId = PlayerDataHandler.GetPathValue(player.UserId, { oldLocation, oldSlotId })
-- 		if oldLocationSlotObjectId == objectId then
-- 			PlayerDataHandler.SetPathValue(player.UserId, { oldLocation, oldSlotId }, nil)
-- 		end
-- 	end

-- 	-- Update object data
-- 	object.location = newLocation
-- 	object.slotId = newSlotId
-- 	PlayerDataHandler.SetPathValue(player.UserId, { "objects", objectId }, object)

-- 	-- Set new location
-- 	PlayerDataHandler.SetPathValue(player.UserId, { newLocation, newSlotId }, objectId)

-- 	return true
-- end

-- Adds a new stackable object or increments an existing object's quantity
function InventoryHandler.AddOrIncrementObject(
	inventoryId: string | number,
	objectCopy: ObjectTypes.ObjectCopy,
	location: ("inventory" | "hotbar" | "loadout" | "storage")?
): (boolean, string?)
	local inventory = Inventory.GetInventory(inventoryId)
	if not inventory then
		return false, "Inventory not found"
	end

	-- Check for existing object to increment
	local object = inventory:GetObjectOfKey(objectCopy.key)
	if object then
		local success, errMsg =
			inventory:IncrementObject(object.id, objectCopy.quantity or 1, object.location == "storage")
		if not success then
			local player = inventory:GetPlayer()
			if player then
				MessageHandler.SendMessageToPlayer(player, errMsg, "Error")
			end
			return false, errMsg
		end
	end

	-- Add new object
	return inventory:AddObject(objectCopy, location)
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

Utils.Signals.Connect("PlayerLoaded", function(player: Player)
	local playerData = PlayerDataHandler.GetDataInstance(player.UserId)
	if not playerData and player.Parent == game.Players then
		warn("InventoryHandler: Player data not found for userId " .. tostring(player.UserId))
	end

	Inventory.new(playerData, player.UserId)
end)

Utils.Signals.Connect("PlayerRemoving", function(player: Player)
	local inventory = Inventory.GetInventory(player.UserId)
	if inventory then
		inventory:Destroy()
	end
end)

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return InventoryHandler
