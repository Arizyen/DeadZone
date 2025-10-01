local Resource = {}
Resource.__index = Resource

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

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Resource.new(player: Player)
	local self = setmetatable({}, Resource)

	-- Booleans
	self._destroyed = false
	self._efficientMinerPerk = false
	self._efficientLumberjackPerk = false
	self._efficientCrafterPerk = false

	-- Instances
	self._player = player :: Player

	self:_Init()

	return self
end

function Resource:_Init()
	-- Connections
	Utils.Connections.Add(
		self,
		"efficientMinerPerk",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "perks", "efficientMiner" }, function(newValue)
			self._efficientMinerPerk = newValue or false
			self:_UpdateMiningSpeed()
		end)
	)

	Utils.Connections.Add(
		self,
		"efficientLumberjackPerk",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "perks", "efficientLumberjack" }, function(newValue)
			self._efficientLumberjackPerk = newValue or false
			self:_UpdateChoppingSpeed()
		end)
	)

	Utils.Connections.Add(
		self,
		"efficientCrafterPerk",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "perks", "efficientCrafter" }, function(newValue)
			self._efficientCrafterPerk = newValue or false
			self:_UpdateCraftingCost()
		end)
	)

	self:_UpdateMiningSpeed()
	self:_UpdateChoppingSpeed()
	self:_UpdateCraftingCost()
end

function Resource:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Resource:_UpdateMiningSpeed()
	local miningSpeedFactor = 1

	if self._efficientMinerPerk then
		local efficientMinerPerkInfo = PerksInfo.byKey.efficientMiner
		miningSpeedFactor += efficientMinerPerkInfo.value
	end

	PlayerDataHandler.SetPathValue(self._player.UserId, { "stats", "miningSpeedFactor" }, miningSpeedFactor)
end

function Resource:_UpdateChoppingSpeed()
	local choppingSpeedFactor = 1

	if self._efficientLumberjackPerk then
		local efficientLumberjackPerkInfo = PerksInfo.byKey.efficientLumberjack
		choppingSpeedFactor += efficientLumberjackPerkInfo.value
	end

	PlayerDataHandler.SetPathValue(self._player.UserId, { "stats", "choppingSpeedFactor" }, choppingSpeedFactor)
end

function Resource:_UpdateCraftingCost()
	local craftingCostFactor = 1

	if self._efficientCrafterPerk then
		local efficientCrafterPerkInfo = PerksInfo.byKey.efficientCrafter
		craftingCostFactor += efficientCrafterPerkInfo.value
	end

	PlayerDataHandler.SetPathValue(self._player.UserId, { "stats", "craftingCostFactor" }, craftingCostFactor)
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

return Resource
