local PlayerZoneTracker = {}
PlayerZoneTracker.__index = PlayerZoneTracker

-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local ReplicatedSource = ReplicatedStorage:WaitForChild("Source")
local ReplicatedPlaywooEngine = ReplicatedSource:WaitForChild("PlaywooEngine")
local ReplicatedBaseModules = ReplicatedPlaywooEngine:WaitForChild("BaseModules")
local ReplicatedGameModules = ReplicatedSource:WaitForChild("GameModules")
local ReplicatedConfigs = ReplicatedSource:WaitForChild("Configs")
local ReplicatedInfo = ReplicatedSource:WaitForChild("Info")
local ReplicatedTypes = ReplicatedSource:WaitForChild("Types")
local ReplicatedBaseHandlers = ReplicatedPlaywooEngine:WaitForChild("BaseHandlers")
local ReplicatedGameHandlers = ReplicatedSource:WaitForChild("GameHandlers")

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))

-- Handlers --------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local RANGE = 200
local UPDATE_RATE = 2 -- Times per second

-- Variables -----------------------------------------------------------------------
local timerRunning = false

-- Tables --------------------------------------------------------------------------
local playersZoneTracker = {} :: { [number]: typeof(PlayerZoneTracker) }

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function StartTimer()
	if timerRunning then
		return
	end
	timerRunning = true

	task.spawn(function()
		while next(playersZoneTracker) do
			for _, zoneTracker in pairs(playersZoneTracker) do
				zoneTracker:Update()
			end
			task.wait(1 / UPDATE_RATE)
		end
		timerRunning = false
	end)
end

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function PlayerZoneTracker.new(player: Player)
	local self = setmetatable({}, PlayerZoneTracker)

	-- Booleans
	self._destroyed = false

	-- Instances
	self._player = player
	self._character = player.Character

	self:_Init()

	return self
end

function PlayerZoneTracker:_Init()
	-- Add connections
	Utils.Connections.Add(
		self,
		"CharacterAdded",
		self._player.CharacterAdded:Connect(function(character)
			self._character = character
			playersZoneTracker[self._player.UserId] = self
			StartTimer()
		end)
	)

	Utils.Connections.Add(
		self,
		"CharacterRemoving",
		self._player.CharacterRemoving:Connect(function()
			self._character = nil
			playersZoneTracker[self._player.UserId] = nil
		end)
	)
end

function PlayerZoneTracker:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)

	playersZoneTracker[self._player.UserId] = nil
end

function PlayerZoneTracker:Update() end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return PlayerZoneTracker
