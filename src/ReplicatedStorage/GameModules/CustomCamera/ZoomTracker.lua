local ZoomTracker = {}
ZoomTracker.__index = ZoomTracker

-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

-- Modules -------------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))

-- Handlers ------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ----------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local DEFAULT_GAMEPAD_ZOOMS = { 0, 10, 20 }

-- Variables -----------------------------------------------------------------------
local localPlayer = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera

-- Tables --------------------------------------------------------------------------
local instance

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ZoomTracker.new()
	if instance then
		return instance
	end

	local self = setmetatable({}, ZoomTracker)
	instance = self

	-- Booleans
	self._destroyed = false
	self._zoomedIn = false

	-- Numbers
	self._minZoom = localPlayer.CameraMinZoomDistance
	self._maxZoom = localPlayer.CameraMaxZoomDistance
	self._desiredZoom = self:GetCurrentZoom()

	self:_Init()

	return self
end

function ZoomTracker:_Init()
	-- Input connections
	self:_AddPCConnections()
	self:_AddMobileConnections()
	self:_AddGamepadConnections()
end

function ZoomTracker:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ZoomTracker:_UpdateZoom(newZoom: number)
	self._zoomedIn = newZoom < self._desiredZoom
	self._desiredZoom = math.clamp(newZoom, self._minZoom, self._maxZoom)
end

function ZoomTracker:_AddPCConnections()
	Utils.Connections.Add(
		self,
		"PCMouseWheel",
		UserInputService.InputChanged:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseWheel then
				local delta = input.Position.Z
				local zoomChange = -delta * 2

				self:_UpdateZoom(self:GetCurrentZoom() + zoomChange)
			end
		end)
	)
end

function ZoomTracker:_AddMobileConnections()
	local pinchTouch1: InputObject? = nil
	local pinchTouch2: InputObject? = nil
	local lastDist: number? = nil

	local PIXEL_DEADZONE = 5
	local SCALE = 0.03

	local function resetPinch()
		pinchTouch1 = nil
		pinchTouch2 = nil
		lastDist = nil
	end

	local function updatePinch()
		if not (pinchTouch1 and pinchTouch2 and lastDist) then
			return
		end

		local p1 = pinchTouch1.Position
		local p2 = pinchTouch2.Position
		local dist = (p1 - p2).Magnitude
		local delta = dist - lastDist

		if math.abs(delta) > PIXEL_DEADZONE then
			-- Fingers moving apart (delta > 0) -> zoom IN -> reduce distance
			-- Fingers moving together (delta < 0) -> zoom OUT -> increase distance
			local zoomChange = -delta * SCALE
			self:_UpdateZoom(self:GetCurrentZoom() + zoomChange)

			lastDist = dist
		end
	end

	Utils.Connections.Add(
		self,
		"TouchStarted",
		UserInputService.TouchStarted:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if not pinchTouch1 then
				pinchTouch1 = input
			elseif not pinchTouch2 then
				pinchTouch2 = input
				lastDist = (pinchTouch1.Position - pinchTouch2.Position).Magnitude
			end
		end)
	)

	Utils.Connections.Add(
		self,
		"TouchMoved",
		UserInputService.TouchMoved:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if input == pinchTouch1 or input == pinchTouch2 then
				updatePinch()
			end
		end)
	)

	Utils.Connections.Add(
		self,
		"TouchEnded",
		UserInputService.TouchEnded:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if input == pinchTouch1 or input == pinchTouch2 then
				resetPinch()
			end
		end)
	)
end

function ZoomTracker:_AddGamepadConnections()
	Utils.Connections.Add(
		self,
		"GamepadR3",
		UserInputService.InputChanged:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonR3 then
				local currentZoom = self:GetCurrentZoom()
				local closestZoomLevel = 3 -- Start with the farthest zoom
				local closestDifference = math.abs(currentZoom - DEFAULT_GAMEPAD_ZOOMS[closestZoomLevel])

				-- Get closest zoom level
				for i = #DEFAULT_GAMEPAD_ZOOMS, 1, -1 do
					local zoom = DEFAULT_GAMEPAD_ZOOMS[i]
					local difference = math.abs(currentZoom - zoom)
					if difference <= closestDifference then
						closestZoomLevel = i
						closestDifference = difference
					end
				end

				-- Get next zoom
				local nextZoomLevel = closestZoomLevel - 1 < 1 and #DEFAULT_GAMEPAD_ZOOMS or closestZoomLevel - 1
				self:_UpdateZoom(DEFAULT_GAMEPAD_ZOOMS[nextZoomLevel])
			end
		end)
	)
end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ZoomTracker:GetCurrentZoom(): number
	return (camera.CFrame.Position - camera.Focus.Position).Magnitude
end

function ZoomTracker:GetDesiredZoom(): (number, boolean)
	return self._desiredZoom, self._zoomedIn
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return ZoomTracker
