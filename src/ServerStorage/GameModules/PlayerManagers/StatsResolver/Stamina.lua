local Stamina = {}
Stamina.__index = Stamina

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
local MovementConfigs = require(ReplicatedConfigs.MovementConfigs)

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Stamina.new(player: Player)
	local self = setmetatable({}, Stamina)

	-- Booleans
	self._destroyed = false
	self._staminaBoostGamepass = PlayerDataHandler.GetPathValue(player.UserId, { "gamepasses", "staminaBonus100" })
		or false
	self._enduranceTrainingPerk = PlayerDataHandler.GetPathValue(player.UserId, { "perks", "enduranceTraining" })
		or false
	self._ironLungsPerk = PlayerDataHandler.GetPathValue(player.UserId, { "perks", "ironLungs" }) or false

	-- Instances
	self._player = player :: Player

	-- Numbers

	self:_Init()

	return self
end

function Stamina:_Init()
	Utils.Connections.Add(
		self,
		"StaminaGamepass",
		PlayerDataHandler.ObservePlayerPath(
			self._player.UserId,
			{ "gamepasses", "staminaBonus100" },
			function(hasGamepass)
				self._staminaBoostGamepass = hasGamepass
				self:_UpdateMaxStamina()
			end
		)
	)

	-- Perks connections
	Utils.Connections.Add(
		self,
		"enduranceTrainingPerk",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "perks", "enduranceTraining" }, function(value)
			self._enduranceTrainingPerk = value
			self:_UpdateConsumptionRate()
		end)
	)

	Utils.Connections.Add(
		self,
		"ironLungsPerk",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "perks", "ironLungs" }, function(value)
			self._ironLungsPerk = value
			self:_UpdateMaxStamina()
		end)
	)

	self:_UpdateMaxStamina()
	self:_UpdateConsumptionRate()
end

function Stamina:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Stamina:_UpdateMaxStamina()
	local maxStamina = MovementConfigs.STAMINA

	if self._staminaBoostGamepass then
		local gamepassInfo = GamepassesInfo.byKey.staminaBonus100
		maxStamina += gamepassInfo.value
	end

	PlayerDataHandler.SetPathValue(self._player.UserId, { "stats", "maxStamina" }, maxStamina)
end

function Stamina:_UpdateConsumptionRate()
	local drainingPercentageFactor = 1

	if self._enduranceTrainingPerk then
		local enduranceTrainingPerkInfo = PerksInfo.byKey.enduranceTraining
		drainingPercentageFactor -= enduranceTrainingPerkInfo.value
	end

	PlayerDataHandler.SetPathValue(
		self._player.UserId,
		{ "stats", "staminaConsumptionRate" },
		MovementConfigs.STAMINA_CONSUMPTION_RATE * drainingPercentageFactor
	)
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

return Stamina
