-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Packages = ReplicatedStorage.Packages
local ReplicatedSource = ReplicatedStorage.Source
local ServerSource = ServerStorage.Source
local ReplicatedPlaywooEngine = ReplicatedSource.PlaywooEngine
local PlaywooEngine = ServerSource.PlaywooEngine
local ReplicatedBaseModules = ReplicatedPlaywooEngine.BaseModules
local ReplicatedConfigs = ReplicatedSource.Configs
local ReplicatedInfo = ReplicatedSource.Info
local ReplicatedKeys = ReplicatedSource.Keys
local ReplicatedTypes = ReplicatedSource.Types
local BaseModules = PlaywooEngine.BaseModules
local GameModules = ServerSource.GameModules
local GameHandlers = ServerSource.GameHandlers

-- Modulescripts
local Knit = require(Packages.Knit)

-- Handlers
local PlayerHandler = require(GameHandlers.PlayerHandler)

-- KnitServices
local PlayerService = Knit.CreateService({
	Name = "Player",
	Client = { Teleport = Knit.CreateSignal() },
})

-- Instances

-- Configs

-- Variables

-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------

function PlayerService:KnitInit()
	PlayerHandler.Register({
		Teleport = function(player: Player, cframe: CFrame)
			self.Client.Teleport:Fire(player, cframe)
		end,
	})
end

function PlayerService:KnitStart() end

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- SERVICE FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- CLIENT FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------

function PlayerService.Client:Freeze(playerFired, state)
	PlayerHandler.Freeze(playerFired, state)
end

function PlayerService.Client:Spawn(playerFired)
	return PlayerHandler.Spawn(playerFired)
end

function PlayerService.Client:Reset(playerFired)
	PlayerHandler.Reset(playerFired)
end

function PlayerService.Client:KnitLoaded(playerFired)
	PlayerHandler.KnitLoaded(playerFired)
end

return PlayerService
