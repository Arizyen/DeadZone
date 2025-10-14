local PlayerManagers = {}

-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

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
local PlayerZoneTracker = require(script:WaitForChild("PlayerZoneTracker"))
local PlayerPitchAnimator = require(script:WaitForChild("PlayerPitchAnimator"))

-- Handlers ------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ----------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local MapConfigs = require(ReplicatedConfigs:WaitForChild("MapConfigs"))

-- Variables -----------------------------------------------------------------------

-- Events --------------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
local playersAdded = {} :: { [number]: boolean }
local playersZoneTracker = {}
local playersPitchAnimator = {}
local playersManagerList = {
	PlayerZoneTracker = playersZoneTracker,
	PlayerPitchAnimator = playersPitchAnimator,
}

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function AddPlayer(player: Player)
	if not player or player.Parent ~= game.Players or playersAdded[player.UserId] then
		return
	end
	playersAdded[player.UserId] = true

	playersZoneTracker[player.UserId] = PlayerZoneTracker.new(player)
	playersPitchAnimator[player.UserId] = PlayerPitchAnimator.new(player)
end

local function RemovePlayer(player: Player)
	if not player or not playersAdded[player.UserId] then
		return
	end
	playersAdded[player.UserId] = nil

	for _, managerList in pairs(playersManagerList) do
		if managerList[player.UserId] then
			managerList[player.UserId]:Destroy()
			managerList[player.UserId] = nil
		end
	end
end

local function AddConnections()
	Utils.Signals.Connect("PlayerAdded", AddPlayer)
	Utils.Signals.Connect("PlayerRemoving", RemovePlayer)
end

local function Activate()
	AddConnections()

	for _, player in pairs(Players:GetPlayers()) do
		AddPlayer(player)
	end
end

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function PlayerManagers.GetPlayerZoneKey(userId: number): string?
	if not userId then
		return nil
	end
	local zoneTracker = playersZoneTracker[userId]
	if not zoneTracker then
		return nil
	end
	return zoneTracker:GetZoneKey()
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

if MapConfigs.IS_PVE_PLACE then
	Activate()
end

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return PlayerManagers
