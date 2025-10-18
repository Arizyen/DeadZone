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

local Tools = ReplicatedStorage:WaitForChild("Tools")

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))

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

function Tool.new(object: ObjectTypes.Tool, humanoid: Humanoid): Tool
	local self = setmetatable({}, Tool)

	-- Booleans
	self._destroyed = false

	-- Instances
	self._object = object
	self._humanoid = humanoid
	self._toolInstance = nil

	self:_Init()

	return self
end

function Tool:_Init()
	-- Connections
	Utils.Connections.Add(
		self,
		"UnequipOnDied",
		self._humanoid.Died:Connect(function()
			self:Destroy()
		end)
	)

	-- Clone and equip tool
	local tool = Tools:FindFirstChild(self._object.key)
	if not tool then
		warn("Tool:_Init: Tool not found with key:", self._object.key)
		self:Destroy()
		return
	end

	self._toolInstance = tool:Clone()
	self._humanoid:EquipTool(self._toolInstance)

	localPlayer:SetAttribute("toolEquipped", true)
	UserInputService.MouseIconEnabled = false
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
end

function Tool:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)

	if self._toolInstance then
		self._toolInstance:Destroy()
		self._toolInstance = nil
	end

	localPlayer:SetAttribute("toolEquipped", false)
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = true
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Tool
