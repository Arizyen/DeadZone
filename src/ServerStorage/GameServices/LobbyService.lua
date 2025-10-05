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
local ReplicatedTypes = ReplicatedSource.Types
local BaseModules = PlaywooEngine.BaseModules
local GameModules = ServerSource.GameModules
local BaseHandlers = PlaywooEngine.BaseHandlers
local GameHandlers = ServerSource.GameHandlers

-- Modules -------------------------------------------------------------------
local Knit = require(Packages.Knit)
local RateLimiter = require(BaseModules.RateLimiter)

-- Handlers -------------------------------------------------------------------
local LobbyHandler = require(GameHandlers.LobbyHandler)

-- Knit Services --------------------------------------------------------------------
local LobbyService = Knit.CreateService({
	Name = "Lobby",
	Client = { UpdateLobbyState = Knit.CreateSignal() },
})

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local MapConfigs = require(ReplicatedConfigs.MapConfigs)

-- Types ---------------------------------------------------------------------------
local LobbyTypes = require(ReplicatedTypes.LobbyTypes)

-- Variables -----------------------------------------------------------------------
local isLobby = MapConfigs.MAPS_PLACE_ID.Lobby == game.PlaceId

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS ------------------------------------------------------------------------------------------------------

-- Require Knit Services in KnitInit(). KnitStart() is called after all KnitInit() have been completed.
function LobbyService:KnitInit()
	LobbyHandler.Register({
		FireLobbyStateUpdate = function(state: LobbyTypes.LobbyState, playersLobbyId: { [number]: string })
			self.Client.UpdateLobbyState:FireAll(state, playersLobbyId)
		end,
	})
end

-- KnitStart() fires after all KnitInit() have been completed.
function LobbyService:KnitStart()
	if isLobby then
		LobbyHandler.Activate()
	end
end

-------------------------------------------------------------------------------------------------------------------------
-- CLIENT FUNCTIONS -----------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------

function LobbyService.Client:GetAllLobbiesState(player: Player): { [string]: LobbyTypes.LobbyState }?
	if not RateLimiter.Use(player, "LobbyService", "GetAllLobbiesState") then
		return nil
	end

	return LobbyHandler.GetAllLobbiesState()
end

function LobbyService.Client:LeaveLobby(player: Player): boolean
	if not RateLimiter.Use(player, "LobbyService", "LeaveLobby") then
		return false
	end

	return LobbyHandler.LeaveLobby(player)
end

function LobbyService.Client:CreateLobby(player: Player, settings: LobbyTypes.LobbySettings): (boolean, string?)
	if not RateLimiter.Use(player, "LobbyService", "CreateLobby") then
		return false
	end

	return LobbyHandler.CreateLobby(player, settings)
end

return LobbyService
