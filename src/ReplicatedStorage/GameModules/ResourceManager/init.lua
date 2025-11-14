local ResourceManager = {}

-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local ReplicatedSource = ReplicatedStorage:WaitForChild("Source")
local ReplicatedPlaywooEngine = ReplicatedSource:WaitForChild("PlaywooEngine")
local ReplicatedConfigs = ReplicatedSource:WaitForChild("Configs")
local ReplicatedInfo = ReplicatedSource:WaitForChild("Info")
local ReplicatedTypes = ReplicatedSource:WaitForChild("Types")
local ReplicatedBaseModules = ReplicatedPlaywooEngine:WaitForChild("BaseModules")
local ReplicatedGameModules = ReplicatedSource:WaitForChild("GameModules")
local ReplicatedBaseHandlers = ReplicatedPlaywooEngine:WaitForChild("BaseHandlers")
local ReplicatedGameHandlers = ReplicatedSource:WaitForChild("GameHandlers")

local Zones = game.Workspace:WaitForChild("Zones")

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))
local PlayerManagers = require(ReplicatedGameHandlers:WaitForChild("PlayerHandler"):WaitForChild("PlayerManagers"))
local Resources = require(script:WaitForChild("Resources"))
local Tree = require(script:WaitForChild("Tree"))

-- Handlers ----------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
export type ResourcesType = "trees" | "ores"

-- Instances -----------------------------------------------------------------------

-- Info ----------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local ZoneConfigs = require(ReplicatedConfigs:WaitForChild("ZoneConfigs"))

-- Variables -----------------------------------------------------------------------
local localPlayer = game.Players.LocalPlayer
local ConnectionsManager = Utils.ConnectionsManager.new()

-- Events --------------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
local resourceModules = {
	trees = Tree,
}

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function AddResource(resourceType: ResourcesType, instance: Instance): boolean
	local hp = instance:GetAttribute("hp")
	if type(hp) ~= "number" or hp <= 0 then
		return false
	end

	local resource = Resources[resourceType][instance.Name]

	if not resource then
		resourceModules[resourceType].new(instance)
	else
		resource:Activate()
	end

	return true
end

local function Update(newOriginKey)
	newOriginKey = newOriginKey or PlayerManagers.GetPlayerZoneKey(localPlayer.UserId)
	local zoneKeysInRange = ZoneConfigs.GetZoneKeysInRange(newOriginKey)

	ConnectionsManager:DisconnectAll()

	-- Get resources in range
	local newResourcesToTrack = {} :: { [string]: boolean }
	for _, zoneKey in pairs(zoneKeysInRange) do
		local zoneFolder = Zones:FindFirstChild(zoneKey)
		if zoneFolder then
			-- Get trees
			local treesFolder = zoneFolder:FindFirstChild("Trees")
			if treesFolder then
				for _, treeInstance in pairs(treesFolder:GetChildren()) do
					if AddResource("trees", treeInstance) then
						newResourcesToTrack[treeInstance.Name] = true
					end
				end

				-- Add a child added connection to track new trees
				ConnectionsManager:Add(
					"TreesChildAdded_" .. zoneKey,
					treesFolder.ChildAdded:Connect(function(treeInstance)
						AddResource("trees", treeInstance)
					end)
				)
			end

			-- TODO: Get ores
		end
	end

	-- Remove resources out of range
	for _, resources in pairs(Resources) do
		for resourceKey, resource in pairs(resources) do
			if not newResourcesToTrack[resourceKey] then
				resource:Deactivate() -- Starts a timer to destroy the resource metatable after some time
			end
		end
	end
end

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- GETTERS ----------------------------------------------------------------------------------------------------

-- Returns all resource instances of a specific type that are currently within range
function ResourceManager.GetResourceInstances(resourceType: ResourcesType): { Instance }
	local resourceInstances = {}

	local resourcesOfType = Resources[resourceType]
	if not resourcesOfType then
		return resourceInstances
	end

	for _, resource in pairs(resourcesOfType) do
		table.insert(resourceInstances, resource:GetInstance())
	end

	return resourceInstances
end

function ResourceManager.GetClosestResource(
	resourceType: ResourcesType,
	position: Vector3,
	maxDistance: number
): typeof(Tree)?
	local closestResource = nil
	local closestDistSq = maxDistance * maxDistance -- Using squared distance for performance

	local resourcesOfType = Resources[resourceType]
	if not resourcesOfType then
		return nil
	end

	for _, resource in pairs(resourcesOfType) do
		local resourceInstance = resource:GetInstance()
		if resourceInstance and resourceInstance.Parent then
			local offset = resourceInstance:GetPivot().Position - position
			local distanceSq = offset.X * offset.X + offset.Y * offset.Y + offset.Z * offset.Z

			if distanceSq <= closestDistSq then
				closestDistSq = distanceSq
				closestResource = resource
			end
		end
	end

	return closestResource
end

function ResourceManager.GetClosestResourceInLookVector(
	resourceType: ResourcesType,
	position: Vector3,
	lookVector: Vector3,
	toolUseRange: number,
	angleThreshold: number
): typeof(Tree)?
	local closestResource = nil
	local cosAngleThreshold = math.cos(math.rad(angleThreshold or 180))
	local closestCosAngle = nil

	local resourcesOfType = Resources[resourceType]
	if not resourcesOfType then
		return nil
	end

	for _, resource in pairs(resourcesOfType) do
		local resourceInstance = resource:GetInstance()
		if resourceInstance and resourceInstance.Parent and resourceInstance.PrimaryPart then
			local maxDistance = toolUseRange + resourceInstance.PrimaryPart.Size.Z / 2
			maxDistance = maxDistance * maxDistance -- Squared
			local offset = resourceInstance:GetPivot().Position - position
			local distanceSq = offset.X * offset.X + offset.Y * offset.Y + offset.Z * offset.Z

			if distanceSq <= maxDistance then
				local direction = offset.Unit
				local dotProduct = lookVector:Dot(direction)

				if dotProduct >= cosAngleThreshold and (closestCosAngle == nil or dotProduct > closestCosAngle) then
					closestCosAngle = dotProduct
					closestResource = resource
				end
			end
		end
	end

	return closestResource
end

function ResourceManager.GetResource(resourceType: ResourcesType, resourceId: string): typeof(Tree)?
	local resourcesOfType = Resources[resourceType]
	if not resourcesOfType then
		return nil
	end

	return resourcesOfType[resourceId]
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
Utils.Signals.Connect("PlayerZoneChanged", function(player: Player, newZoneKey: string)
	if player == localPlayer then
		Update(newZoneKey)
	end
end)

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return ResourceManager
