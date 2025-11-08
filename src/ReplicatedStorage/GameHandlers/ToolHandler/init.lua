local ToolHandler = {}

-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

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

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))
local Ports = require(script:WaitForChild("Ports"))

-- Handlers ----------------------------------------------------------------
local PlayerDataHandler = require(ReplicatedBaseHandlers:WaitForChild("PlayerDataHandler"))
local MessageHandler = require(ReplicatedBaseHandlers:WaitForChild("MessageHandler"))

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------
local ObjectsInfo = require(ReplicatedInfo:WaitForChild("ObjectsInfo"))

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------
local localPlayer = game.Players.LocalPlayer
local currentTool

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ToolHandler.Register(ports: Ports.Ports)
	Utils.Table.Dictionary.mergeMut(Ports, ports)
end

function ToolHandler.Activate()
	if currentTool then
		currentTool:Activate()
	end
end

function ToolHandler.Deactivate()
	if currentTool then
		currentTool:Deactivate()
	end
end

-- CLIENT FUNCTIONS ----------------------------------------------------------------------------------------------------

function ToolHandler.Equip(objectId: string)
	local object = PlayerDataHandler.GetPathValue({ "objects", objectId })
	local objectInfo = ObjectsInfo.byKey[object and object.key]

	if not object or not objectInfo then
		warn("ToolHandler.Equip: Object not found with ID:", objectId)
		return
	elseif objectInfo.type ~= "tool" then
		warn("ToolHandler.Equip: Object is not a tool with ID:", objectId)
		MessageHandler.ShowMessage("This item cannot be equipped!", "Error")
		return
	elseif localPlayer:GetAttribute("isDead") then
		MessageHandler.ShowMessage("You cannot equip tools while dead!", "Error")
		return
	end

	local humanoid = Utils.Player.GetHumanoid(localPlayer)
	if not humanoid then
		MessageHandler.ShowMessage("You cannot equip tools while dead!", "Error")
		return
	end

	ToolHandler.Unequip()

	if not script.Tool:FindFirstChild(object.key) then
		warn("ToolHandler.Equip: Tool module not found with key:", object.key)
		MessageHandler.ShowMessage("Could not find tool to equip", "Error")
		return
	end

	-- Equip tool
	local toolModule = require(script.Tool:FindFirstChild(object.key))
	currentTool = toolModule.new(object, objectInfo, humanoid)
end

function ToolHandler.Unequip()
	if currentTool then
		currentTool:Destroy()
		currentTool = nil
	end
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

game.Players.LocalPlayer.CharacterRemoving:Connect(function()
	ToolHandler.Unequip()
end)

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false) -- Custom backpack UI

return ToolHandler
