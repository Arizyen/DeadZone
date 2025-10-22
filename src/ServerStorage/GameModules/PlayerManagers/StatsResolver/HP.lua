local HP = {}
HP.__index = HP

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
local GamepassesInfo = require(ReplicatedInfo.Shop.GamepassesInfo)
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

function HP.new(player)
	local self = setmetatable({}, HP)

	-- Booleans
	self._destroyed = false
	self._x2HPRegenGamepass = PlayerDataHandler.GetPathValue(player.UserId, { "gamepasses", "x2HPRegen" }) or false
	self._hpRegenPerk = PlayerDataHandler.GetPathValue(player.UserId, { "perks", "hpRegen" }) or false
	self._ironSkinGamepass = PlayerDataHandler.GetPathValue(player.UserId, { "gamepasses", "ironSkin" }) or false
	self._thickSkinPerk = PlayerDataHandler.GetPathValue(player.UserId, { "perks", "thickSkin" }) or false

	-- Instances
	self._player = player :: Player

	self:_Init()

	return self
end

function HP:_Init()
	-- Connections
	Utils.Connections.Add(
		self,
		"x2HPRegenGamepassChanged",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "gamepasses", "x2HPRegen" }, function(newValue)
			self._x2HPRegenGamepass = newValue or false
			self:_UpdateHPRegenSpeed()
		end)
	)

	Utils.Connections.Add(
		self,
		"hpRegenPerkChanged",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "perks", "hpRegen" }, function(newValue)
			self._hpRegenPerk = newValue or false
			self:_UpdateHPRegenSpeed()
		end)
	)

	Utils.Connections.Add(
		self,
		"thickSkinPerkChanged",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "perks", "thickSkin" }, function(newValue)
			self._thickSkinPerk = newValue or false
			self:_UpdateDamageFactor()
		end)
	)

	self:_UpdateHPRegenSpeed()
	self:_UpdateDamageFactor()
end

function HP:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function HP:_UpdateHPRegenSpeed()
	local hpRegenFactor = 1

	if self._x2HPRegenGamepass then
		local gamepassInfo = GamepassesInfo.byKey.x2HPRegen
		hpRegenFactor += gamepassInfo.value
	end

	if self._hpRegenPerk then
		local perkInfo = PerksInfo.byKey.hpRegen
		hpRegenFactor += perkInfo.value
	end

	PlayerDataHandler.SetPathValue(self._player.UserId, { "stats", "hpRegenFactor" }, hpRegenFactor)
end

function HP:_UpdateDamageFactor()
	local damageFactor = 1

	if self._ironSkinGamepass then
		local gamepassInfo = GamepassesInfo.byKey.ironSkin
		damageFactor -= gamepassInfo.value
	end

	if self._thickSkinPerk then
		local perkInfo = PerksInfo.byKey.thickSkin
		damageFactor -= perkInfo.value
	end

	PlayerDataHandler.SetPathValue(self._player.UserId, { "stats", "damageFactor" }, damageFactor)
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

return HP
