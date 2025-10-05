-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local GameHandlers = Source:WaitForChild("GameHandlers")

-- Modulescripts
local Knit = require(Packages:WaitForChild("Knit"))

-- Handlers
local PlayerHandler = require(GameHandlers:WaitForChild("PlayerHandler"))

-- KnitControllers
local PlayerController = Knit.CreateController({
	Name = "Player",
})

-- Instances

-- Configs

-- Variables

-- Tables
local knitServices = {}

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------

function PlayerController:KnitInit()
	knitServices["Player"] = Knit.GetService("Player")
	PlayerHandler.Register({
		KnitLoaded = function()
			knitServices["Player"]:KnitLoaded()
		end,
		Freeze = function(state)
			knitServices["Player"]:Freeze(state)
		end,
		Spawn = function()
			return knitServices["Player"]:Spawn()
		end,
		Reset = function()
			knitServices["Player"]:Reset()
		end,
	})
end

function PlayerController:KnitStart()
	knitServices["Player"].Teleport:Connect(PlayerHandler.Teleport)
	knitServices["Player"].AddStamina:Connect(PlayerHandler.AddStamina)

	PlayerHandler.Activate()
end

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONTROLLER FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------

return PlayerController
