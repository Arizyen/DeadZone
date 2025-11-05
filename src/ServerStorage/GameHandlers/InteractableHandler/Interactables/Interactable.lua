local Interactable = {}
Interactable.__index = Interactable

-- Services ------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
local Interactables = require(script.Parent)
local Inventory = require(GameHandlers.InventoryHandler.Inventory)

-- Handlers --------------------------------------------------------------------
local DataHandler = require(BaseHandlers.DataHandler)

-- Types ---------------------------------------------------------------------------
local InteractableTypes = require(ReplicatedTypes.InteractableTypes)

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Interactable.new(data: InteractableTypes.Interactable): typeof(Interactable)
	local self = setmetatable({}, Interactable)

	-- Booleans
	self._destroyed = false

	-- Strings
	self._id = nil :: string

	-- Instances
	self._dataReplicator = DataHandler.CreateDataReplicator(data or {})
	self._inventory = Inventory.new(self._dataReplicator, self._id, true)

	self:_Init()

	return self
end

function Interactable:_Init()
	self._id = self._dataReplicator:GetId()
	Interactables[self._id] = self

	-- Spawn instance in world
end

function Interactable:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true
	Interactables[self._id] = nil

	Utils.Connections.DisconnectKeyConnections(self)

	-- Destroy instances
	self._inventory:Destroy()
	self._dataReplicator:Destroy()
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Interactable:GetInventory(): typeof(Inventory)
	return self._inventory
end

function Interactable:AddPlayerListener(player: Player)
	self._dataReplicator:AddPlayerListener(player)
end

function Interactable:RemovePlayerListener(player: Player)
	self._dataReplicator:RemovePlayerListener(player)
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Interactable
