local XP = {}
XP.__index = XP

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
local Level = require(BaseModules.Level)

-- Handlers --------------------------------------------------------------------
local PlayerDataHandler = require(BaseHandlers.PlayerDataHandler)

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------
local gamepassesInfo = require(ReplicatedInfo.Shop.GamepassesInfo)
local perksInfo = require(ReplicatedInfo.PerksInfo)

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function XP.new(player: Player)
	local self = setmetatable({}, XP)

	-- Booleans
	self._destroyed = false
	self._vipGamepass = PlayerDataHandler.GetPathValue(player.UserId, { "gamepasses", "vip" }) or false
	self._quickLearnerPerk = PlayerDataHandler.GetPathValue(player.UserId, { "perks", "quickLearner" }) or false

	-- Instances
	self._player = player :: Player

	-- Numbers
	self._xpFactor = 1

	self:_Init()

	return self
end

function XP:_Init()
	-- Connections
	Utils.Connections.Add(
		self,
		"vipGamepassChanged",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "gamepasses", "vip" }, function(newValue)
			self._vipGamepass = newValue or false
			self:_UpdateXPFactor()
		end)
	)

	Utils.Connections.Add(
		self,
		"quickLearnerPerkChanged",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "perks", "quickLearner" }, function(newValue)
			self._quickLearnerPerk = newValue or false
			self:_UpdateXPFactor()
		end)
	)

	self:_UpdateXPFactor()
end

function XP:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function XP:_UpdateXPFactor()
	local xpFactor = 1

	if self._vipGamepass then
		local gamepassInfo = gamepassesInfo.byKey.vip
		xpFactor += gamepassInfo.value
	end

	if self._quickLearnerPerk then
		local quickLearnerPerkInfo = perksInfo.byKey.quickLearner
		xpFactor += quickLearnerPerkInfo.value
	end

	self._xpFactor = xpFactor
	PlayerDataHandler.SetPathValue(self._player.UserId, { "stats", "xpFactor" }, xpFactor)
end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function XP:Add(amount: number)
	amount = amount * self._xpFactor
	Level.AddXP(self._player, amount, true)
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return XP
