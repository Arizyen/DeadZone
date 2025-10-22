local Attack = {}
Attack.__index = Attack

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
local GamepassesInfo = require(ReplicatedInfo.Shop.GamepassesInfo)

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------
local rng = Random.new()

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Attack.new(player: Player)
	local self = setmetatable({}, Attack)

	-- Booleans
	self._destroyed = false
	self._quickHandsGamepass = PlayerDataHandler.GetPathValue({ "gamepasses", "quickHands" }) or false
	self._bluntForcePerk = PlayerDataHandler.GetPathValue({ "perks", "bluntForce" }) or false
	self._rapidStrikesPerk = PlayerDataHandler.GetPathValue({ "perks", "rapidStrikes" }) or false
	self._sharpshooterPerk = PlayerDataHandler.GetPathValue({ "perks", "sharpshooter" }) or false
	self._lastStandPerk = PlayerDataHandler.GetPathValue({ "perks", "lastStand" }) or false
	self._ammoSaverPerk = PlayerDataHandler.GetPathValue({ "perks", "ammoSaver" }) or false
	self._swiftHandsPerk = PlayerDataHandler.GetPathValue({ "perks", "swiftHands" }) or false

	self._lastStandPerkInEffect = false

	-- Instances
	self._player = player :: Player

	-- Numbers
	self._ammoSaveLuck = 0

	self:_Init()

	return self
end

function Attack:_Init()
	-- Gamepass connections
	Utils.Connections.Add(
		self,
		"quickHandsGamepass",
		PlayerDataHandler.ObservePlayerPath(
			self._player.UserId,
			{ "gamepasses", "quickHands" },
			function(value: boolean)
				self._quickHandsGamepass = value or false
				self:_UpdateReloadSpeed()
			end
		)
	)

	-- Perks connections
	Utils.Connections.Add(
		self,
		"bluntForcePerk",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "perks", "bluntForce" }, function(value: boolean)
			self._bluntForcePerk = value or false
			self:_UpdateDamage()
		end)
	)

	Utils.Connections.Add(
		self,
		"rapidStrikesPerk",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "perks", "rapidStrikes" }, function(value: boolean)
			self._rapidStrikesPerk = value or false
			self:_UpdateAttackSpeed()
		end)
	)

	Utils.Connections.Add(
		self,
		"sharpshooterPerk",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "perks", "sharpshooter" }, function(value: boolean)
			self._sharpshooterPerk = value or false
			self:_UpdateDamage()
		end)
	)

	Utils.Connections.Add(
		self,
		"lastStandPerk",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "perks", "lastStand" }, function(value: boolean)
			self._lastStandPerk = value or false
			self:_UpdateDamage()
		end)
	)

	Utils.Connections.Add(
		self,
		"ammoSaverPerk",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "perks", "ammoSaver" }, function(value: boolean)
			self._ammoSaverPerk = value or false
			self:_UpdateAmmoSaveLuck()
		end)
	)

	Utils.Connections.Add(
		self,
		"swiftHandsPerk",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "perks", "swiftHands" }, function(value: boolean)
			self._swiftHandsPerk = value or false
			self:_UpdateReloadSpeed()
		end)
	)

	-- HP connection for Last Stand perk
	Utils.Connections.Add(
		self,
		"lastStandHP",
		self._player:GetAttributeChangedSignal("hp"):Connect(function()
			if self._lastStandPerk then
				local playerHP = self._player:GetAttribute("hp")
				if type(playerHP) == "number" and playerHP <= 20 then
					if not self._lastStandPerkInEffect then
						self._lastStandPerkInEffect = true
						self:_UpdateDamage()
					end
				else
					if self._lastStandPerkInEffect then
						self._lastStandPerkInEffect = false
						self:_UpdateDamage()
					end
				end
			end
		end)
	)

	self:_UpdateDamage()
	self:_UpdateReloadSpeed()
	self:_UpdateAttackSpeed()
end

function Attack:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Attack:_UpdateDamage()
	local meleeDamageFactor = 1
	local rangedDamageFactor = 1

	if self._bluntForcePerk then
		local bluntForceInfo = PerksInfo.byKey.bluntForce
		meleeDamageFactor += bluntForceInfo.value
	end

	if self._sharpshooterPerk then
		local sharpshooterInfo = PerksInfo.byKey.sharpshooter
		rangedDamageFactor += sharpshooterInfo.value
	end

	if self._lastStandPerk then
		local playerHP = self._player:GetAttribute("hp")
		if type(playerHP) == "number" and playerHP <= 20 then
			local lastStandInfo = PerksInfo.byKey.lastStand
			meleeDamageFactor += lastStandInfo.value
			rangedDamageFactor += lastStandInfo.value
		end
	end

	PlayerDataHandler.SetPathValue(self._player.UserId, { "stats", "meleeDamageFactor" }, meleeDamageFactor)
	PlayerDataHandler.SetPathValue(self._player.UserId, { "stats", "rangedDamageFactor" }, rangedDamageFactor)
end

function Attack:_UpdateReloadSpeed()
	local reloadSpeedFactor = 1

	if self._quickHandsGamepass then
		local quickHandsInfo = GamepassesInfo.quickHands
		reloadSpeedFactor += quickHandsInfo.value
	end

	if self._swiftHandsPerk then
		local swiftHandsInfo = PerksInfo.byKey.swiftHands
		reloadSpeedFactor += swiftHandsInfo.value
	end

	PlayerDataHandler.SetPathValue(self._player.UserId, { "stats", "reloadSpeedFactor" }, reloadSpeedFactor)
end

function Attack:_UpdateAttackSpeed()
	local meleeSpeedFactor = 1

	if self._rapidStrikesPerk then
		local rapidStrikesInfo = PerksInfo.byKey.rapidStrikes
		meleeSpeedFactor += rapidStrikesInfo.value
	end

	PlayerDataHandler.SetPathValue(self._player.UserId, { "stats", "meleeSpeedFactor" }, meleeSpeedFactor)
end

function Attack:_UpdateAmmoSaveLuck()
	local ammoSaveLuck = 0

	if self._ammoSaverPerk then
		local ammoSaverInfo = PerksInfo.byKey.ammoSaver
		ammoSaveLuck += ammoSaverInfo.value
	end

	self._ammoSaveLuck = ammoSaveLuck
end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Attack:_CanSaveAmmo(): boolean
	if self._ammoSaveLuck <= 0 then
		return false
	end

	return rng:NextNumber() <= self._ammoSaveLuck
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Attack
