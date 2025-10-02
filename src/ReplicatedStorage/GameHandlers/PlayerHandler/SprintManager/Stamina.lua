local Stamina = {}
Stamina.__index = Stamina

-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local ReplicatedSource = ReplicatedStorage:WaitForChild("Source")
local ReplicatedPlaywooEngine = ReplicatedSource:WaitForChild("PlaywooEngine")
local ReplicatedBaseModules = ReplicatedPlaywooEngine:WaitForChild("BaseModules")
local ReplicatedGameModules = ReplicatedSource:WaitForChild("GameModules")
local ReplicatedConfigs = ReplicatedSource:WaitForChild("Configs")
local ReplicatedInfo = ReplicatedSource:WaitForChild("Info")
local ReplicatedTypes = ReplicatedSource:WaitForChild("Types")
local ReplicatedBaseHandlers = ReplicatedPlaywooEngine:WaitForChild("BaseHandlers")
local ReplicatedGameHandlers = ReplicatedSource:WaitForChild("GameHandlers")

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))

-- Handlers --------------------------------------------------------------------
local PlayerDataHandler = require(ReplicatedBaseHandlers:WaitForChild("PlayerDataHandler"))

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local MovementConfigs = require(ReplicatedConfigs:WaitForChild("MovementConfigs"))

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Stamina.new(sprintManager: table)
	local self = setmetatable({}, Stamina)

	-- Booleans
	self._destroyed = false
	self._isConsuming = false

	-- Numbers
	self._maxStamina = PlayerDataHandler.GetPathValue({ "stats", "maxStamina" }) or MovementConfigs.STAMINA
	self._staminaConsumptionRate = PlayerDataHandler.GetPathValue({ "stats", "staminaConsumptionRate" })
		or MovementConfigs.STAMINA_CONSUMPTION_RATE
	self._stamina = self._maxStamina

	-- Instances
	self._sprintManager = sprintManager

	self:_Init()

	return self
end

function Stamina:_Init()
	-- Connections
	Utils.Connections.Add(
		self,
		"maxStaminaChanged",
		PlayerDataHandler.ObservePath({ "stats", "maxStamina" }, function(newMaxStamina)
			self._maxStamina = newMaxStamina or MovementConfigs.STAMINA
			-- self._stamina = math.clamp(self._stamina, 0, self._maxStamina)
			self._stamina = self._maxStamina

			self._sprintManager:UpdateUIState()
			-- self:_Regen()
		end)
	)

	Utils.Connections.Add(
		self,
		"staminaConsumptionRateChanged",
		PlayerDataHandler.ObservePath({ "stats", "staminaConsumptionRate" }, function(newRate)
			self._staminaConsumptionRate = newRate or MovementConfigs.STAMINA_CONSUMPTION_RATE
		end)
	)
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

-- Auto-regenerate stamina when not consuming
function Stamina:_Regen()
	if self._isConsuming or self._stamina >= self._maxStamina then
		return
	end

	Utils.Connections.Add(
		self,
		"staminaRegenHeartbeat",
		RunService.Heartbeat:Connect(function(deltaTime)
			if self._isConsuming then
				return
			end

			self._stamina =
				math.clamp(self._stamina + (MovementConfigs.STAMINA_REGENERATION_RATE * deltaTime), 0, self._maxStamina)

			if self._stamina >= self._maxStamina then
				Utils.Connections.DisconnectKeyConnection(self, "staminaRegenHeartbeat")
			end
		end)
	)
end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Stamina:GetStamina(): number
	return self._stamina
end

function Stamina:StartConsuming(): boolean
	if self._stamina <= 0 or self._isConsuming then
		return false
	end
	self._isConsuming = true

	self._sprintManager:UpdateUIState()

	Utils.Connections.Add(
		self,
		"staminaConsumeHeartbeat",
		RunService.Heartbeat:Connect(function(deltaTime)
			if not self._isConsuming then
				return
			end

			self._stamina = math.clamp(self._stamina - (self._staminaConsumptionRate * deltaTime), 0, self._maxStamina)

			if self._stamina <= 0 then
				self._sprintManager:Sprint(false)
				self:StopConsuming()
			end
		end)
	)

	return true
end

function Stamina:StopConsuming()
	if not self._isConsuming then
		return
	end
	self._isConsuming = false

	Utils.Connections.DisconnectKeyConnection(self, "staminaConsumeHeartbeat")

	self:_Regen()
end

function Stamina:Add(amount: number)
	self._stamina = math.clamp(self._stamina + amount, 0, self._maxStamina)
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Stamina
