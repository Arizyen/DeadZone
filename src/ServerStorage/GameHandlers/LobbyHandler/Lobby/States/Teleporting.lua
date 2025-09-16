local Teleporting = {}
Teleporting.__index = Teleporting

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
local ReplicatedInfo = ReplicatedSource.Info
local ReplicatedTypes = ReplicatedSource.Types
local BaseModules = PlaywooEngine.BaseModules
local GameModules = ServerSource.GameModules
local BaseHandlers = PlaywooEngine.BaseHandlers
local GameHandlers = ServerSource.GameHandlers

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine.Utils)
local SafeTeleport = require(BaseModules.SafeTeleport)

-- Handlers --------------------------------------------------------------------
local MessageHandler = require(BaseHandlers.MessageHandler)

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local MapConfigs = require(ReplicatedConfigs.MapConfigs)

-- Types ---------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Teleporting.new(lobby: table)
	local self = setmetatable({}, Teleporting)

	-- Booleans
	self._destroyed = false

	-- Strings
	self.type = "Teleporting"

	-- Instances
	self.lobby = lobby

	self:_Init()

	return self
end

function Teleporting:_Init()
	self.lobby:DestroyTouchConnections()
	self.lobby:ShowFrame("Teleporting")
	self:_TeleportPlayers()
end

function Teleporting:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Teleporting:_TeleportPlayers()
	local teleportOptions = Instance.new("TeleportOptions")
	teleportOptions.ShouldReserveServer = true

	local teleportData = {
		saveInfo = self.lobby.saveInfo,
	}
	teleportOptions:SetTeleportData(teleportData)

	if not SafeTeleport(MapConfigs.MAPS_PLACE_ID.PVE, self.lobby.players, teleportOptions) then
		task.defer(function()
			MessageHandler.SendMessageToPlayers(
				self.lobby.players,
				"There was an error teleporting players. Please try again.",
				"Error"
			)
			self.lobby:Reset()
		end)
	end
end

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Teleporting
