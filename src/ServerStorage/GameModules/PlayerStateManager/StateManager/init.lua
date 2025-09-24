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
local Energy = require(script.Energy)

-- Handlers --------------------------------------------------------------------
local PlayerDataHandler = require(BaseHandlers.PlayerDataHandler)

-- Types ---------------------------------------------------------------------------
local SaveTypes = require(ReplicatedTypes.Save)

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local StateConfigs = require(Configs.StateConfigs)

-- Variables -----------------------------------------------------------------------
local updateTimerRunning = false

-- Tables --------------------------------------------------------------------------
local stateManagers = {} :: { [number]: typeof(StateManager) } -- Key is player UserId

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function StartUpdateTimer()
	if updateTimerRunning then
		return
	end
	updateTimerRunning = true

	task.spawn(function()
		local last = os.clock()
		local elapsed = 0

		while updateTimerRunning do
			task.wait(5)

			local now = os.clock()
			elapsed = now - last
			last = now

			for _, stateManager in pairs(stateManagers) do
				stateManager:Update(nil, elapsed)
			end
		end
	end)
end

-- Deserialize the player state, ensuring all fields are present and correctly typed
local function Deserialize(player: Player, playerState: SaveTypes.PlayerState): SaveTypes.PlayerState
	local playerGamepasses = PlayerDataHandler.GetKeyValue(player.UserId, "gamepasses") or {} :: { [string]: boolean }

	return {
		hp = playerState.hp or StateConfigs.HP_MAX,
		energy = playerState.energy or StateConfigs.ENERGY_MAX * (playerGamepasses["x2Energy"] and 2 or 1),
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
	self._energy = Energy.new(player, self)

	self:_Init()

	return self
end

function StateManager:_Init()
	stateManagers[self._player.UserId] = self
	StartUpdateTimer()
end

function StateManager:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	stateManagers[self._player.UserId] = nil

	self._hp:Destroy()
	self._energy:Destroy()

	Utils.Connections.DisconnectKeyConnections(self)
end

function StateManager:Update(playerState: SaveTypes.PlayerState?, elapsedTime: number?)
	if self._destroyed then
		return
	end

	if playerState then
		self.state = Deserialize(self._player, playerState)
	end

	elapsedTime = elapsedTime or 0

	self._hp:Update(elapsedTime)
	self._energy:Update(elapsedTime)
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

-- ENERGY ----------------------------------------------------------------------------------------------------
function StateManager:GetStartingEnergy(): number
	return self._energy:GetStartingEnergy()
end

function StateManager:GetMaxEnergy(): number
	return self._energy:GetMaxEnergy()
end

function StateManager:IncrementEnergy(amount: number)
	return self._energy:Increment(amount)
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return StateManager
