local StateManager = {}
StateManager.__index = StateManager

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
local PlayerStatsResolver = require(GameModules.PlayerStatsResolver)
local HP = require(script.HP)
local Stamina = require(script.Stamina)

-- Handlers --------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
local SaveTypes = require(ReplicatedTypes.Save)

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local StateConfigs = require(Configs.StateConfigs)

-- Variables -----------------------------------------------------------------------
local updateTimerRunning = false

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- Deserialize the player state, ensuring all fields are present and correctly typed
local function Deserialize(player: Player, playerState: SaveTypes.PlayerState): SaveTypes.PlayerState
	return {
		hp = playerState.hp or StateConfigs.HP_MAX,
		position = type(playerState.position) == "string" and Vector3.new(unpack(string.split(playerState.position)))
			or playerState.position,
	}
end

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function StateManager.new(player: Player, playerState: SaveTypes.PlayerState?)
	local self = setmetatable({}, StateManager)

	-- Booleans
	self._destroyed = false

	-- Instances
	self._player = player :: Player

	-- Tables
	self.state = Deserialize(player, playerState or {}) :: SaveTypes.PlayerState

	-- Metatables
	self.statsResolver = PlayerStatsResolver.GetStatsResolver(player)
	self._hp = HP.new(player, self)
	self._stamina = Stamina.new(player)

	self:_Init()

	return self
end

function StateManager:_Init() end

function StateManager:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	self._hp:Destroy()
	self._stamina:Destroy()

	Utils.Connections.DisconnectKeyConnections(self)
end

function StateManager:Update(playerState: SaveTypes.PlayerState?)
	if self._destroyed then
		return
	end

	if playerState then
		self.state = Deserialize(self._player, playerState)
	end
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- PUBLIC CLASS METHODS ------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- HP ----------------------------------------------------------------------------------------------------

function StateManager:GetStartingHP(): number
	return self._hp:GetStartingHP()
end

function StateManager:GetMaxHP(): number
	return self._hp:GetMaxHP()
end

function StateManager:IncrementHP(amount: number)
	return self._hp:Increment(amount)
end

-- STAMINA ----------------------------------------------------------------------------------------------------

function StateManager:AddStamina(amount: number)
	self._stamina:Add(amount)
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return StateManager
