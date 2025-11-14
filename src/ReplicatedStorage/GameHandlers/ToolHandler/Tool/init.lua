local Tool = {}
Tool.__index = Tool

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
local Ports = require(script.Parent:WaitForChild("Ports"))
local DeviceTypeUpdater = require(ReplicatedBaseModules:WaitForChild("DeviceTypeUpdater"))
local AnimationManager = require(ReplicatedBaseModules:WaitForChild("AnimationManager"))
local ResourceManager = require(ReplicatedGameModules:WaitForChild("ResourceManager"))
local CustomCamera = require(ReplicatedGameModules:WaitForChild("CustomCamera"))

-- Handlers --------------------------------------------------------------------
local PlayerHandler = require(ReplicatedGameHandlers:WaitForChild("PlayerHandler"))

-- Types ---------------------------------------------------------------------------
local ObjectTypes = require(ReplicatedTypes:WaitForChild("ObjectTypes"))

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------
local localPlayer = game.Players.LocalPlayer
local localAxesAnimator = PlayerHandler.GetPlayerAxesAnimator(localPlayer.UserId)

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local MouseRaycast = Utils.Raycaster.MouseRaycast
local GetMouseRay = Utils.Raycaster.GetMouseRay
local IsWithinDistance = Utils.Math.IsWithinDistance

-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Tool.new(object: ObjectTypes.ToolCopy, objectInfo: ObjectTypes.Tool, humanoid: Humanoid)
	local self = setmetatable({}, Tool)

	-- Booleans
	self._destroyed = false

	-- Instances
	self._object = object
	self._objectInfo = objectInfo
	self._humanoid = humanoid
	self._character = humanoid.Parent

	-- Numbers
	self._lastHitTime = 0

	-- Signals
	self.destroying = Utils.Signals.Create()
	self.activated = Utils.Signals.Create()
	self.deactivated = Utils.Signals.Create()

	-- Metatables
	self.animationManager = AnimationManager.new(humanoid)

	self:_Init()

	return self
end

function Tool:_Init()
	-- Load animations
	self.animationManager:LoadAnimations(self._objectInfo.animations or {})

	-- Connections
	Utils.Connections.Add(
		self,
		"UnequipOnDied",
		self._humanoid.Died:Connect(function()
			self:Destroy()
		end)
	)
	Utils.Connections.Add(
		self,
		"CharacterAncestryChanged",
		self._character.AncestryChanged:Connect(function(_, parent)
			if not parent then
				self:Destroy()
			end
		end)
	)

	-- Equip tool
	self:_Equip()
end

function Tool:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	self.destroying:Fire()
	Utils.Connections.DisconnectKeyConnections(self)

	self:_StopFocusOnModel()

	if self._humanoid then
		self._humanoid:UnequipTools()
	end

	localPlayer:SetAttribute("equippedObjectId", nil)
	localPlayer:SetAttribute("equippedObjectKey", nil)

	-- Destroy signals
	self.destroying:Destroy()
	self.activated:Destroy()
	self.deactivated:Destroy()

	-- Destroy metatables
	self.animationManager:Destroy()
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Tool:_Equip()
	if self._destroyed then
		return
	end

	local tool: Tool? = nil
	for _, eachChild in pairs(localPlayer.Backpack:GetChildren()) do
		if eachChild:IsA("Tool") and eachChild:GetAttribute("id") == self._object.id then
			tool = eachChild
			break
		end
	end

	if not tool then
		Utils.Connections.Add(
			self,
			"ToolAdded",
			localPlayer.Backpack.ChildAdded:Connect(function(child)
				if child.Name == self._objectInfo.key then
					self:_Equip()
					Utils.Connections.DisconnectKeyConnection(self, "ToolAdded")
				end
			end)
		)

		Ports.AddToBackpack(self._object.id):andThen(function(success)
			if not success then
				self:Destroy()
			end
		end)

		return
	end

	-- Add tool connections
	Utils.Connections.Add(
		self,
		"ToolActivated",
		tool.Activated:Connect(function()
			if DeviceTypeUpdater.currentDeviceType == "mobile" then
				return
			end

			self:Activate()
		end)
	)
	Utils.Connections.Add(
		self,
		"ToolDeactivated",
		tool.Deactivated:Connect(function()
			if DeviceTypeUpdater.currentDeviceType == "mobile" then
				return
			end

			self:Deactivate()
		end)
	)
	Utils.Connections.Add(
		self,
		"ToolDestroying",
		tool.Destroying:Connect(function()
			self:Destroy()
		end)
	)

	self._humanoid:EquipTool(tool)

	localPlayer:SetAttribute("equippedObjectId", self._object.id)
	localPlayer:SetAttribute("equippedObjectKey", self._objectInfo.key)
end

function Tool:_RunHoldAnimation() end

-- FOCUS ----------------------------------------------------------------------------------------------------

function Tool:_FocusOnModel(model: Model, offset: Vector3)
	localPlayer:SetAttribute("focusingCharacter", true)
	Utils.Connections.DisconnectKeyConnection(self, "FocusOnModel")
	CustomCamera:FocusOnModel(model)
	localAxesAnimator:FocusOnModel(model, offset)

	Utils.Connections.Add(
		self,
		"FocusOnModel",
		RunService.Heartbeat:Connect(function()
			if self._destroyed then
				return
			end

			local characterPrimaryPart = self._character and self._character.PrimaryPart
			if not characterPrimaryPart or not model or not model.PrimaryPart then
				self:_StopFocusOnModel()
				return
			end

			-- Confirm model is still within range
			if
				not IsWithinDistance(
					characterPrimaryPart.Position,
					model.PrimaryPart.Position + (offset or Vector3.new(0, 0, 0)),
					(self._objectInfo.useRange or 0) + model.PrimaryPart.Size.Z / 2
				)
			then
				self:_StopFocusOnModel()
				return
			end
		end)
	)
end

function Tool:_StopFocusOnModel()
	localPlayer:SetAttribute("focusingCharacter", false)
	Utils.Connections.DisconnectKeyConnection(self, "FocusOnModel")
	CustomCamera:FocusOnModel(nil)
	localAxesAnimator:FocusOnModel(nil)
end

-- RESOURCE ----------------------------------------------------------------------------------------------------

function Tool:_GetClosestResource(applyHipHeightOffset: boolean?): table?
	local position = self._character and self._character.PrimaryPart and self._character.PrimaryPart.Position
	if not position then
		return nil
	end

	position = position - Vector3.new(0, applyHipHeightOffset and self._humanoid.HipHeight or 0, 0)
	local mouseLookVector = GetMouseRay().Direction.Unit

	local resource
	if self._objectInfo.resourceType == "any" then
		resource = ResourceManager.GetClosestResourceInLookVector(
			"trees",
			position,
			mouseLookVector,
			self._objectInfo.useRange or 0
		) or ResourceManager.GetClosestResourceInLookVector(
			"ores",
			position,
			mouseLookVector,
			self._objectInfo.useRange or 0
		)
	else
		resource = ResourceManager.GetClosestResourceInLookVector(
			self._objectInfo.resourceType,
			position,
			mouseLookVector,
			self._objectInfo.useRange or 0
		)
	end

	return resource
end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Tool:Activate()
	if self._destroyed then
		return
	end

	Utils.Connections.Add(
		self,
		"HeartbeatActivate",
		RunService.Heartbeat:Connect(function()
			self:Activate()
		end)
	)

	if os.clock() - self._lastHitTime < (self._objectInfo.useDelay or 0) then
		return
	end
	self._lastHitTime = os.clock()

	self.activated:Fire()
	Utils.Signals.Fire("ToolActivated")
end

function Tool:Deactivate()
	self.deactivated:Fire()

	Utils.Connections.DisconnectKeyConnection(self, "HeartbeatActivate")
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Tool
