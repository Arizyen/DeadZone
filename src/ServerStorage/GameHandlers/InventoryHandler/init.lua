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
	object: ObjectTypes.Object,
	location: "inventory" | "hotbar"
): (boolean, string?)
	assert(object and object.key, "InventoryHandler.AddObject: Invalid object provided")

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
	local newObject = CreateObject(object)
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

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return InventoryHandler
