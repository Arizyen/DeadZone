local Tree = {}
Tree.__index = Tree

-- Services ------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage.Packages
local ReplicatedSource = ReplicatedStorage.Source
local ServerSource = ServerStorage.Source
local ReplicatedPlaywooEngine = ReplicatedSource.PlaywooEngine
local PlaywooEngine = ServerSource.PlaywooEngine
local ReplicatedBaseModules = ReplicatedPlaywooEngine.BaseModules
local ReplicatedConfigs = ReplicatedSource.Configs
local Configs = ServerSource.Configs
local ReplicatedInfo = ReplicatedSource.Info
local Info = ServerSource.Info
local ReplicatedTypes = ReplicatedSource.Types
local Types = ServerSource.Types
local BaseModules = PlaywooEngine.BaseModules
local GameModules = ServerSource.GameModules
local BaseHandlers = PlaywooEngine.BaseHandlers
local GameHandlers = ServerSource.GameHandlers

local TreeModels = ReplicatedStorage.Models.Trees

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine.Utils)

-- Handlers --------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
local treeTypeModelFolder = {
	maple = TreeModels.Maple,
	palm = TreeModels.Palm,
	pine = TreeModels.Pine,
}

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Tree.new(
	type: string,
	cframe: CFrame,
	scaleFactor: number,
	stageIndex: number,
	stageProgress: number?,
	planted: boolean?
): typeof(Tree)
	local self = setmetatable({}, Tree)

	-- Booleans
	self._destroyed = false
	self._planted = planted or false

	-- Strings
	self._type = type

	-- Numbers
	self._scaleFactor = scaleFactor
	self._stageIndex = stageIndex
	self._growthProgress = stageProgress or 0

	-- CFrame
	self._cframe = cframe

	-- Instances
	self._instance = nil

	self:_Init()

	return self
end

function Tree:_Init()
	-- Spawn tree
	local modelFolder = treeTypeModelFolder[self._type]
	if not modelFolder then
		warn("Invalid tree type: " .. tostring(self._type))
		return
	end

	local stageModel = modelFolder:FindFirstChild(self._stageIndex)
	if not stageModel then
		warn("Invalid stage index: " .. tostring(self._stageIndex) .. " for tree type: " .. tostring(self._type))
		return
	end

	self._instance = stageModel:Clone()
	self._instance:PivotTo(self._cframe)
	self._instance:ScaleTo((self._instance:GetScale() or 1) * self._scaleFactor)
	self._instance.Parent = game.Workspace
end

function Tree:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)
end

function Tree:Update() end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Tree:GetInstance(): Model
	return self._instance
end

function Tree:GetCFrame(): CFrame
	return self._instance and self._instance:GetPivot()
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Tree
