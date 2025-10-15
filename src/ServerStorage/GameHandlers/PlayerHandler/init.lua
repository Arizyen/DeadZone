local PlayerHandler = {}

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
local Utils = require(ReplicatedPlaywooEngine.Utils)
local PlayerManager = require(BaseModules.PlayerManager)
local Ports = require(script.Ports)
local Teleport = require(ReplicatedPlaywooEngine.Utils.Teleport)

-- Handlers --------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function PlayerHandler.Register(ports: Ports.Ports)
	Utils.Table.Dictionary.mergeMut(Ports, ports)
end

-- TELEPORTATION ----------------------------------------------------------------------------------------------------

function PlayerHandler.Teleport(player: Player, teleportParams: Teleport.TeleportParams)
	local cframe = Utils.Teleport.Player(player, teleportParams)
	if typeof(cframe) == "CFrame" then
		Ports.Teleport(player, cframe)
	end
end

function PlayerHandler.TeleportPlayers(players: { Player }, teleportParams: Teleport.TeleportParams)
	for _, player in pairs(players) do
		PlayerHandler.Teleport(player, teleportParams)
	end
end

function PlayerHandler.TeleportToFloor(player)
	local cframe = Utils.Teleport.ToFloor(player)
	if typeof(cframe) == "CFrame" then
		Ports.Teleport(player, cframe)
	end
end

-- CHARACTER MANAGEMENT ------------------------------------------------------------------------------------------------

function PlayerHandler.Freeze(player: Player, state: boolean)
	PlayerManager.Freeze(player, state)
end

function PlayerHandler.Spawn(player: Player): boolean
	return PlayerManager.Spawn(player)
end

function PlayerHandler.Reset(player: Player)
	PlayerManager.Reset(player)
end

function PlayerHandler.AddStamina(player: Player, amount: number)
	Ports.AddStamina(player, amount)
end

function PlayerHandler.ReplicateAxes(player: Player, pitchRad: number, yawRad: number)
	Ports.ReplicatePlayerAxes(player, pitchRad, yawRad)
end

-- STATE MANAGEMENT ----------------------------------------------------------------------------------------------------

function PlayerHandler.KnitLoaded(player: Player)
	player:SetAttribute("knitLoaded", true)
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return PlayerHandler
