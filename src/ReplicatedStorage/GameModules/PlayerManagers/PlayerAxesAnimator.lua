local PlayerAxesAnimator = {}
PlayerAxesAnimator.__index = PlayerAxesAnimator

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

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local MAX_YAW = math.rad(75) -- left/right

-- Variables -----------------------------------------------------------------------
local localPlayer = game.Players.LocalPlayer

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local Lerp = Utils.Math.Lerp
local Smoothstep = Utils.Math.Smoothstep

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function PlayerAxesAnimator.new(player: Player)
	local self = setmetatable({}, PlayerAxesAnimator)

	-- Booleans
	self._destroyed = false
	self._activated = false
	self._toolEquipped = player:GetAttribute("toolEquipped") or false
	self._inRange = player == localPlayer

	-- Instances
	self._player = player
	self._character = player.Character
	self._upperTorso = nil
	self._waistMotor6D = nil
	self._neckMotor6D = nil

	-- CFrame
	self._waistC0Base = nil
	self._neckC0Base = nil

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
		"ToolEquippedChanged",
		self._player:GetAttributeChangedSignal("toolEquipped"):Connect(function()
			self._toolEquipped = self._player:GetAttribute("toolEquipped") or false
		end)
	)

	if self._player == localPlayer then
		self:_Activate()
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
	if not self._activated or not self._character then
		return
	end

	self._waistMotor6D.C0 = self._waistC0Base
		* CFrame.Angles(pitchRad * 0.7, self._toolEquipped and 0 or yawRad * 0.4, 0)
	self._neckMotor6D.C0 = self._neckC0Base * CFrame.Angles(pitchRad * 0.3, self._toolEquipped and 0 or yawRad * 0.6, 0)
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function PlayerAxesAnimator:_Activate()
	if self._destroyed or self._activated or not self._inRange or not self._character then
		return
	end
	self._activated = true
	print("Activating pitch animator for", self._player.Name)

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

	self._waistC0Base = self._waistMotor6D.C0
	self._neckC0Base = self._neckMotor6D.C0

	if self._player == localPlayer then
		self:_LocalAnimate()
	end
end

function PlayerAxesAnimator:_Deactivate()
	if not self._activated then
		return
	end
	self._activated = false

	Utils.Connections.DisconnectKeyConnection(self, "RenderStepped")
	RunService:UnbindFromRenderStep("ApplyAimPitch")

	self._upperTorso = nil
	self._waistMotor6D = nil
	self._neckMotor6D = nil
	self._waistC0Base = nil
	self._neckC0Base = nil
end

function PlayerAxesAnimator:_LocalAnimate()
	local camera = game.Workspace.CurrentCamera

	RunService:BindToRenderStep("ApplyAimPitch", Enum.RenderPriority.Last.Value, function()
		if self._activated then
			local camLookVector = camera.CFrame.LookVector

			local charFace = self._upperTorso.CFrame.LookVector
			charFace = Vector3.new(charFace.X, 0, charFace.Z).Unit
			local camFace = Vector3.new(camLookVector.X, 0, camLookVector.Z).Unit

			if charFace.Magnitude < 1e-6 or camFace.Magnitude < 1e-6 then
				return
			end

			local facingDot = charFace:Dot(camFace)
			local t = Smoothstep((1 - facingDot) * 0.5)

			local localLook = self._upperTorso.CFrame:VectorToObjectSpace(camLookVector).Unit
			local zBlended = Lerp(-localLook.Z, localLook.Z, t)

			local yawTarget = -math.atan2(localLook.X, zBlended)
			yawTarget = math.clamp(yawTarget, -MAX_YAW, MAX_YAW)

			local pitch = math.asin(camLookVector.Y)

			self:Update(pitch, yawTarget)
		end
	end)
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
