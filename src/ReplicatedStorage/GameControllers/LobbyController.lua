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
local LobbyHandler = require(ReplicatedGameHandlers:WaitForChild("LobbyHandler"))

-- Knit Controllers ----------------------------------------------------------------
local LobbyController = Knit.CreateController({
	Name = "Lobby",
})

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
local LobbyTypes = require(ReplicatedTypes:WaitForChild("Lobby"))

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
function LobbyController:KnitInit()
	knitServices["Lobby"] = Knit.GetService("Lobby")
	LobbyHandler.Register({
		GetAllLobbiesState = function()
			return knitServices["Lobby"]:GetAllLobbiesState()
		end,
		LeaveLobby = function(): boolean
			return knitServices["Lobby"]:LeaveLobby()
		end,
	})
end

-- KnitStart() fires after all KnitInit() have been completed.
function LobbyController:KnitStart()
	knitServices["Lobby"].UpdateLobbyState:Connect(function(lobbyState: LobbyTypes.LobbyState)
		LobbyHandler.UpdateLobbyState(lobbyState)
	end)
end

return LobbyController
