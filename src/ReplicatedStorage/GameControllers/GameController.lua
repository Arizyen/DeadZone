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

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))
local Knit = require(Packages:WaitForChild("Knit"))

-- Handlers -----------------------------------------------------------------------
local GameHandler = require(ReplicatedGameHandlers:WaitForChild("GameHandler"))

-- Knit Controllers ----------------------------------------------------------------
local GameController = Knit.CreateController({
	Name = "Game",
})

-- Types ---------------------------------------------------------------------------
local GameTypes = require(ReplicatedTypes:WaitForChild("GameTypes"))

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
local knitServices = {}
------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS ------------------------------------------------------------------------------------------------------

-- Require Knit Services in KnitInit(). KnitStart() is called after all KnitInit() have been completed.
function GameController:KnitInit()
	knitServices["Game"] = Knit.GetService("Game")
	GameHandler.Register({
		GetGameState = function(): GameTypes.GameState
			return knitServices["Game"]:GetGameState()
		end,
		VoteSkipDay = function(): boolean
			return knitServices["Game"]:VoteSkipDay()
		end,
	})
end

-- KnitStart() fires after all KnitInit() have been completed.
function GameController:KnitStart()
	knitServices["Game"].SetGameState:Connect(function(newState: GameTypes.GameState)
		GameHandler.SetGameState(newState)
	end)

	GameHandler.Activate()
end

------------------------------------------------------------------------------------------------------------------------
-- CLIENT FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return GameController
