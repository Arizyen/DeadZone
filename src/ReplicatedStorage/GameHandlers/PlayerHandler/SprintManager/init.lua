local SprintManager = {}
SprintManager.__index = SprintManager

-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
local Stamina = require(script:WaitForChild("Stamina"))

-- Handlers --------------------------------------------------------------------
local PlayerDataHandler = require(ReplicatedBaseHandlers:WaitForChild("PlayerDataHandler"))

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local MovementConfigs = require(ReplicatedConfigs:WaitForChild("MovementConfigs"))

-- Variables -----------------------------------------------------------------------
local localPlayer = game.Players.LocalPlayer

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function SprintManager.new()
	local self = setmetatable({}, SprintManager)

	-- Booleans
	self._destroyed = false
	self._isDead = false
	self._isSprinting = false
	self._isHoldingSprint = false

	-- Numbers
	self._sprintSpeed = PlayerDataHandler.GetPathValue({ "stats", "sprintSpeed" }) or MovementConfigs.MAX_WALK_SPEED

	-- Instances
	self._stamina = Stamina.new(self)
	self._humanoid = Utils.Player.GetHumanoid(localPlayer)

	self:_Init()

	return self
end

function SprintManager:_Init()
	if not self._humanoid then
		self._isDead = true
	end

	-- Sprint speed change
	Utils.Connections.Add(
		self,
		"sprintSpeedChanged",
		PlayerDataHandler.ObservePath({ "stats", "sprintSpeed" }, function(newValue)
			self._sprintSpeed = newValue
			if self._isSprinting then
				self:_UpdateWalkSpeed(self._sprintSpeed)
			end
		end)
	)

	-- Character connections
	Utils.Connections.Add(
		self,
		"characterAdded",
		localPlayer.CharacterAdded:Connect(function(character)
			local humanoid = character:WaitForChild("Humanoid")
			self._isDead = false
			self._humanoid = humanoid
		end)
	)

	Utils.Connections.Add(
		self,
		"characterRemoving",
		localPlayer.CharacterRemoving:Connect(function()
			self._isDead = true
			self._humanoid = nil
			self:HoldSprint(false)
		end)
	)

	-- Keybind connections (pc/console)
	Utils.Connections.Add(
		self,
		"inputBegan",
		game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonL3 then
				self:HoldSprint(true)
			end
		end)
	)

	Utils.Connections.Add(
		self,
		"inputEnded",
		game:GetService("UserInputService").InputEnded:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonL3 then
				self:HoldSprint(false)
			end
		end)
	)

	self:UpdateUIState()
end

function SprintManager:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function SprintManager:_UpdateWalkSpeed(speed: number)
	if not self._humanoid then
		return
	end

	self._humanoid.WalkSpeed = speed
end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function SprintManager:UpdateUIState()
	Utils.Signals.Fire("DispatchAction", {
		type = "SetStaminaState",
		value = {
			stamina = self._stamina:GetStamina(),
			isHoldingSprint = self._isHoldingSprint,
		},
	})
end

function SprintManager:Sprint(state: boolean): boolean
	self._isSprinting = state

	if state then
		if self._stamina:StartConsuming() then
			Utils.Camera.TweenFOV(80)
			self:_UpdateWalkSpeed(self._sprintSpeed)
			return true
		end
	else
		Utils.Camera.TweenFOV(70)
		self._stamina:StopConsuming()
		self:_UpdateWalkSpeed(MovementConfigs.WALK_SPEED)
	end

	return true
end

function SprintManager:HoldSprint(state: boolean)
	if self._isHoldingSprint == state or self._isDead and state then
		return
	end
	self._isHoldingSprint = state

	if state then
		self:Sprint(true)
		Utils.Connections.Add(
			self,
			"holdSprintHeartbeat",
			game:GetService("RunService").Heartbeat:Connect(function()
				if self._stamina:GetStamina() > 10 then
					self:Sprint(true)
				end
			end)
		)
	else
		Utils.Connections.DisconnectKeyConnection(self, "holdSprintHeartbeat")
		self:Sprint(false)
	end

	self:UpdateUIState()
end

function SprintManager:AddStamina(amount: number)
	self._stamina:AddStamina(amount)
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return SprintManager
