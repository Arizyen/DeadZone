local Stamina = {}
Stamina.__index = Stamina

-- Services ------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

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
local PlayerHandler = require(GameHandlers.PlayerHandler)

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------
local PerksInfo = require(ReplicatedInfo:WaitForChild("PerksInfo"))

-- Configs -------------------------------------------------------------------------
local MovementConfigs = require(ReplicatedConfigs:WaitForChild("MovementConfigs"))
local CHECK_PER_SECOND = 4
local MAX_SPEEDS_SECONDS_TRACKED = 1
local EPSILON = 3 -- Tolerance over max speed to apply speed strike
local SPEED_STRIKE_KICK = CHECK_PER_SECOND * 5 -- Number of strikes before kick
local STAMINA_STRIKE_KICK = CHECK_PER_SECOND * 5 -- Number of strikes before kick

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
	self._adrenalineMeleePerk = false

	-- Instances
	self._player = player
	self._lastPosition = nil :: Vector3?

	-- Numbers
	self._sprintSpeed = PlayerDataHandler.GetPathValue(player.UserId, { "stats", "sprintSpeed" })
		or MovementConfigs.MAX_WALK_SPEED
	self._maxStamina = PlayerDataHandler.GetPathValue(player.UserId, { "stats", "maxStamina" })
		or MovementConfigs.STAMINA
	self._stamina = self._maxStamina
	self._staminaConsumptionRate = PlayerDataHandler.GetPathValue(player.UserId, { "stats", "staminaConsumptionRate" })
		or MovementConfigs.STAMINA_CONSUMPTION_RATE
	self._staminaStrikes = 0
	self._speedStrikes = 0

	-- Tables
	self._speeds = {} :: { number } -- To get the average speed over time (to save past MAX_SPEEDS_SECONDS_TRACKED seconds of speeds)

	self:_Init()

	return self
end

function Stamina:_Init()
	Utils.Connections.Add(
		self,
		"sprintSpeedChanged",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "stats", "sprintSpeed" }, function(newValue)
			self._sprintSpeed = newValue
		end)
	)

	Utils.Connections.Add(
		self,
		"maxStaminaChanged",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "stats", "maxStamina" }, function(newValue)
			self._maxStamina = newValue
			self._stamina = math.min(self._stamina, self._maxStamina)
		end)
	)

	Utils.Connections.Add(
		self,
		"CharacterAdded",
		self._player.CharacterAdded:Connect(function(character)
			self:_OnCharacterAdded(character)
		end)
	)

	Utils.Connections.Add(
		self,
		"CharacterRemoving",
		self._player.CharacterRemoving:Connect(function()
			Utils.Connections.DisconnectKeyConnection(self, "SpeedCheck")
		end)
	)

	Utils.Connections.Add(
		self,
		"Teleported",
		self._player:GetAttributeChangedSignal("teleported"):Connect(function()
			if not self._player:GetAttribute("teleported") then
				-- Only reset after teleport ends
				self:_Reset()
			end
		end)
	)

	-- Perks connections
	Utils.Connections.Add(
		self,
		"adrenalineMelee",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "perks", "adrenalineMelee" }, function(value)
			self._adrenalineMeleePerk = value
			self:_AdrenalineMeleeConnection()
		end)
	)
	self:_AdrenalineMeleeConnection()

	self:Update()
end

function Stamina:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)
end

function Stamina:Update() end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Stamina:_Reset()
	self._lastPosition = nil
	self._staminaStrikes = 0
	self._speedStrikes = 0
	table.clear(self._speeds)
end

function Stamina:_OnCharacterAdded(character: Model)
	local primaryPart = character:WaitForChild("HumanoidRootPart", 15)
	if not primaryPart then
		return
	end

	self._stamina = self._maxStamina
	self:_Reset()

	local int = 0
	local maxDT = 1 / CHECK_PER_SECOND
	Utils.Connections.Add(
		self,
		"SpeedCheck",
		RunService.Heartbeat:Connect(function(dt)
			int = int + dt
			if int < maxDT or not primaryPart.Parent then
				return
			end
			int = int % maxDT

			-- Calculate horizontal speed
			local position = primaryPart.Position
			if not self._lastPosition then
				self._lastPosition = position
				return
			end

			-- Use simple math to avoid temporary Vector3 allocation
			local dx = position.X - self._lastPosition.X
			local dz = position.Z - self._lastPosition.Z
			local horizontalSpeed = math.sqrt(dx * dx + dz * dz) / maxDT

			self._lastPosition = position

			-- Add to speeds table
			table.insert(self._speeds, horizontalSpeed)
			if #self._speeds > CHECK_PER_SECOND * MAX_SPEEDS_SECONDS_TRACKED then
				table.remove(self._speeds, 1)
			end

			-- Calculate average speed (to smooth out spikes)
			local totalSpeed = 0
			for _, speed in pairs(self._speeds) do
				totalSpeed = totalSpeed + speed
			end
			local averageSpeed = totalSpeed / #self._speeds

			-- Check if sprinting (check horizontalSpeed as well since the averageSpeed can take time to reduce after stopping)
			if horizontalSpeed >= (self._sprintSpeed - EPSILON) and averageSpeed >= (self._sprintSpeed - EPSILON) then
				-- Update stamina
				self._stamina = self._stamina - (maxDT * self._staminaConsumptionRate)

				if self._stamina < 0 then
					self._stamina = 0
					self._staminaStrikes += 1

					if self._staminaStrikes >= STAMINA_STRIKE_KICK then
						-- Kick player for sprinting more than allowed
						warn("Kicking player for sprinting more than allowed")
					end
				end

				-- Detect if player is moving faster than max speed
				if horizontalSpeed > (self._sprintSpeed + EPSILON) and averageSpeed > (self._sprintSpeed + EPSILON) then
					print("Speed is higher than max:", averageSpeed)
					self._speedStrikes += 1

					if self._speedStrikes >= SPEED_STRIKE_KICK then
						-- Kick player for speed hacking
						warn("Kicking player for speed hacking")
					end
				else
					self._speedStrikes = 0
				end
			else
				self._stamina = math.min(self._stamina + (maxDT * self._staminaConsumptionRate), self._maxStamina)
				self._staminaStrikes = 0
			end
		end)
	)
end

function Stamina:_AdrenalineMeleeConnection()
	if not self._adrenalineMeleePerk then
		return
	end

	local adrenalineMeleeInfo = PerksInfo.byKey.adrenalineMelee
	local staminaAdd = adrenalineMeleeInfo.value

	Utils.Connections.Add(
		self,
		"meleeKillsChanged",
		PlayerDataHandler.ObservePlayerPath(
			self._player.UserId,
			{ "statistics", "meleeKills" },
			function(newValue, oldValue)
				if newValue > oldValue then
					self:Add(staminaAdd)
				end
			end
		)
	)
end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Stamina:Add(amount: number)
	self._stamina = math.clamp(self._stamina + amount, 0, self._maxStamina)
	PlayerHandler.AddStamina(self._player, amount)
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Stamina
