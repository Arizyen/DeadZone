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

	-- Tables

	-- Instances
	self._animationTrack = nil :: AnimationTrack?

	self:_Init()

	return self
end

function Rock:_Init()
	-- Activate idle animation
	self.animationManager:PlayAnimation(self._objectInfo.animations["idle"], { looped = true })

	-- Connections
	Utils.Connections.Add(
		self,
		"Destroying",
		self.destroying:Connect(function()
			self:_Deactivate()
		end)
	)

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
	Utils.Connections.DisconnectKeyConnection(self, "AnimationTrackStopped")
	self._animationTrack = self.animationManager:PlayAnimation(
		self._objectInfo.animations["attack"],
		{ priority = Enum.AnimationPriority.Action2 }
	)

	-- Adjust speed based on useDelay and animation length (to sync length with useDelay)
	self._animationTrack:AdjustSpeed(1 / (self._objectInfo.useDelay / self._animationTrack.Length))

	local resource = self:_GetClosestResource(true)
	if resource then
		local resourceModel = resource:GetInstance()
		if not resourceModel or not resourceModel.PrimaryPart then
			return
		end

		self:_FocusOnModel(
			resourceModel,
			Vector3.new(
				0,
				self._humanoid.HipHeight + (resource:GetType() == "tree" and self._character.PrimaryPart.Size.Y or 0),
				0
			)
		)
	end
end

function Rock:_Deactivate()
	if not self._animationTrack or not self._animationTrack.IsPlaying then
		self:_StopFocusOnModel()
	else
		Utils.Connections.Add(
			self,
			"AnimationTrackStopped",
			self._animationTrack.Stopped:Connect(function()
				Utils.Connections.DisconnectKeyConnection(self, "AnimationTrackStopped")
				self:_StopFocusOnModel()
			end)
		)
	end
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
