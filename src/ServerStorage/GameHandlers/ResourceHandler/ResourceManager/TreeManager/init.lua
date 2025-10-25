local TreeManager = {}

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

local ResourceSpawns = game.Workspace.ResourceSpawns

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine.Utils)
local Tree = require(script.Tree)

-- Handlers --------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
local ResourceTypes = require(ReplicatedTypes.ResourceTypes)

-- Instances -----------------------------------------------------------------------

-- Info ----------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local MIN_SCALE_FACTOR = 0.8
local MAX_SCALE_FACTOR = 1.05

-- Variables -----------------------------------------------------------------------
local rng = Random.new()

-- Events --------------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
local trees = {} :: { [Instance]: typeof(Tree) }

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function TreeManager.Init(treesData: ResourceTypes.Resources?)
	if not treesData then
		-- Spawn trees at predefined locations at random
		for _, treeTypes in pairs(ResourceSpawns.Trees:GetChildren()) do
			local treeType = treeTypes.Name
			for _, spawn in pairs(treeTypes:GetChildren()) do
				local tree = Tree.new(
					string.lower(treeType),
					spawn.CFrame
						* CFrame.new(0, -spawn.Size.Y / 1.95, 0)
						* CFrame.Angles(0, math.rad(rng:NextInteger(0, 360)), 0),
					rng:NextNumber(MIN_SCALE_FACTOR, MAX_SCALE_FACTOR),
					rng:NextInteger(1, 3)
				)
				trees[tree:GetInstance()] = tree
			end
		end
	else
		for type, treeData in pairs(treesData) do
			local tree = Tree.new(
				string.lower(type),
				CFrame.new(table.unpack(string.split(treeData.cframe, ","))),
				treeData.scaleFactor,
				treeData.stageIndex,
				treeData.stageProgress,
				treeData.planted
			)
			trees[tree:GetInstance()] = tree
		end
	end
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return TreeManager
