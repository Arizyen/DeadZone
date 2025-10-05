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
local ReplicatedInfo = ReplicatedSource.Info
local ReplicatedTypes = ReplicatedSource.Types
local BaseModules = PlaywooEngine.BaseModules
local GameModules = ServerSource.GameModules
local BaseHandlers = PlaywooEngine.BaseHandlers
local GameHandlers = ServerSource.GameHandlers

-- Modules -------------------------------------------------------------------
local Knit = require(Packages.Knit)
local RateLimiter = require(BaseModules.RateLimiter)

-- Handlers -------------------------------------------------------------------
local GameHandler = require(GameHandlers.GameHandler)

-- Knit Services --------------------------------------------------------------------
local GameService = Knit.CreateService({
	Name = "Game",
	Client = { SetGameState = Knit.CreateSignal(), SetGameStateKey = Knit.CreateSignal() },
})

-- Types ---------------------------------------------------------------------------
local GameTypes = require(ReplicatedTypes:WaitForChild("GameTypes"))

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
-- KNIT FUNCTIONS ------------------------------------------------------------------------------------------------------

-- Require Knit Services in KnitInit(). KnitStart() is called after all KnitInit() have been completed.
function GameService:KnitInit()
	GameHandler.Register({
		SetGameState = function(newState: GameTypes.GameState)
			self.Client.SetGameState:FireAll(newState)
		end,
		SetGameStateKey = function(key: string, value: any)
			self.Client.SetGameStateKey:FireAll(key, value)
		end,
	})
end

-- KnitStart() fires after all KnitInit() have been completed.
function GameService:KnitStart() end

-------------------------------------------------------------------------------------------------------------------------
-- CLIENT FUNCTIONS -----------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------

function GameService.Client:GetGameState(playerFired: Player): GameTypes.GameState
	if not RateLimiter.Use(playerFired, "GameService", "GetGameState") then
		warn("Rate limit exceeded for GetGameState by player: " .. playerFired.Name)
		return
	end

	return GameHandler.GetGameState()
end

function GameService.Client:VoteSkipDay(playerFired: Player): boolean
	if not RateLimiter.Use(playerFired, "GameService", "VoteSkipDay") then
		warn("Rate limit exceeded for VoteSkipDay by player: " .. playerFired.Name)
		return false
	end

	return GameHandler.VoteSkipDay(playerFired)
end

return GameService
