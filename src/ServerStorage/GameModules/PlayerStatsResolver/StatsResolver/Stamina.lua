local Stamina = {}
Stamina.__index = Stamina

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
local Info = ServerSource.Info
local ReplicatedTypes = ReplicatedSource.Types
local Types = ServerSource.Types
local BaseModules = PlaywooEngine.BaseModules
local GameModules = ServerSource.GameModules
local BaseHandlers = PlaywooEngine.BaseHandlers
local GameHandlers = ServerSource.GameHandlers

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine.Utils)

-- Handlers --------------------------------------------------------------------
local PlayerDataHandler = require(BaseHandlers.PlayerDataHandler)

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local MovementConfigs = require(ReplicatedConfigs:WaitForChild("MovementConfigs"))

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function Stamina.new(player: Player)
	local self = setmetatable({}, Stamina)

	-- Booleans
	self._destroyed = false

	-- Instances
	self._player = player :: Player

	-- Numbers
	self._staminaBoostGamepass = 0

	self:_Init()

	return self
end

function Stamina:_Init()
	Utils.Connections.Add(
		self,
		"StaminaGamepass",
		PlayerDataHandler.ObservePlayerPath(
			self._player.UserId,
			{ "gamepasses", "staminaBonus100" },
			function(hasGamepass)
				self._staminaBoostGamepass = hasGamepass and 100 or 0
			end
		)
	)

	self:Update()
end

function Stamina:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)
end

function Stamina:Update()
	PlayerDataHandler.SetPathValue(
		self._player.UserId,
		{ "stats", "maxStamina" },
		MovementConfigs.STAMINA + self._staminaBoostGamepass
	)
end

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

return Stamina
