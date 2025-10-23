local ToolCreator = {}

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

local Tools = ServerStorage.Tools

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine.Utils)

-- Handlers --------------------------------------------------------------------
local InventoryHandler = require(GameHandlers.InventoryHandler)
local MessageHandler = require(BaseHandlers.MessageHandler)

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ----------------------------------------------------------------------------
local ObjectsInfo = require(ReplicatedInfo.ObjectsInfo)

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Events --------------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function IsValidToolKey(toolKey: string): boolean
	return ObjectsInfo.byKey[toolKey] ~= nil
end

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ToolCreator.AddToInventory(player: Player, toolKey: string, location: "inventory" | "hotbar")
	if not IsValidToolKey(toolKey) then
		warn("IsValidToolKey: Invalid tool key:", toolKey)
		return
	end

	InventoryHandler.AddObject(player, { key = toolKey, durability = 1 }, location or "inventory")
end

function ToolCreator.AddToBackpack(player: Player, toolKey: string)
	if not IsValidToolKey(toolKey) then
		warn("ToolCreator.AddToBackpack: Invalid tool key:", toolKey)
		MessageHandler.SendMessageToPlayer(player, "Invalid tool key: " .. toolKey, "Error")
		return
	end

	if not Tools:FindFirstChild(toolKey) then
		warn("ToolCreator.AddToBackpack: Tool not found in Tools folder:", toolKey)
		return
	elseif player.Backpack:FindFirstChild(toolKey) then
		return
	elseif player.Character and player.Character:FindFirstChild(toolKey) then
		return
	end

	local toolCopy = Tools[toolKey]:Clone()

	-- Add tool idle animation if exists
	local toolInfo = ObjectsInfo.byKey[toolKey]
	if toolInfo.animations and toolInfo.animations.idle then
		print("Adding tool idle animation for tool:", toolKey)
		Utils.Instantiator.Create("StringValue", {
			Name = "toolanim",
			Value = toolInfo.animations.idle,
			Parent = toolCopy,
		})
	end

	toolCopy.Parent = player.Backpack
end

function ToolCreator.RemoveFromBackpack(player: Player, toolKey: string)
	for _, tool in pairs(player.Backpack:GetChildren()) do
		if tool.Name == toolKey then
			tool:Destroy()
		end
	end
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return ToolCreator
