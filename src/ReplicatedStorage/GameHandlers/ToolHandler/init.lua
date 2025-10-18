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

local Tools = ReplicatedStorage:WaitForChild("Tools")

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))
local Ports = require(script:WaitForChild("Ports"))
local Tool = require(script:WaitForChild("Tool"))

-- Handlers ----------------------------------------------------------------
local PlayerDataHandler = require(ReplicatedBaseHandlers:WaitForChild("PlayerDataHandler"))
local MessageHandler = require(ReplicatedBaseHandlers:WaitForChild("MessageHandler"))

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

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

function ToolHandler.Activate() end

-- CLIENT FUNCTIONS ----------------------------------------------------------------------------------------------------

function ToolHandler.Equip(objectId: string)
	local object = PlayerDataHandler.GetPathValue({ "objects", objectId })

	if not object then
		warn("ToolHandler.Equip: Object not found with ID:", objectId)
		return
	elseif not Tools:FindFirstChild(object.key) then
		warn("ToolHandler.Equip: Tool not found with key:", object.key)
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

	currentTool = Tool.new(object, humanoid)
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
PlayerDataHandler.ObservePath({ "loadout", "equippedObjectId" }, function(newObjectId: string?)
	if not newObjectId and currentTool then
		ToolHandler.Unequip()
	end
end)

game.Players.LocalPlayer.CharacterRemoving:Connect(function()
	ToolHandler.Unequip()
end)

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false) -- Custom backpack UI

return ToolHandler
