local Tool = {}
Tool.__index = Tool

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

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))
local Ports = require(script.Parent:WaitForChild("Ports"))
local DeviceTypeUpdater = require(ReplicatedBaseModules:WaitForChild("DeviceTypeUpdater"))
local AnimationManager = require(ReplicatedBaseModules:WaitForChild("AnimationManager"))

-- Handlers --------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
local ObjectTypes = require(ReplicatedTypes:WaitForChild("ObjectTypes"))

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------
local localPlayer = game.Players.LocalPlayer

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Tool.new(object: ObjectTypes.ToolCopy, objectInfo: ObjectTypes.Tool, humanoid: Humanoid)
	local self = setmetatable({}, Tool)

	-- Booleans
	self._destroyed = false

	-- Instances
	self._object = object
	self._objectInfo = objectInfo
	self._humanoid = humanoid

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

	if self._humanoid then
		self._humanoid:UnequipTools()
	end

	localPlayer:SetAttribute("equippedObjectId", nil)
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = true

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

	local tool = localPlayer.Backpack:FindFirstChild(self._objectInfo.key)

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

		Ports.AddToBackpack(self._object.id)

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

	self._humanoid:EquipTool(tool)

	localPlayer:SetAttribute("equippedObjectId", self._object.id)
	UserInputService.MouseIconEnabled = false
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
end

function Tool:_RunHoldAnimation() end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Tool:Activate()
	self.activated:Fire()
end

function Tool:Deactivate()
	self.deactivated:Fire()
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Tool
