local RangeTracker = {}
RangeTracker.__index = RangeTracker

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
local PlayerManagers = require(ReplicatedGameHandlers:WaitForChild("PlayerHandler"):WaitForChild("PlayerManagers"))

-- Handlers --------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local ZoneConfigs = require(ReplicatedConfigs:WaitForChild("ZoneConfigs"))

-- Variables -----------------------------------------------------------------------
local localPlayer = game.Players.LocalPlayer

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function RangeTracker.new()
	local self = setmetatable({}, RangeTracker)

	-- Booleans
	self._destroyed = false

	-- Strings
	self._zoneKey = PlayerManagers.GetPlayerZoneKey(localPlayer.UserId)

	-- Tables
	self._playersInRange = {} :: { [number]: boolean }
	self._playersZoneKey = {} :: { [number]: string? }
	self._inRangeKeys = self._zoneKey and ZoneConfigs.GetZoneKeysInRange(self._zoneKey) or {} :: { string }

	self:_Init()

	return self
end

function RangeTracker:_Init()
	-- Connections
	Utils.Connections.Add(
		self,
		"playerZoneChanged",
		Utils.Signals.Connect("PlayerZoneChanged", function(player, newZoneKey)
			if player == localPlayer then
				self._zoneKey = newZoneKey
				self:_UpdatePlayersInRange()
			else
				self:_PlayerZoneChanged(player, newZoneKey)
			end
		end)
	)

	Utils.Connections.Add(
		self,
		"PlayerRemoving",
		game.Players.PlayerRemoving:Connect(function(player)
			self._playersInRange[player.UserId] = nil
			self._playersZoneKey[player.UserId] = nil
		end)
	)
end

function RangeTracker:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function RangeTracker:_PlayerZoneChanged(player: Player, newZoneKey: string?)
	self._playersZoneKey[player.UserId] = newZoneKey

	local prevInRange = self._playersInRange[player.UserId]
	local inRange = false

	if not newZoneKey then
		inRange = false
	else
		inRange = table.find(self._inRangeKeys, newZoneKey) ~= nil
	end

	if prevInRange ~= inRange then
		self._playersInRange[player.UserId] = inRange or nil
		self:_PlayerInRangeChanged(player, inRange or false)
	end
end

function RangeTracker:_UpdatePlayersInRange()
	if not self._zoneKey then
		return
	end

	self._inRangeKeys = ZoneConfigs.GetZoneKeysInRange(self._zoneKey)

	for userId, zoneKey in pairs(self._playersZoneKey) do
		local player = game.Players:GetPlayerByUserId(userId)
		if player and player ~= localPlayer then
			local inRange = table.find(self._inRangeKeys, zoneKey) ~= nil

			if self._playersInRange[userId] ~= (inRange or nil) then
				self._playersInRange[userId] = inRange or nil
				self:_PlayerInRangeChanged(player, inRange or false)
			end
		end
	end
end

function RangeTracker:_PlayerInRangeChanged(player: Player, inRange: boolean)
	player:SetAttribute("isInRange", inRange)
end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function RangeTracker:IsPositionInRange(position: Vector3): boolean
	if not position or not self._zoneKey then
		return false
	end

	local positionZoneKey = position.X .. "," .. position.Y .. "," .. position.Z

	return table.find(self._inRangeKeys, positionZoneKey) ~= nil
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return RangeTracker.new()
