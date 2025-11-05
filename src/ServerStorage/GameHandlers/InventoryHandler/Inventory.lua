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

local function CreateObject(object: ObjectTypes.Object)
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

	-- Strings
	self._id = id

	-- Instances
	self._tableObserver = tableObserver :: typeof(TableObserver)

	self:_Init()

	return self
end

function Inventory:_Init()
	inventories[self._id] = self
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

		for i = 1, GameConfigs.MAX_INVENTORY_SLOTS do
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
		elseif location == "backpack" then
			local backpack = self._tableObserver:GetKeyValue({ "backpack" })
			if not backpack then
				return nil
			end

			for i = 1, GameConfigs.MAX_INVENTORY_SLOTS do
				local slotId = "slot" .. tostring(i)
				if not backpack[slotId] then
					return slotId
				end
			end
		end
	end

	return nil
end

function Inventory:_GetQuantityCapacityLeft(objectInfo: ObjectTypes.Object, inBackpack: boolean): number
	if inBackpack and self._isAnInteractable then
		warn("Cannot check backpack capacity on interactable inventories.")
		return 0
	end

	if objectInfo.weightPerUnit then
		if inBackpack and not self._tableObserver:GetPathValue({ "backpack" }) then
			return 0
		end

		local inventoryCapacity = self._tableObserver:GetPathValue({
			(inBackpack and "backpack" or "stats"),
			"inventoryCapacity",
		}) or 0
		local capacityUsed = self._tableObserver:GetPathValue(
			inBackpack and { "backpack", "capacityUsed" } or { "capacityUsed" }
		) or 0
		local capacityLeft = inventoryCapacity - capacityUsed

		return math.floor(capacityLeft / objectInfo.weightPerUnit)
	end

	return math.huge
end

function Inventory:_ObjectCanGoToLocation(objectInfo: ObjectTypes.Object, location: string): (boolean, string?)
	if location == "inventory" then
	elseif not self._isAnInteractable then
		if location == "hotbar" and objectInfo.type ~= "tool" then
			return false, "Only tools can be placed in the hotbar"
		elseif location == "loadout" and objectInfo.type ~= "wearable" then
			return false, "Only wearables can be placed in the loadout"
		end
	end

	return true
end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Inventory:PlayerCanAccess(player: Player): boolean
	if self._isAnInteractable then
		return self._tableObserver:IsPlayerAListener(player)
	else
		return self._tableObserver:GetPlayer() == player
	end
end

-- Adds a new object to the player's inventory, hotbar, or loadout
function Inventory:AddObject(
	objectCopy: ObjectTypes.ObjectCopy,
	location: ("inventory" | "hotbar" | "loadout" | "backpack")?
): (boolean, string?)
	assert(objectCopy and objectCopy.key, "InventoryHandler.AddObject: Invalid object provided")
	assert(ObjectsInfo.byKey[objectCopy.key], "InventoryHandler.AddObject: Object key not found in ObjectsInfo")

	location = location or "inventory"

	local freeSlotKey = self:_GetFreeSlotId(location)
	if not freeSlotKey and location == "hotbar" then
		location = "inventory"
		freeSlotKey = self:_GetFreeSlotId(location)
	end

	if not freeSlotKey then
		return false, "No slots available" -- No free slot found
	end

	-- Create and add object
	local newObject = CreateObject(objectCopy)
	newObject.location = location
	newObject.slotId = freeSlotKey

	self._tableObserver:SetPathValue({ "objects", newObject.id }, newObject)
	self._tableObserver:InsertAtPathValue({ "objectsCategorized", newObject.key }, newObject.id)
	self._tableObserver:SetPathValue({ location, freeSlotKey }, newObject.id)

	return true
end

function Inventory:RemoveObject(objectId: string): (boolean, string?)
	local object: ObjectTypes.ObjectCopy? = self._tableObserver:GetPathValue({ "objects", objectId })
	if not object then
		return false, "Object not found in inventory"
	end

	-- Remove objectId from slotId
	local location = object.location
	local slotId = object.slotId
	if location and slotId then
		local locationSlotObjectId = self._tableObserver:GetPathValue({ location, slotId })
		if locationSlotObjectId == objectId then
			self._tableObserver:SetPathValue({ location, slotId }, nil)
		end
	end

	-- Remove object from objects and objectsCategorized
	self._tableObserver:RemoveAtPathValue({ "objectsCategorized", object.key }, objectId)

	-- Remove from objects
	self._tableObserver:SetPathValue({ "objects", objectId }, nil)

	return true
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Inventory
