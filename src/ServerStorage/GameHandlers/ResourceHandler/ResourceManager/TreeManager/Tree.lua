local Tree = {}
Tree.__index = Tree

-- Services ------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

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

local Models = ReplicatedStorage.Models
local TreeModels = Models.Trees

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine.Utils)
local ZoneManager = require(GameModules.ZoneManager)

-- Handlers --------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
local ResourceTypes = require(ReplicatedTypes.ResourceTypes)

-- Instances -----------------------------------------------------------------------
local TreeSpawnSpot = Models.TreeSpawnSpot

-- Info ---------------------------------------------------------------------------
local ResourcesInfo = require(ReplicatedInfo.ResourcesInfo)

-- Configs -------------------------------------------------------------------------
local ResourceConfigs = require(ReplicatedConfigs.ResourceConfigs)

-- Variables -----------------------------------------------------------------------
local growthTimerRunning = false

-- Tables --------------------------------------------------------------------------
local treesGrowing = {} :: { [typeof(Tree)]: boolean }

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function StartGrowthTimer()
	if growthTimerRunning then
		return
	end
	growthTimerRunning = true

	local timerInterval = ResourceConfigs._TREE_GROWTH_TIMER_INTERVAL or 5

	task.spawn(function()
		while true do
			local anyGrowing = false
			for tree, _ in pairs(treesGrowing) do
				anyGrowing = true

				tree:UpdateGrowth(timerInterval)
			end

			if not anyGrowing then
				growthTimerRunning = false
				break
			end

			task.wait(timerInterval)
		end
	end)
end

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Tree.new(
	key: string,
	cframe: CFrame,
	scaleFactor: number,
	hp: number?,
	stageIndex: number,
	stageProgress: number?,
	planted: boolean?
): typeof(Tree)
	local self = setmetatable({}, Tree)

	-- Booleans
	self._destroyed = false
	self._planted = planted or false

	-- Tables
	self._resourceInfo = ResourcesInfo.byKey[key] :: ResourceTypes.ResourceInfo

	-- Strings
	self._id = HttpService:GenerateGUID(false):gsub("-", "")
	self._key = key

	-- Numbers
	self._scaleFactor = scaleFactor
	self._stageIndex = stageIndex or 0
	self._growthProgress = stageProgress or 0
	self._hp = hp or math.floor((self._resourceInfo.hp or 100) * self._scaleFactor * (self._stageIndex / 3))
	self._lastDamageReceivedTime = 0

	-- CFrame
	self._cframe = cframe

	-- Instances
	self._instance = nil

	-- Signals
	self.destroyed = Utils.Signals.Create()

	self:_Init()

	return self
end

function Tree:_Init()
	if not self._resourceInfo then
		warn("Tree:_Init: Invalid resource info for key: " .. tostring(self._key))
		return
	end

	-- Spawn tree
	if not self:_UpdateInstance() then
		return
	end

	-- Add tree to growing trees if applicable
	if self._stageIndex < 3 and self._planted then
		treesGrowing[self] = true
		StartGrowthTimer()
	end

	self:_UpdateHP(self._hp)
end

function Tree:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	treesGrowing[self] = nil

	Utils.Connections.DisconnectKeyConnections(self)

	self.destroyed:Fire()

	-- Cleanup
	if self._instance then
		self._instance:Destroy()
		self._instance = nil
	end

	self.destroyed:Destroy()
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- Updates the tree instance based on its current stageIndex
function Tree:_UpdateInstance(): boolean
	if self._instance then
		self._instance:Destroy()
		self._instance = nil
	end

	local modelFolder = TreeModels:FindFirstChild(self._key)
	if not modelFolder then
		warn("Invalid tree key: " .. tostring(self._key))
		return false
	end

	local stageModel = self._stageIndex == 0 and TreeSpawnSpot or modelFolder:FindFirstChild(self._stageIndex)
	if not stageModel then
		warn("Invalid stage index: " .. tostring(self._stageIndex) .. " for tree key: " .. tostring(self._key))
		return false
	end

	self._instance = stageModel:Clone()
	self._instance:PivotTo(self._cframe)
	ZoneManager.ParentResource(self._instance, "Trees")

	return true
end

function Tree:_UpdateHP(newHP: number)
	self._hp = newHP
	self._instance:SetAttribute("hp", self._hp)
	if self._hp <= 0 then
		self:Destroy()
	end
end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Tree:GetId(): string
	return self._id
end

function Tree:GetCFrame(): CFrame
	return self._instance and self._instance:GetPivot()
end

function Tree:UpdateGrowth(timePassed: number)
	-- Check if tree can grow (not damaged recently)
	if os.time() - self._lastDamageReceivedTime >= ResourceConfigs._COOLDOWN_GROWTH_AFTER_DAMAGE then
		-- Increase growth progress (there are 4 stages including sapling)
		self._growthProgress += timePassed / ((ResourceConfigs._TREE_GROWTH_TIME * self._resourceInfo.growthTimeFactor) / 4)

		-- Check if growth stage should increase
		if self._growthProgress >= 1 then
			self._growthProgress = 0
			self._stageIndex += 1

			-- Update tree instance
			if not self:_UpdateInstance() then
				-- Failed to update instance, destroy tree
				self:Destroy()
				return
			else
				-- Check if tree is fully grown
				if self._stageIndex >= 3 then
					treesGrowing[self] = nil
				end
			end

			self:_UpdateHP(self._hp + math.floor((self._resourceInfo.hp or 100) * self._scaleFactor * (1 / 3)))
		end
	end
end

function Tree:TakeDamage(player: Player, damage: number)
	if self._destroyed then
		return
	end

	self._lastDamageReceivedTime = os.time()
	self:_UpdateHP(self._hp - damage)
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Tree
