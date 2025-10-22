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
local PlayerManager = require(BaseModules.PlayerManager)

-- Handlers --------------------------------------------------------------------
local PlayerDataHandler = require(BaseHandlers.PlayerDataHandler)

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local StateConfigs = require(Configs.StateConfigs)

-- Variables -----------------------------------------------------------------------
local hpRegainTimerRunning = false

-- Tables --------------------------------------------------------------------------
local hpManagers = {} :: { [number]: typeof(HP) } -- Key is player UserId, value is HP manager
local hpManagersRegenBag = {} :: { [number]: boolean } -- Key is player UserId, value is whether the player is in the regain HP phase

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function StartHPRegenTimer()
	if hpRegainTimerRunning or not next(hpManagersRegenBag) then
		return
	end
	hpRegainTimerRunning = true

	task.spawn(function()
		while next(hpManagersRegenBag) ~= nil do
			for userId, _ in pairs(hpManagersRegenBag) do
				local hpManager = hpManagers[userId]
				if hpManager then
					hpManager:Regenerate()
				else
					hpManagersRegenBag[userId] = nil
				end
			end

			task.wait(1)
		end

		hpRegainTimerRunning = false
	end)
end

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function HP.new(player: Player, stateManager)
	local self = setmetatable({}, HP)

	-- Booleans
	self._destroyed = false

	-- Numbers
	self._hpMax = StateConfigs.HP_MAX
	self._lastDamageReceivedTime = 0
	self._hpRegenFactor = PlayerDataHandler.GetPathValue(player.UserId, { "stats", "hpRegenFactor" }) or 1
	self._damageFactor = PlayerDataHandler.GetPathValue(player.UserId, { "stats", "damageFactor" }) or 1

	-- Instances
	self._player = player

	-- Metatables
	self.stateManager = stateManager

	self:_Init()

	return self
end

function HP:_Init()
	hpManagers[self._player.UserId] = self

	-- Connections
	-- On player hp change
	Utils.Connections.Add(
		self,
		"hpChanged",
		self._player:GetAttributeChangedSignal("hp"):Connect(function()
			local newHP = self._player:GetAttribute("hp") :: number
			local currentHP = self.stateManager.state.hp
			self.stateManager.state.hp = math.clamp(newHP, 0, self._hpMax)

			if newHP == currentHP then
				return
			end

			if newHP >= self._hpMax then
				hpManagersRegenBag[self._player.UserId] = nil
			elseif newHP < currentHP and newHP < self._hpMax then
				self:_StartHPRegen()
			end
		end)
	)

	-- On player maxHP change
	Utils.Connections.Add(
		self,
		"hpMaxChanged",
		self._player:GetAttributeChangedSignal("hpMax"):Connect(function()
			local newMaxHP = self._player:GetAttribute("hpMax") :: number
			if newMaxHP == self._hpMax then
				return
			elseif newMaxHP > self._hpMax then
				self:_StartHPRegen()
			end

			self._hpMax = newMaxHP
		end)
	)

	-- Stats change
	Utils.Connections.Add(
		self,
		"hpRegenFactorChanged",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "stats", "hpRegenFactor" }, function(newFactor)
			self._hpRegenFactor = newFactor or 1
		end)
	)

	Utils.Connections.Add(
		self,
		"damageFactorChanged",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "stats", "damageFactor" }, function(newFactor)
			self._damageFactor = newFactor or 1
		end)
	)

	PlayerManager.SetMaxVital(self._player, "hp", self._hpMax)
	PlayerManager.SetVital(self._player, "hp", self.stateManager.state.hp)
end

function HP:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	hpManagers[self._player.UserId] = nil
	hpManagersRegenBag[self._player.UserId] = nil

	Utils.Connections.DisconnectKeyConnections(self)
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function HP:_StartHPRegen()
	if self.stateManager.state.hp >= self._hpMax then
		return
	end

	self._lastDamageReceivedTime = os.clock()
	hpManagersRegenBag[self._player.UserId] = true
	StartHPRegenTimer()
end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function HP:GetStartingHP(): number
	local currentHP = self.stateManager.state.hp

	return currentHP > 0 and currentHP or self._hpMax
end

function HP:GetMaxHP(): number
	return self._hpMax
end

function HP:Regenerate()
	-- If the player has not taken damage in the last HP_REGEN_WAIT seconds, regen HP
	if os.clock() - self._lastDamageReceivedTime >= StateConfigs.HP_REGEN_WAIT then
		self:Increment((StateConfigs.HP_REGEN_FACTOR * self._hpRegenFactor) * self._hpMax)
	end
end

function HP:Increment(amount: number)
	if amount < 0 then
		amount = amount * self._damageFactor
	end

	amount = Utils.Math.Round(amount, 2)

	return PlayerManager.IncrementVital(self._player, "hp", amount)
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return HP
