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
	self:Update()
end

function Teleporting:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)
end

function Teleporting:Update() end

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

return Teleporting
