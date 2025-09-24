local Energy = {}
Energy.__index = Energy

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

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local StateConfigs = require(Configs.StateConfigs)

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Energy.new(player: Player, stateManager)
	local self = setmetatable({}, Energy)

	-- Booleans
	self._destroyed = false

	-- Numbers
	self._energyMax = StateConfigs.ENERGY_MAX

	-- Instances
	self._player = player

	-- Metatables
	self.stateManager = stateManager

	self:_Init()

	return self
end

function Energy:_Init()
	-- Connections
	-- On player energy change
	Utils.Connections.Add(
		self,
		"energyChanged",
		self._player:GetAttributeChangedSignal("energy"):Connect(function()
			local newEnergy = self._player:GetAttribute("energy") :: number
			local currentEnergy = self.stateManager.state.energy

			if newEnergy == currentEnergy then
				return
			end

			self.stateManager.state.energy = math.clamp(newEnergy, 0, self._energyMax)
		end)
	)

	Utils.Connections.Add(
		self,
		"energyMaxChanged",
		self._player:GetAttributeChangedSignal("energyMax"):Connect(function()
			local newMaxEnergy = self._player:GetAttribute("energyMax") :: number

			if newMaxEnergy == self._energyMax then
				return
			end

			self._energyMax = newMaxEnergy
		end)
	)

	self:Update()
end

function Energy:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)
end

function Energy:Update(elapsedTime: number?)
	if self._destroyed then
		return
	end

	if not elapsedTime or elapsedTime <= 0 then
		PlayerManager.SetMaxVital(self._player, "energy", self._energyMax)
		PlayerManager.SetVital(self._player, "energy", self.stateManager.state.energy)
		return
	end

	-- Decay the player's energy over time
	self:Increment(-(StateConfigs.ENERGY_DECAY_RATE * elapsedTime))
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Energy:GetStartingEnergy(): number
	local currentEnergy = self.stateManager.state.energy

	return currentEnergy > 0 and currentEnergy or self._energyMax
end

function Energy:GetMaxEnergy(): number
	return self._energyMax
end

function Energy:Increment(amount: number)
	return PlayerManager.IncrementVital(self._player, "energy", amount)
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Energy
