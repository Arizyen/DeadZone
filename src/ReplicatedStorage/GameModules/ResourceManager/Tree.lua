local Tree = {}
Tree.__index = Tree

-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

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

local ResourcesDebris = game.Workspace:WaitForChild("Debris"):WaitForChild("Resources")

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))
local Resources = require(script.Parent:WaitForChild("Resources"))

-- Handlers --------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local FALL_ANIMATION_DURATION = 2

-- Variables -----------------------------------------------------------------------
local rng = Random.new()

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Tree.new(treeInstance: Instance)
	local self = setmetatable({}, Tree)

	-- Booleans
	self._destroyed = false
	self._activated = false
	self._animatingDestroy = false

	-- Instances
	self._instance = treeInstance

	-- Strings
	self._id = treeInstance.Name
	self._type = "tree"

	-- Numbers
	self._hp = treeInstance:GetAttribute("hp")

	self:_Init()

	return self
end

function Tree:_Init()
	if type(self._hp) ~= "number" or self._hp <= 0 then
		self:Destroy()
		return
	end

	-- Connections
	Utils.Connections.Add(
		self,
		"AncestryChanged",
		self._instance.AncestryChanged:Connect(function(_, parent)
			if not parent then
				self:Destroy()
			elseif parent == ResourcesDebris then
				self:_AnimateDestroy()
			end
		end)
	)

	Resources.trees[self._id] = self

	self:Activate()
end

function Tree:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true
	Resources.trees[self._id] = nil

	Utils.Connections.DisconnectKeyConnections(self)
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Tree:_AnimateDestroy()
	if self._destroyed then
		if self._instance and self._instance.Parent then
			self._instance:Destroy()
		end
		return
	elseif self._animatingDestroy then
		return
	end
	self._animatingDestroy = true

	-- Make sure the tree is activated to prevent deactivation during animation
	self:Activate()

	-- Animate destroy the tree falling over
	-- Raycast from top of tree down to random direction to find hit position around the base
	local treePrimaryPart = self._instance.PrimaryPart
	local treeTopPrimaryPart = self._instance.Top.PrimaryPart
	local startCFrame = self._instance.Top:GetPivot()

	local topPosition = startCFrame.Position + Vector3.new(0, treeTopPrimaryPart.Size.Y, 0)
	local randomAngleRad = math.rad(rng:NextNumber(0, 360))
	local direction = Vector3.new(math.cos(randomAngleRad), 0, math.sin(randomAngleRad))
	local positionAroundBase = treePrimaryPart.Position + direction * (treeTopPrimaryPart.Size.Y * 4)

	local raycastResult = Utils.Raycaster.Raycast(
		topPosition,
		positionAroundBase,
		{ game.Workspace.Terrain },
		nil,
		Enum.RaycastFilterType.Include
	)
	local hitPosition = raycastResult and raycastResult.Position or positionAroundBase

	-- Get fall CFrame by getting angle to tilt the tree over to hitPosition
	local rawDir = hitPosition - startCFrame.Position
	local dirXZ = Vector3.new(rawDir.X, 0, rawDir.Z)

	-- Fallback if target is exactly above the base (no horizontal component)
	if dirXZ.Magnitude < 1e-6 then
		-- Use current forward projected to XZ
		local forward = startCFrame.LookVector
		dirXZ = Vector3.new(forward.X, 0, forward.Z)
		if dirXZ.Magnitude < 1e-6 then
			-- Absolute fallback
			dirXZ = Vector3.new(0, 0, -1)
		end
	end

	dirXZ = dirXZ.Unit

	-- Calculate the axis of rotation (perpendicular to both up and the direction to target)
	local rotationAxis = Vector3.yAxis:Cross(dirXZ).Unit

	-- Compute the maximum allowed fall angle so the top doesn't go below target height
	local H = treeTopPrimaryPart.Size.Y
	local h = hitPosition.Y - startCFrame.Position.Y
	local clamped = math.clamp(h / H, -0.5, 1)
	local fallAngle = math.acos(clamped) -- Angle in radians

	-- Apply tilt around the rotation axis while preserving the tree's original orientation
	local finalCFrame = startCFrame * CFrame.fromAxisAngle(rotationAxis, fallAngle)

	-- Animate tree falling over
	local animationStartTime = os.clock()
	local alpha = 0
	Utils.Connections.Add(
		self,
		"HeartbeatDestroyAnimation",
		RunService.Heartbeat:Connect(function()
			if not self._instance or not self._instance.Parent then
				-- Tree instance destroyed during animation
				Utils.Connections.DisconnectKeyConnection(self, "HeartbeatDestroyAnimation")
				self:Destroy()
				return
			end

			local elapsedTime = os.clock() - animationStartTime
			alpha = math.clamp(elapsedTime / FALL_ANIMATION_DURATION, 0, 1)

			local newCFrame = startCFrame:Lerp(
				finalCFrame,
				TweenService:GetValue(alpha, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			)
			self._instance.Top:PivotTo(newCFrame)

			if alpha >= 1 then
				-- Animation complete
				Utils.Connections.DisconnectKeyConnection(self, "HeartbeatDestroyAnimation")

				-- Tween transparency of tree parts to 1 over 0.5 seconds
				local descendants = self._instance:GetDescendants()
				local baseParts = Utils.Table.Array.filter(descendants, function(descendant)
					return descendant:IsA("BasePart")
				end)

				for idx, basePart in ipairs(baseParts) do
					if idx == #baseParts then
						-- Last part, destroy after tween
						Utils.Tween(
							basePart,
							0.5,
							Enum.EasingStyle.Linear,
							Enum.EasingDirection.Out,
							{ Transparency = 1 }
						).Completed
							:Connect(function(state)
								if state == Enum.PlaybackState.Completed then
									if self._instance and self._instance.Parent then
										self._instance:Destroy()
									end
									self:Destroy()
								end
							end)
					else
						-- Just tween transparency
						Utils.Tween(
							basePart,
							0.5,
							Enum.EasingStyle.Linear,
							Enum.EasingDirection.Out,
							{ Transparency = 1 }
						)
					end
				end
			end
		end)
	)
end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Tree:Activate()
	if self._activated or self._destroyed then
		return
	end
	self._activated = true

	Utils.Connections.DisconnectKeyConnection(self, "DeactivationSchedule")
end

-- Schedules deactivation after a delay
function Tree:Deactivate()
	if Utils.Connections.GetKeyConnection(self, "DeactivationSchedule") or self._destroyed then
		return
	end
	self._activated = false

	Utils.Connections.Add(
		self,
		"DeactivationSchedule",
		Utils.Scheduler.Add(5, function()
			self:Destroy()
		end)
	)
end

-- GETTERS ----------------------------------------------------------------------------------------------------

function Tree:GetId(): string
	return self._id
end

function Tree:GetType(): string
	return self._type
end

function Tree:GetInstance(): Instance?
	return not self._destroyed and self._hp > 0 and self._instance
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Tree
