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
local hpManagersRegainBag = {} :: { [number]: boolean } -- Key is player UserId, value is whether the player is in the regain HP phase

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function StartHPRegainTimer()
	if hpRegainTimerRunning or not next(hpManagersRegainBag) then
		return
	end
	hpRegainTimerRunning = true

	task.spawn(function()
		while next(hpManagersRegainBag) ~= nil do
			local now = os.clock()

			for userId, _ in pairs(hpManagersRegainBag) do
				local hpManager = hpManagers[userId]
				if hpManager then
					-- If the player's energy is at 0, do not regain HP
					if hpManager.stateManager.state.energy <= 0 then
						continue
					end

					-- If the player has not taken damage in the last HP_REGAIN_WAIT seconds, regain HP
					if now - hpManager._lastDamageReceivedTime >= StateConfigs.HP_REGAIN_WAIT then
						hpManager:Increment(StateConfigs.HP_REGAIN_RATE)
					end
				else
					hpManagersRegainBag[userId] = nil
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

			if newHP == currentHP then
				return
			end

			if newHP >= self._hpMax then
				hpManagersRegainBag[self._player.UserId] = nil
			elseif newHP < currentHP and newHP < self._hpMax then
				self._lastDamageReceivedTime = os.clock()
				self:_StartHPRegain()
			end

			self.stateManager.state.hp = math.clamp(newHP, 0, self._hpMax)
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
				self:_StartHPRegain()
			end

			self._hpMax = newMaxHP
		end)
	)

	self:Update()
end

function HP:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	hpManagers[self._player.UserId] = nil
	hpManagersRegainBag[self._player.UserId] = nil

	Utils.Connections.DisconnectKeyConnections(self)
end

-- Decays HP over time if energy is 0
function HP:Update(elapsedTime: number?)
	if self._destroyed then
		return
	end

	if not elapsedTime or elapsedTime <= 0 then
		PlayerManager.SetMaxVital(self._player, "hp", self._hpMax)
		PlayerManager.SetVital(self._player, "hp", self.stateManager.state.hp)
		return
	end

	-- If the player's energy is at 0, decay HP
	if self.stateManager.state.energy <= 0 then
		self:Increment(-(StateConfigs.HP_DECAY_RATE * elapsedTime))
	end
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function HP:_StartHPRegain()
	hpManagersRegainBag[self._player.UserId] = true
	StartHPRegainTimer()
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

function HP:Increment(amount: number)
	return PlayerManager.IncrementVital(self._player, "hp", amount)
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return HP
