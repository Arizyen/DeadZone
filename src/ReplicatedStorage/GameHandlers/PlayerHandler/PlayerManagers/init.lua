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
local PlayerAxesAnimator = require(script:WaitForChild("PlayerAxesAnimator"))

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
local playersZoneTracker = {} :: { [number]: typeof(PlayerZoneTracker) }
local playersAxesAnimator = {} :: { [number]: typeof(PlayerAxesAnimator) }
local playersManagerMap = {
	PlayerZoneTracker = playersZoneTracker,
	PlayerAxesAnimator = playersAxesAnimator,
}

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function AddPlayer(player: Player)
	if not player or player.Parent ~= game.Players or playersAdded[player.UserId] then
		return
	end
	playersAdded[player.UserId] = true

	-- All place managers
	playersZoneTracker[player.UserId] = PlayerZoneTracker.new(player)
	playersAxesAnimator[player.UserId] = PlayerAxesAnimator.new(player)

	-- Game place only managers
	if MapConfigs.IS_PVE_PLACE then
	end
end

local function RemovePlayer(player: Player)
	if not player or not playersAdded[player.UserId] then
		return
	end
	playersAdded[player.UserId] = nil

	for _, managerMap in pairs(playersManagerMap) do
		if managerMap[player.UserId] then
			managerMap[player.UserId]:Destroy()
			managerMap[player.UserId] = nil
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

function PlayerManagers.GetPlayerAxesAnimator(userId: number): typeof(PlayerAxesAnimator)?
	if not userId then
		return nil
	end
	return playersAxesAnimator[userId]
end

function PlayerManagers.UpdatePlayerAxes(userId: number, pitchRad: number, yawRad: number)
	if not userId then
		return
	end
	local axesAnimator = playersAxesAnimator[userId]
	if not axesAnimator then
		return
	end
	axesAnimator:Update(pitchRad, yawRad)
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
Utils.Signals.Once("ClientStarted", Activate)

return PlayerManagers
