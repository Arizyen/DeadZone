local Tool = require(script.Parent)

local Rock = setmetatable({}, { __index = Tool })
Rock.__index = Rock
-- This is a SubClass of Tool which extends the Tool with the same methods and properties.

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
local ObjectTypes = require(ReplicatedTypes:WaitForChild("ObjectTypes"))

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Rock.new(object: ObjectTypes.Tool, objectInfo: ObjectTypes.Tool, humanoid: Humanoid)
	local self = setmetatable(Tool.new(object, objectInfo, humanoid), Rock)

	-- Booleans
	self._destroyed = false

	-- Numbers
	self._lastHitTime = 0

	-- Tables
	self._objectInfo = objectInfo

	self:_Init()

	return self
end

function Rock:_Init()
	-- Activate idle animation
	self.animationManager:PlayAnimation(self._objectInfo.animations["idle"], { looped = true })

	-- Connections
	Utils.Connections.Add(self, "Destroying", self.destroying:Connect(function() end))
	Utils.Connections.Add(
		self,
		"Activated",
		self.activated:Connect(function()
			self:_Activate()
		end)
	)
	Utils.Connections.Add(
		self,
		"Deactivated",
		self.deactivated:Connect(function()
			self:_Deactivate()
		end)
	)
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE METHODS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Rock:_Activate()
	self:_Hit()

	Utils.Connections.Add(
		self,
		"HeartbeatHit",
		RunService.Heartbeat:Connect(function()
			self:_Hit()
		end)
	)
end

function Rock:_Deactivate()
	Utils.Connections.DisconnectKeyConnection(self, "HeartbeatHit")
end

function Rock:_Hit()
	if os.clock() - self._lastHitTime < (self._objectInfo.attackDelay or 0) then
		return
	end
	self._lastHitTime = os.clock()

	Utils.Signals.Fire("ToolActivated")

	local animationTrack = self.animationManager:PlayAnimation(
		self._objectInfo.animations["attack"],
		{ priority = Enum.AnimationPriority.Action2 }
	)

	-- Adjust speed based on attackDelay and animation length (to sync length with attackDelay)
	animationTrack:AdjustSpeed(1 / (self._objectInfo.attackDelay / animationTrack.Length))
end

------------------------------------------------------------------------------------------------------------------------
-- VIRTUAL METHODS IMPLEMENTATION --------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC METHODS ------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Rock
