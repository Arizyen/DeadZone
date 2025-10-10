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
local CAMERA_OFFSET = Vector3.new(2, 0.2, 0)
local FADE_START = 5
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
	self._isRagdolled = localPlayer:GetAttribute("isRagdolled") or false
	self._transitioning = false

	-- Numbers
	self._origMinZoomDistance = 0
	self._origMaxZoomDistance = 0

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

	-- Make character face camera direction
	if not self._inFirstPerson and not self._isRagdolled then
		-- In first-person, the character rotates automatically with the camera
		local root = self._character.PrimaryPart
		local _, yaw = camera.CFrame:ToEulerAnglesYXZ()

		self._character:PivotTo(CFrame.new(root.Position) * CFrame.Angles(0, yaw, 0))
	end

	-- Fade out as we approach first-person
	local dist = GetZoomDistance()

	local fade = 1.0
	if dist <= FADE_END then
		fade = 0
	elseif dist < FADE_START then
		fade = (dist - FADE_END) / math.max(1e-3, (FADE_START - FADE_END))
	end

	self._humanoid.CameraOffset = CAMERA_OFFSET * fade

	-- Auto transition first-person / third-person
	if not self._transitioning then
		if not self._inFirstPerson and dist <= FADE_START - EPS and dist > FADE_END + EPS then
			self:_StartTransition(FADE_END, TWEEN_TIME)
			self._inFirstPerson = true
		elseif self._inFirstPerson and dist > FADE_END + EPS then
			self:_StartTransition(FADE_START, TWEEN_TIME)
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

	humanoid.CameraOffset = CAMERA_OFFSET
	humanoid.AutoRotate = false

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
end

function CustomCamera:_StartTransition(distance: number, duration: number)
	if self._transitioning then
		RunService:UnbindFromRenderStep("ThirdPersonCameraTransition")
	end
	self._transitioning = true

	self._origMinZoomDistance = localPlayer.CameraMinZoomDistance
	self._origMaxZoomDistance = localPlayer.CameraMaxZoomDistance

	local zoomFrom = GetZoomDistance()
	local zoomTo = distance
	local startTime = os.clock()

	RunService:BindToRenderStep("ThirdPersonCameraTransition", Enum.RenderPriority.Camera.Value + 2, function()
		if not self._transitioning then
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
				self._transitioning = false
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
