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

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local mergeDeep = Utils.Table.Dictionary.mergeDeep

local function SendErrorMessageToPlayer(player: Player, message: string)
	if not player or not message then
		return
	end

	MessageHandler.SendMessageToPlayer(player, message, "Error")
end

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function InventoryHandler.Register(ports: Ports.Ports)
	Utils.Table.Dictionary.mergeMut(Ports, ports)
end

-- GETTERS ----------------------------------------------------------------------------------------------------

-- Checks if the inventory has enough total quantity of the specified object key
function InventoryHandler.HasEnoughQuantity(
	inventoryId: string | number,
	objectKey: string,
	requiredQuantity: number
): boolean
	local inventory = Inventory.GetInventory(inventoryId)
	if not inventory then
		return false
	end

	local totalQuantity = inventory:GetTotalQuantity(objectKey)
	return totalQuantity >= requiredQuantity
end

-- SETTERS ----------------------------------------------------------------------------------------------------

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

	local success, errMsg = inventory:AddObject(objectCopy, location)
	if success then
		inventory:ObjectAdded(objectCopy.key, objectCopy.quantity or 1)
	end

	return success, errMsg
end

-- - Adds a new stackable object or increments an existing object's quantity
-- - If object is not stackable, it will just add the object normally (prefer using AddObject if not stackable)
function InventoryHandler.AddOrIncrementObject(
	inventoryId: string | number,
	objectCopy: ObjectTypes.ObjectCopy,
	location: ("inventory" | "hotbar" | "loadout" | "storage")?,
	sendErrorMessageToPlayer: boolean?,
	fitQuantity: boolean?
): (boolean, string?)
	local inventory = Inventory.GetInventory(inventoryId)
	if not inventory then
		return false, "Inventory not found"
	end

	-- Check for existing object to increment
	local object = inventory:GetObjectOfKey(objectCopy.key)
	local objectInfo = ObjectsInfo.byKey[objectCopy.key]

	if not objectInfo then
		return false, "Object info not found"
	end

	local player = inventory:GetPlayer()

	if object and objectInfo.stackable then
		if fitQuantity then
			-- Check quantity capacity left
			local quantityCapacityLeft = inventory:GetQuantityCapacityLeft(objectInfo, object.location)
			if quantityCapacityLeft <= 0 then
				SendErrorMessageToPlayer(sendErrorMessageToPlayer and player or nil, "No capacity left!")
				return false, "No capacity left!"
			end

			local quantityToAdd = math.min(objectCopy.quantity or 1, quantityCapacityLeft)
			local success, errMsg = inventory:IncrementObject(object, quantityToAdd)
			if not success then
				SendErrorMessageToPlayer(sendErrorMessageToPlayer and player or nil, errMsg)
				return false, errMsg
			else
				inventory:ObjectAdded(objectCopy.key, quantityToAdd)
			end
		else
			-- Just add the full quantity
			local success, errMsg = inventory:IncrementObject(object, objectCopy.quantity or 1)
			if not success then
				SendErrorMessageToPlayer(sendErrorMessageToPlayer and player or nil, errMsg)
				return false, errMsg
			else
				inventory:ObjectAdded(objectCopy.key, objectCopy.quantity or 1)
			end
		end

		return true
	end

	-- Add new object
	local success, errMsg = inventory:AddObject(objectCopy, location)
	if not success then
		SendErrorMessageToPlayer(sendErrorMessageToPlayer and player or nil, errMsg)
		return false, errMsg
	else
		inventory:ObjectAdded(objectCopy.key, objectCopy.quantity or 1)
	end
	return true
end

-- Removes an object from the player's inventory, hotbar, or loadout
function InventoryHandler.RemoveObjectId(inventoryId: string | number, objectId: string): boolean
	local inventory = Inventory.GetInventory(inventoryId)
	if not inventory then
		return false, "Inventory not found"
	end

	local object = inventory:GetObject(objectId)
	if not object then
		return false, "Object not found"
	end

	local success, errMsg = inventory:RemoveObject(object)
	if success then
		inventory:ObjectRemoved(object.key, object.quantity or 1)
	end

	return success, errMsg
end

-- - Decrements the quantity of all stackable objects of key objectKey by a specified amount or removes it if quantity reaches zero
-- - Does not check for enough quantity, caller must ensure that enough quantity exists
function InventoryHandler.DecrementObjectTotal(
	inventoryId: string | number,
	objectKey: string,
	decrementBy: number
): (boolean, (string | number)?)
	local inventory = Inventory.GetInventory(inventoryId)
	if not inventory then
		return false, "Inventory not found"
	end

	local success, result = inventory:DecrementObjectTotal(objectKey, decrementBy)
	if success then
		inventory:ObjectRemoved(objectKey, result)
	end

	return success, result
end

-- UTILITIES ----------------------------------------------------------------------------------------------------

-- Moves an object to a new location and slotId
function InventoryHandler.MoveObject(
	player: Player,
	from: {
		inventoryId: string | number,
		location: "inventory" | "hotbar" | "loadout" | "storage",
		slotId: string,
	},
	to: {
		inventoryId: string | number,
		location: "inventory" | "hotbar" | "loadout" | "storage",
		slotId: string,
	}
): (boolean, string?)
	-- Get inventories
	local fromInventory = Inventory.GetInventory(from.inventoryId)
	if not fromInventory then
		return false, "Source inventory not found"
	end

	local toInventory = Inventory.GetInventory(to.inventoryId)
	if not toInventory then
		return false, "Destination inventory not found"
	end

	-- Confirm player can access both inventories
	local fromInventoryPlayer = fromInventory:GetPlayer()
	local toInventoryPlayer = toInventory:GetPlayer()

	if fromInventoryPlayer and fromInventoryPlayer ~= player then
		return false, "Cannot access source inventory"
	elseif toInventoryPlayer and toInventoryPlayer ~= player then
		return false, "Cannot access destination inventory"
	end

	-- Get objects from inventories
	local fromObject = fromInventory:GetObjectFromLocation(from.location, from.slotId)
	if not fromObject then
		return false, "Source object not found"
	end

	local toObject = toInventory:GetObjectFromLocation(to.location, to.slotId)

	-- Get object info
	local objectInfo = ObjectsInfo.byKey[fromObject.key]
	if not objectInfo then
		return false, "Object info not found"
	end

	if toObject then
		if fromObject.key == toObject.key and objectInfo.stackable then
			-- Same object key, attempt to stack
			-- Check quantity capacity left in destination
			local quantityCapacityLeft = toInventory:GetQuantityCapacityLeft(objectInfo, toObject.location)
			if quantityCapacityLeft < (fromObject.quantity or 1) then
				return false, "No capacity left!"
			end

			if quantityCapacityLeft < (fromObject.quantity or 1) then
				-- Move only what can fit
				local success, errMsg = toInventory:IncrementObject(toObject, quantityCapacityLeft)
				if success then
					-- Successfully stacked, decrement from source
					success, errMsg = fromInventory:DecrementObject(fromObject, quantityCapacityLeft)
					if not success then
						-- Rollback increment
						toInventory:DecrementObject(toObject, quantityCapacityLeft)
						return false, errMsg
					end
				else
					return false, errMsg
				end
			else
				-- Move all
				local success, errMsg = toInventory:IncrementObject(toObject, fromObject.quantity or 1)
				if success then
					-- Successfully stacked, remove from source
					success, errMsg = fromInventory:RemoveObjectId(fromObject.id)
					if not success then
						-- Rollback increment
						toInventory:DecrementObject(toObject, fromObject.quantity or 1)
						return false, errMsg
					end
				else
					return false, errMsg
				end
			end
		else
			-- Different object keys, swap objects
			-- Remove objects from both inventories
			local success, errMsg = fromInventory:RemoveObjectId(fromObject.id)
			if not success then
				return false, errMsg
			end

			success, errMsg = toInventory:RemoveObjectId(toObject.id)
			if not success then
				-- Rollback removal
				fromInventory:AddObject(fromObject, from.location, from.slotId)
				return false, errMsg
			end

			-- Add objects to new locations
			success, errMsg = toInventory:AddObject(fromObject, to.location, to.slotId)
			if not success then
				-- Rollback removals
				fromInventory:AddObject(fromObject, from.location, from.slotId)
				toInventory:AddObject(toObject, to.location, to.slotId)
				return false, errMsg
			end

			success, errMsg = fromInventory:AddObject(toObject, from.location, from.slotId)
			if not success then
				-- Rollback additions
				toInventory:RemoveObjectFromLocation(to.location, to.slotId)
				fromInventory:AddObject(fromObject, from.location, from.slotId)
				return false, errMsg
			end
		end
	else
		-- Check quantity capacity left in destination
		local quantityCapacityLeft = toInventory:GetQuantityCapacityLeft(objectInfo, to.location)
		if quantityCapacityLeft < (fromObject.quantity or 1) then
			return false, "No capacity left!"
		end

		if objectInfo.stackable and quantityCapacityLeft < (fromObject.quantity or 1) then
			-- Move only what can fit
			local success, errMsg = toInventory:AddObject(
				mergeDeep(fromObject, { quantity = quantityCapacityLeft }),
				to.location,
				to.slotId
			)

			if success then
				-- Successfully added, decrement from source
				success, errMsg = fromInventory:DecrementObject(fromObject, quantityCapacityLeft)
				if not success then
					-- Rollback addition
					toInventory:RemoveObjectFromLocation(to.location, to.slotId)
					return false, errMsg
				end
			else
				return false, errMsg
			end
		else
			-- Add object to new location
			local success, errMsg = toInventory:AddObject(fromObject, to.location, to.slotId)
			if not success then
				return false, errMsg
			end

			-- Remove object from old location
			success, errMsg = fromInventory:RemoveObjectId(fromObject.id)
			if not success then
				-- Rollback addition
				toInventory:RemoveObjectFromLocation(to.location, to.slotId)
				return false, errMsg
			end
		end
	end

	return true
end

function InventoryHandler.Spend(inventoryId: string, objectKeyQuantityMap: { [string]: number }): (boolean, string?)
	local inventory = Inventory.GetInventory(inventoryId)
	if not inventory then
		return false, "Inventory not found"
	end

	-- Confirm enough quantity for all objects
	for objectKey, quantity in pairs(objectKeyQuantityMap) do
		local totalQuantity = inventory:GetTotalQuantity(objectKey)
		if totalQuantity < quantity then
			local errorMessage = ("Not enough %s%s! You need %s."):format(
				objectKey,
				totalQuantity > 1 and "s" or "",
				quantity
			)
			return false, errorMessage
		end
	end

	-- Decrement all objects
	for objectKey, quantity in pairs(objectKeyQuantityMap) do
		local success, result = inventory:DecrementObjectTotal(objectKey, quantity)
		if not success then
			return false, result
		else
			inventory:ObjectRemoved(objectKey, result)
		end
	end

	return true
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
