local MouseManager = {}

-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

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

-- Handlers ----------------------------------------------------------------

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ----------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------
local localPlayer = game.Players.LocalPlayer

-- Events --------------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function MouseManager.UpdateMouseProperties()
	local toolEquipped = localPlayer:GetAttribute("equippedObjectId") ~= nil
	local shiftLockDisabled = localPlayer:GetAttribute("shiftLockDisabled") or false

	if not toolEquipped then
		UserInputService.MouseIconEnabled = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		return
	end

	UserInputService.MouseIconEnabled = false

	if shiftLockDisabled and localPlayer:GetAttribute("deviceType") == "pc" then
		-- Free mouse
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	else
		-- Lock mouse to center
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	end
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

localPlayer:GetAttributeChangedSignal("equippedObjectId"):Connect(MouseManager.UpdateMouseProperties)
localPlayer:GetAttributeChangedSignal("shiftLockDisabled"):Connect(MouseManager.UpdateMouseProperties)
localPlayer:GetAttributeChangedSignal("deviceType"):Connect(MouseManager.UpdateMouseProperties)

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return MouseManager
