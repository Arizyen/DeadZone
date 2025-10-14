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
local localPlayer = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera

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
	self._activated = false
	self._isLocalPlayer = player == localPlayer

	-- Instances
	self._player = player
	self._character = player.Character

	-- Strings
	self._zoneKey = "" -- Current zone key (x,y,z)

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
			self:_Activate()
		end)
	)

	Utils.Connections.Add(
		self,
		"CharacterRemoving",
		self._player.CharacterRemoving:Connect(function()
			self._character = nil
			self:_Deactivate()
		end)
	)

	if self._character or self._isLocalPlayer then
		self:_Activate()
	end
end

function PlayerZoneTracker:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)

	self:_Deactivate()
end

function PlayerZoneTracker:Update()
	local root = self._isLocalPlayer and camera.CFrame or self._character and self._character.PrimaryPart
	if not root then
		return
	end

	local rootPosition = root.Position
	local x, y, z =
		math.floor(rootPosition.X / RANGE), math.floor(rootPosition.Y / RANGE), math.floor(rootPosition.Z / RANGE)

	self:_UpdateZoneKey(tostring(x) .. "," .. tostring(y) .. "," .. tostring(z))
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function PlayerZoneTracker:_Activate()
	self:Update()
	playersZoneTracker[self._player.UserId] = self
	StartTimer()
end

function PlayerZoneTracker:_Deactivate()
	if self._isLocalPlayer then
		-- Keep it running for the local player
		return
	end

	playersZoneTracker[self._player.UserId] = nil
	self:_UpdateZoneKey()
end

function PlayerZoneTracker:_UpdateZoneKey(zoneKey: string?)
	if zoneKey ~= self._zoneKey then
		self._zoneKey = zoneKey
		-- Fire signal
		Utils.Signals.Fire("PlayerZoneChanged", self._player, zoneKey)
	end
end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function PlayerZoneTracker:GetZoneKey(): string
	return self._zoneKey
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return PlayerZoneTracker
