local Inventory = {}
Inventory.__index = Inventory

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

-- Handlers --------------------------------------------------------------------
local PlayerDataHandler = require(BaseHandlers.PlayerDataHandler)

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------
local PerksInfo = require(ReplicatedInfo.PerksInfo)

-- Configs -------------------------------------------------------------------------
local GameConfigs = require(ReplicatedConfigs.GameConfigs)

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Inventory.new(player: Player)
	local self = setmetatable({}, Inventory)

	-- Booleans
	self._destroyed = false
	self._lightweightPerk = false
	self._packRatPerk = false

	-- Instances
	self._player = player :: Player

	self:_Init()

	return self
end

function Inventory:_Init()
	-- Connections
	Utils.Connections.Add(
		self,
		"lightweightPerk",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "perks", "lightweight" }, function(newValue)
			self._lightweightPerk = newValue or false
			self:_UpdateInventorySlots()
		end)
	)

	Utils.Connections.Add(
		self,
		"packRatPerk",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "perks", "packRat" }, function(newValue)
			self._packRatPerk = newValue or false
			self:_UpdateHotbarSlots()
		end)
	)

	self:_UpdateInventorySlots()
	self:_UpdateHotbarSlots()
end

function Inventory:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Inventory:_UpdateInventorySlots()
	local baseInventorySlots = GameConfigs.INVENTORY_SLOTS

	if self._lightweightPerk then
		local lightweightPerkInfo = PerksInfo.byKey.lightweight
		baseInventorySlots += lightweightPerkInfo.value
	end

	PlayerDataHandler.SetPathValue({ "stats", "inventorySlots" }, baseInventorySlots)
end

function Inventory:_UpdateHotbarSlots()
	local baseHotbarSlots = GameConfigs.HOTBAR_SLOTS

	if self._packRatPerk then
		local packRatPerkInfo = PerksInfo.byKey.packRat
		baseHotbarSlots += packRatPerkInfo.value
	end

	PlayerDataHandler.SetPathValue({ "stats", "hotbarSlots" }, baseHotbarSlots)
end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Inventory
