local PlayerHandler = {}

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

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))
local Ports = require(script.Ports)
local SprintManager = require(script:WaitForChild("SprintManager"))

-- Handlers ----------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------
local localPlayer = game:GetService("Players").LocalPlayer
local sprintManager = SprintManager.new()

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function PlayerHandler.Register(ports)
	Utils.Table.Dictionary.mergeMut(Ports, ports)
end

-- CHARACTER MANAGEMENT ------------------------------------------------------------------------------------------------

function PlayerHandler.Spawn(): boolean
	return Ports.Spawn()
end

function PlayerHandler.Reset()
	Ports.Reset()
end

function PlayerHandler.Freeze(state)
	Ports.Freeze(state)

	local humanoid = Utils.Player.GetHumanoid(localPlayer)
	if humanoid and state then
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
	end
end

function PlayerHandler.AddStamina(amount: number)
	sprintManager:AddStamina(amount)
end

-- TELEPORTATION -------------------------------------------------------------------------------------------------------

function PlayerHandler.Teleport(cframe)
	if localPlayer.Character and localPlayer.Character.PrimaryPart then
		localPlayer.Character:PivotTo(cframe)
	end
end

-- NAMETAG ----------------------------------------------------------------------------------------------------

function PlayerHandler.ShowNameTag(state)
	local character = Utils.Player.GetCharacter(localPlayer)
	if character and character:FindFirstChild("Head") then
		local nameTag = character.Head:FindFirstChild("BillboardGuiNameTag")
		if nameTag then
			nameTag.Enabled = state
		end
	end
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
Utils.Signals.Once("ClientStarted", function()
	Ports.KnitLoaded()
end)

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return PlayerHandler
