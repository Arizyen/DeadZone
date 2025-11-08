local ToolHandler = {}

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
local StartingTools = require(script.StartingTools)
local ToolCreator = require(script.ToolCreator)

-- Handlers --------------------------------------------------------------------
local PlayerDataHandler = require(BaseHandlers.PlayerDataHandler)
local MessageHandler = require(BaseHandlers.MessageHandler)

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
local playersEquippedTool: { [number]: table } = {}

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ToolHandler.Register(ports: Ports.Ports)
	Utils.Table.Dictionary.mergeMut(Ports, ports)
end

function ToolHandler.AddToBackpack(player: Player, objectId: string): boolean
	-- Get tool key from object ID
	local object = PlayerDataHandler.GetPathValue(player.UserId, { "objects", objectId })
	local toolKey = object and object.key

	if not toolKey then
		MessageHandler.SendMessageToPlayer(player, "You do not own this tool", "Error")
		return
	end

	return ToolCreator.AddToBackpack(player, toolKey, objectId)
end

-- Will remove a tool if contained in player's backpack
function ToolHandler.RemoveFromBackpack(player: Player, objectId: string)
	ToolCreator.RemoveFromBackpack(player, objectId)
end

-- EQUIP/UNEQUIP ----------------------------------------------------------------------------------------------------

function ToolHandler.ToolEquipped(player: Player, tool: Tool)
	local equippedTool = playersEquippedTool[player.UserId]
	if equippedTool and equippedTool:GetTool() == tool then
		return
	end

	ToolHandler.UnequipTool(player)

	-- Create a new tool metatable
	local toolModule = script.Tool:FindFirstChild(tool.Name)
	if not toolModule then
		warn("ToolHandler.ToolEquipped: Tool module not found for tool:", tool.Name)
		return
	end

	local toolMeta = require(toolModule).new(player, tool)
	playersEquippedTool[player.UserId] = toolMeta
end

function ToolHandler.ToolUnequipped(player: Player, tool: Tool)
	local equippedTool = playersEquippedTool[player.UserId]
	if equippedTool and equippedTool:GetTool() == tool then
		playersEquippedTool[player.UserId] = nil
	end
end

function ToolHandler.UnequipTool(player: Player)
	local equippedTool = playersEquippedTool[player.UserId]
	if equippedTool then
		equippedTool:Destroy()
		playersEquippedTool[player.UserId] = nil
	end
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

Utils.Signals.Connect("PlayerRemoving", function(player: Player)
	ToolHandler.UnequipTool(player)
end)

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return ToolHandler
