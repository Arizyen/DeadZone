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
						hpManager:Regain(StateConfigs.HP_REGAIN_RATE)
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
	self._maxHP = StateConfigs.MAX_HP
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
		"HPChanged",
		PlayerDataHandler.ObservePlayerPath(
			self._player.UserId,
			{ "vitals", "hp" },
			function(newHP: number, oldHP: number)
				if newHP == oldHP then
					return
				end

				if newHP < oldHP then
					self._lastDamageReceivedTime = os.clock()
					self:_StartHPRegain()
				end
			end
		)
	)

	-- On player maxHP change
	Utils.Connections.Add(
		self,
		"MaxHPChanged",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "vitals", "maxHP" }, function(newMaxHP, oldMaxHP)
			if newMaxHP == oldMaxHP then
				return
			end

			if newMaxHP > oldMaxHP then
				self:_StartHPRegain()
			end
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

	elapsedTime = elapsedTime or 0

	-- If the player's energy is at 0, decay HP
	if self.stateManager.state.energy <= 0 then
		local currentHP = self.stateManager.state.hp
		if currentHP > 0 then
			self:Remove(StateConfigs.HP_DECAY_RATE * elapsedTime)
		end
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

-- Returns false if the player has reached max HP
-- Returns true if the player can still regain more HP
function HP:Regain(amount: number): boolean
	local currentHP = self.stateManager.state.hp
	local maxHP = self._maxHP

	if currentHP >= maxHP then
		hpManagersRegainBag[self._player.UserId] = nil
		return false
	end

	self._player:SetAttribute("AddHP", amount)

	if currentHP + amount >= maxHP then
		hpManagersRegainBag[self._player.UserId] = nil
		return false
	end

	return true
end

-- Returns false if the player has reached 0 HP (is dead)
-- Returns true if the player is still alive
function HP:Remove(amount: number): boolean
	local currentHP = self.stateManager.state.hp

	if currentHP <= 0 then
		return false
	end

	self._player:SetAttribute("RemoveHP", amount)

	if currentHP - amount <= 0 then
		return false
	end

	return true
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return HP
