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
local PlayersManagers = require(ReplicatedGameHandlers:WaitForChild("PlayerHandler"):WaitForChild("PlayersManagers"))

-- Handlers --------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

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
	self._zoneKey = PlayersManagers.GetPlayerZoneKey(localPlayer.UserId)

	-- Tables
	self._playersInRange = {} :: { [number]: boolean }
	self._playersZoneKey = {} :: { [number]: string? }
	self._inRangeKeys = {} :: { string }

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
		local coordinates = string.split(newZoneKey, ",")
		local x, y, z = tonumber(coordinates[1]), tonumber(coordinates[2]), tonumber(coordinates[3])

		for i = x - 1, x + 1 do
			for j = y - 1, y + 1 do
				for k = z - 1, z + 1 do
					if self._zoneKey == (i .. "," .. j .. "," .. k) then
						inRange = true
						break
					end
				end
				if inRange then
					break
				end
			end
			if inRange then
				break
			end
		end
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

	local inRangeZoneKeys = {}
	local coordinates = string.split(self._zoneKey, ",")
	local x, y, z = tonumber(coordinates[1]), tonumber(coordinates[2]), tonumber(coordinates[3])

	for i = x - 1, x + 1 do
		for j = y - 1, y + 1 do
			for k = z - 1, z + 1 do
				table.insert(inRangeZoneKeys, i .. "," .. j .. "," .. k)
			end
		end
	end
	self._inRangeKeys = inRangeZoneKeys

	for userId, zoneKey in pairs(self._playersZoneKey) do
		local player = game.Players:GetPlayerByUserId(userId)
		if player and player ~= localPlayer then
			local inRange = table.find(inRangeZoneKeys, zoneKey) ~= nil

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
