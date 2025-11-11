local ResourceHandler = {}

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
local ReplicatedTypes = ReplicatedSource.Types
local BaseModules = PlaywooEngine.BaseModules
local GameModules = ServerSource.GameModules
local BaseHandlers = PlaywooEngine.BaseHandlers
local GameHandlers = ServerSource.GameHandlers

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine.Utils)
local Ports = require(script.Ports)
local GameSaveData = require(GameModules.GameSaveData)
local TreeManager = require(script.TreeManager)
local Resources = require(script.Resources)

-- Handlers --------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ResourceHandler.Register(ports: Ports.Ports)
	Utils.Table.Dictionary.mergeMut(Ports, ports)
end

function ResourceHandler.Init()
	local resources = GameSaveData.GetResources()

	TreeManager.Init(resources.tree)

	-- Clear cached resources from save data to free up memory
	GameSaveData.ClearResources()
end

function ResourceHandler.GiveDamage(player: Player, id: string, damage: number)
	local resource = Resources[id]
	if not resource then
		return false, "Resource not found"
	end

	return resource:GiveDamage(player, damage)
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return ResourceHandler
