local PlayerAxesAnimator = {}
PlayerAxesAnimator.__index = PlayerAxesAnimator

-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

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
local Ports = require(script.Parent.Parent:WaitForChild("Ports"))

-- Handlers --------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local MAX_YAW = math.rad(75) -- left/right
local REPLICATION_RATE = 10 -- Times per second
local WAIST_PITCH_RAD_FACTOR = 0.6
local NECK_PITCH_RAD_FACTOR = 0.4
local WAIST_YAW_RAD_FACTOR = 0.4
local NECK_YAW_RAD_FACTOR = 0.6

-- Variables -----------------------------------------------------------------------
local localPlayer = game.Players.LocalPlayer

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local Lerp = Utils.Math.Lerp
local Smoothstep = Utils.Math.Smoothstep
local Round = Utils.Math.Round

local function AngleDiff(a, b)
	-- returns (b - a) wrapped to [-π, π]
	local d = (b - a + math.pi) % (2 * math.pi) - math.pi
	return d
end

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function PlayerAxesAnimator.new(player: Player)
	local self = setmetatable({}, PlayerAxesAnimator)

	-- Booleans
	self._destroyed = false
	self._activated = false
	self._isLocalPlayer = player == localPlayer
	self._inRange = self._isLocalPlayer and true or false
	self._toolEquipped = player:GetAttribute("equippedObjectId") ~= nil
	self._isRagdolled = player:GetAttribute("isRagdolled") or false
	self._shiftLockDisabled = localPlayer:GetAttribute("shiftLockDisabled") or false

	-- Strings
	self._deviceType = localPlayer:GetAttribute("deviceType") or "pc"

	-- Instances
	self._player = player
	self._character = player.Character
	self._upperTorso = nil
	self._waistMotor6D = nil
	self._neckMotor6D = nil

	-- CFrame
	self._waistC0Base = nil
	self._neckC0Base = nil

	-- Numbers
	self._previousPitchRad = 0
	self._previousYawRad = 0
	self._targetPitchRad = 0
	self._targetYawRad = 0
	self._pitchRad = 0
	self._yawRad = 0
	self._lastReplicationTime = 0
	self._lastUpdateTime = 0

	self:_Init()

	return self
end

function PlayerAxesAnimator:_Init()
	-- Connections
	Utils.Connections.Add(
		self,
		"CharacterAdded",
		self._player.CharacterAdded:Connect(function(character)
			self._character = character
			self:_Activate()
		end)
	)

	Utils.Connections.Add(
		self,
		"CharacterRemoving",
		self._player.CharacterRemoving:Connect(function()
			self._character = nil
			self:_Deactivate()
		end)
	)

	Utils.Connections.Add(
		self,
		"equippedObjectId",
		self._player:GetAttributeChangedSignal("equippedObjectId"):Connect(function()
			self._toolEquipped = self._player:GetAttribute("equippedObjectId") ~= nil
		end)
	)

	Utils.Connections.Add(
		self,
		"isRagdolled",
		self._player:GetAttributeChangedSignal("isRagdolled"):Connect(function()
			self._isRagdolled = self._player:GetAttribute("isRagdolled") or false
			if self._isRagdolled then
				self:_Deactivate()
			else
				self:_Activate()
			end
		end)
	)

	Utils.Connections.Add(
		self,
		"isInRange",
		self._player:GetAttributeChangedSignal("isInRange"):Connect(function()
			self:SetInRange(self._player:GetAttribute("isInRange") or false)
		end)
	)

	Utils.Connections.Add(
		self,
		"shiftLockDisabled",
		localPlayer:GetAttributeChangedSignal("shiftLockDisabled"):Connect(function()
			self._shiftLockDisabled = localPlayer:GetAttribute("shiftLockDisabled") or false
		end)
	)
	Utils.Connections.Add(
		self,
		"DeviceTypeUpdated",
		localPlayer:GetAttributeChangedSignal("deviceType"):Connect(function()
			self._deviceType = localPlayer:GetAttribute("deviceType") or "pc"
		end)
	)

	if self._isLocalPlayer then
		self:_Activate()
	else
		self:SetInRange(self._player:GetAttribute("isInRange") or false)
	end
end

function PlayerAxesAnimator:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	self:_Deactivate()

	Utils.Connections.DisconnectKeyConnections(self)
end

function PlayerAxesAnimator:Update(pitchRad: number, yawRad: number)
	if not self._activated or not self._character or self._isRagdolled then
		return
	end

	if self._isLocalPlayer then
		-- Fire server to replicate to other players
		if
			math.abs(pitchRad - self._previousPitchRad) > math.rad(1)
			or math.abs(yawRad - self._previousYawRad) > math.rad(1)
		then
			if os.clock() - self._lastReplicationTime >= 1 / REPLICATION_RATE then
				Ports.ReplicateAxes(Round(pitchRad, 3), Round(yawRad, 3))
				self._lastReplicationTime = os.clock()
			end
		end

		self._previousPitchRad = pitchRad
		self._previousYawRad = yawRad
	end

	local waistPitchRad = pitchRad * WAIST_PITCH_RAD_FACTOR
	local neckPitchRad = pitchRad * NECK_PITCH_RAD_FACTOR
	local waistYawRad = self._toolEquipped and 0 or yawRad * WAIST_YAW_RAD_FACTOR
	local neckYawRad = self._toolEquipped and 0 or yawRad * NECK_YAW_RAD_FACTOR

	if self._isLocalPlayer then
		self._waistMotor6D.C0 = self._waistC0Base * CFrame.Angles(waistPitchRad, waistYawRad, 0)
		self._neckMotor6D.C0 = self._neckC0Base * CFrame.Angles(neckPitchRad, neckYawRad, 0)
	else
		self._targetPitchRad = pitchRad
		self._targetYawRad = yawRad

		self._lastUpdateTime = os.clock()

		self:_Animate()
	end
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function PlayerAxesAnimator:_Activate()
	if self._destroyed or self._activated or not self._inRange or not self._character or self._isRagdolled then
		return
	end
	self._activated = true

	-- Get parts
	local upperTorso = self._character:WaitForChild("UpperTorso", 10)
	local head = self._character:WaitForChild("Head", 10)

	if not upperTorso or not head then
		self:_Deactivate()
		return
	end

	self._upperTorso = upperTorso :: BasePart

	-- Get Motor6Ds
	self._waistMotor6D = upperTorso:WaitForChild("Waist", 5) :: Motor6D
	self._neckMotor6D = head:WaitForChild("Neck", 5) :: Motor6D
	if not self._waistMotor6D or not self._neckMotor6D then
		self:_Deactivate()
		return
	end

	-- Get base C0
	self._waistC0Base = self._waistC0Base or self._waistMotor6D.C0
	self._neckC0Base = self._neckC0Base or self._neckMotor6D.C0

	if self._isLocalPlayer then
		self:_LocalAnimate()
	end
end

function PlayerAxesAnimator:_Deactivate()
	if not self._activated then
		return
	end
	self._activated = false

	if self._isLocalPlayer then
		RunService:UnbindFromRenderStep("ApplyAimAxes")
	else
		Utils.Connections.DisconnectKeyConnection(self, "Animate")
	end

	-- Reset C0
	if self._character and not self._isRagdolled then
		if self._waistMotor6D and self._waistC0Base then
			self._waistMotor6D.C0 = self._waistC0Base
		end

		if self._neckMotor6D and self._neckC0Base then
			self._neckMotor6D.C0 = self._neckC0Base
		end
	end

	-- Reset variables
	self._pitchRad = 0
	self._yawRad = 0

	self._upperTorso = nil
	self._waistMotor6D = nil
	self._neckMotor6D = nil
	self._waistC0Base = nil
	self._neckC0Base = nil
end

function PlayerAxesAnimator:_LocalAnimate()
	local camera = game.Workspace.CurrentCamera

	RunService:BindToRenderStep("ApplyAimAxes", Enum.RenderPriority.Last.Value, function()
		if self._activated then
			local lookVector = camera.CFrame.LookVector

			if self._toolEquipped and self._shiftLockDisabled and self._deviceType == "pc" then
				-- Get lookVector from mouse position hit
				local mouseLocation = UserInputService:GetMouseLocation()
				local unitRay = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
				lookVector = unitRay.Direction.Unit
			end

			local charLook = self._character.PrimaryPart.CFrame.LookVector
			charLook = Vector3.new(charLook.X, 0, charLook.Z).Unit
			local camFace = Vector3.new(lookVector.X, 0, lookVector.Z).Unit

			if charLook.Magnitude < 1e-6 or camFace.Magnitude < 1e-6 then
				return
			end

			local facingDot = charLook:Dot(camFace)
			local t = Smoothstep((1 - facingDot) * 0.5)

			local localLook = self._character.PrimaryPart.CFrame:VectorToObjectSpace(lookVector).Unit
			local zBlended = Lerp(-localLook.Z, localLook.Z, t)

			local yawTarget = -math.atan2(localLook.X, zBlended)
			yawTarget = math.clamp(yawTarget, -MAX_YAW, MAX_YAW)

			local pitch = math.asin(lookVector.Y)

			self:Update(pitch, yawTarget)
		end
	end)
end

function PlayerAxesAnimator:_Animate()
	if not self._activated or Utils.Connections.GetKeyConnection(self, "Animate") then
		return
	end

	Utils.Connections.Add(
		self,
		"Animate",
		RunService.Heartbeat:Connect(function()
			local alpha = math.clamp((os.clock() - self._lastUpdateTime) / (1 / REPLICATION_RATE), 0, 1)
			if alpha >= 1 then
				Utils.Connections.DisconnectKeyConnection(self, "Animate")
			end

			self._pitchRad = self._pitchRad + AngleDiff(self._pitchRad, self._targetPitchRad) * alpha
			self._yawRad = self._yawRad + AngleDiff(self._yawRad, self._targetYawRad) * alpha

			local waistPitchRad = self._pitchRad * WAIST_PITCH_RAD_FACTOR
			local neckPitchRad = self._pitchRad * NECK_PITCH_RAD_FACTOR
			local waistYawRad = self._toolEquipped and 0 or self._yawRad * WAIST_YAW_RAD_FACTOR
			local neckYawRad = self._toolEquipped and 0 or self._yawRad * NECK_YAW_RAD_FACTOR

			self._waistMotor6D.C0 = self._waistC0Base * CFrame.Angles(waistPitchRad, waistYawRad, 0)
			self._neckMotor6D.C0 = self._neckC0Base * CFrame.Angles(neckPitchRad, neckYawRad, 0)
		end)
	)
end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function PlayerAxesAnimator:SetInRange(inRange: boolean)
	if self._inRange == inRange then
		return
	end
	self._inRange = inRange

	if inRange then
		self:_Activate()
	else
		self:_Deactivate()
	end
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return PlayerAxesAnimator
