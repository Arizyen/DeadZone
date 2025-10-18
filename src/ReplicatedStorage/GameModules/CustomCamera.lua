local CustomCamera = {}
CustomCamera.__index = CustomCamera

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
local CAMERA_OFFSET = Vector3.new(2.7, 1.25, 0)
local CAMERA_OFFSET_SPEED = 1 / 4
local FADE_START = 3
local FADE_END = 0.5
local EPS = 0.1
local TWEEN_TIME = 0.3

-- Variables -----------------------------------------------------------------------
local localPlayer = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function GetZoomDistance()
	return (camera.CFrame.Position - camera.Focus.Position).Magnitude
end

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function CustomCamera.new()
	local self = setmetatable({}, CustomCamera)

	-- Booleans
	self._destroyed = false
	self._active = false
	self._inFirstPerson = false
	self._transitioningZoom = false
	self._toolEquipped = localPlayer:GetAttribute("toolEquipped") or false
	self._isRagdolled = localPlayer:GetAttribute("isRagdolled") or false

	-- Numbers
	self._origMinZoomDistance = 0
	self._origMaxZoomDistance = 0
	self._offsetAlpha = 0

	-- Instance
	self._character = localPlayer.Character
	self._humanoid = self._character and self._character:FindFirstChildOfClass("Humanoid")

	self:_Init()

	return self
end

function CustomCamera:_Init()
	-- Connections
	Utils.Connections.Add(
		self,
		"CharacterAdded",
		localPlayer.CharacterAdded:Connect(function(character)
			self._character = character
			self:_Activate()
		end)
	)

	Utils.Connections.Add(
		self,
		"CharacterRemoving",
		localPlayer.CharacterRemoving:Connect(function()
			self._character = nil
			self:_Deactivate()
		end)
	)

	Utils.Connections.Add(
		self,
		"toolEquipped",
		localPlayer:GetAttributeChangedSignal("toolEquipped"):Connect(function()
			self._toolEquipped = localPlayer:GetAttribute("toolEquipped") or false
		end)
	)
	Utils.Connections.Add(
		self,
		"isRagdolled",
		localPlayer:GetAttributeChangedSignal("isRagdolled"):Connect(function()
			self._isRagdolled = localPlayer:GetAttribute("isRagdolled") or false
		end)
	)

	if self._character then
		self:_Activate()
	end
end

function CustomCamera:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	self:_Deactivate()
	Utils.Connections.DisconnectKeyConnections(self)

	self._character = nil
end

function CustomCamera:Update()
	if not self._character or not self._character.PrimaryPart then
		return
	end

	local zoomDistance = GetZoomDistance()

	-- Make character face camera direction
	if not self._inFirstPerson and self._toolEquipped and not self._isRagdolled then
		-- In first-person, the character rotates automatically with the camera
		local root = self._character.PrimaryPart
		-- local _, yaw = camera.CFrame:ToEulerAnglesYXZ()
		local yaw = Utils.Math.YawToTarget(root.CFrame, camera.CFrame * CFrame.new(0, 0, -(zoomDistance + 50)))

		self._character:PivotTo(CFrame.new(root.Position) * CFrame.Angles(0, yaw, 0))
	end

	-- Fade out as we approach first-person
	local fade = 1.0
	if zoomDistance <= FADE_END then
		fade = 0
	elseif zoomDistance < FADE_START then
		fade = (zoomDistance - FADE_END) / math.max(1e-3, (FADE_START - FADE_END))
	end

	-- Update offset as tool is equipped/unequipped
	local targetAlpha = self._toolEquipped and 1 or 0

	if self._offsetAlpha ~= targetAlpha then
		if math.abs(self._offsetAlpha - targetAlpha) < 1e-3 then
			self._offsetAlpha = targetAlpha
		else
			self._offsetAlpha += (targetAlpha - self._offsetAlpha) * CAMERA_OFFSET_SPEED
		end
	end

	self._humanoid.CameraOffset = (CAMERA_OFFSET * self._offsetAlpha) * fade
	self._humanoid.AutoRotate = self._inFirstPerson or self._isRagdolled or not self._toolEquipped

	-- Auto transition first-person / third-person
	if not self._transitioningZoom then
		if not self._inFirstPerson and zoomDistance <= FADE_START - EPS and zoomDistance > FADE_END + EPS then
			self:_StartTransitionZoom(FADE_END, TWEEN_TIME)
			self._inFirstPerson = true
		elseif self._inFirstPerson and zoomDistance > FADE_END + EPS then
			self:_StartTransitionZoom(FADE_START, TWEEN_TIME)
			self._inFirstPerson = false
		end
	end
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function CustomCamera:_Activate()
	if self._active then
		return
	end
	self._active = true

	local humanoid = self._character:WaitForChild("Humanoid")
	self._humanoid = humanoid

	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = humanoid

	RunService:BindToRenderStep("CustomCamera", Enum.RenderPriority.Camera.Value + 1, function()
		self:Update()
	end)
end

function CustomCamera:_Deactivate()
	if not self._active then
		return
	end
	self._active = false

	RunService:UnbindFromRenderStep("CustomCamera")

	if self._humanoid and self._humanoid.Parent then
		self._humanoid.CameraOffset = Vector3.new()
		self._humanoid.AutoRotate = true
	end
end

function CustomCamera:_StartTransitionZoom(distance: number, duration: number)
	if self._transitioningZoom then
		RunService:UnbindFromRenderStep("ThirdPersonCameraTransition")
	end
	self._transitioningZoom = true

	self._origMinZoomDistance = localPlayer.CameraMinZoomDistance
	self._origMaxZoomDistance = localPlayer.CameraMaxZoomDistance

	local zoomFrom = GetZoomDistance()
	local zoomTo = distance
	local startTime = os.clock()

	RunService:BindToRenderStep("ThirdPersonCameraTransition", Enum.RenderPriority.Camera.Value + 2, function()
		if not self._transitioningZoom then
			return
		end

		local elapsed = os.clock() - startTime
		local alpha = math.clamp(elapsed / duration, 0, 1)
		local zoom = zoomFrom + (zoomTo - zoomFrom) * alpha

		if zoomTo < zoomFrom then
			-- Write to min first
			localPlayer.CameraMinZoomDistance = zoom
			localPlayer.CameraMaxZoomDistance = zoom
		else
			-- Write to max first
			localPlayer.CameraMaxZoomDistance = zoom
			localPlayer.CameraMinZoomDistance = zoom
		end

		if alpha >= 1 then
			RunService:UnbindFromRenderStep("ThirdPersonCameraTransition")
			task.delay(0.2, function()
				localPlayer.CameraMinZoomDistance = self._origMinZoomDistance
				localPlayer.CameraMaxZoomDistance = self._origMaxZoomDistance
				self._transitioningZoom = false
			end)
		end
	end)
end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return CustomCamera.new() :: typeof(CustomCamera)
