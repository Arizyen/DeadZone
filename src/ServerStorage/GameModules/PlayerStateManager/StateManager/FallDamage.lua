local FallDamage = {}
FallDamage.__index = FallDamage

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
local PerksInfo = require(ReplicatedInfo.PerksInfo)

-- Configs -------------------------------------------------------------------------
local SAFE_FALL_HEIGHT = 12
local EXPONENT = 1.27
local MATERIAL_MULTIPLIER = {
	[Enum.Material.Plastic] = 1.0,
	[Enum.Material.Grass] = 0.9,
	[Enum.Material.Ground] = 0.95,
	[Enum.Material.Wood] = 1.0,
	[Enum.Material.Metal] = 1.1,
	[Enum.Material.Concrete] = 1.15,
	[Enum.Material.Sand] = 0.85,
	[Enum.Material.Snow] = 0.8,
	[Enum.Material.Ice] = 1.05,
	[Enum.Material.Water] = 0.25, -- splash landings hurt way less
}

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function FallDamage.new(player: Player, stateManager: table)
	local self = setmetatable({}, FallDamage)

	-- Booleans
	self._destroyed = false
	self._painTolerancePerk = PlayerDataHandler.GetPathValue(player.UserId, { "perks", "painTolerance" }) or false

	-- Instances
	self._player = player
	self._stateManager = stateManager

	-- Numbers
	self._fallDamageFactor = 1

	-- Vector3
	self._fallStartPosition = nil :: Vector3?

	self:_Init()

	return self
end

function FallDamage:_Init()
	-- Add connections
	Utils.Connections.Add(
		self,
		"painToleranceChanged",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "perks", "painTolerance" }, function(newValue)
			self._painTolerancePerk = newValue or false
			self:_UpdateFallDamageFactor()
		end)
	)

	Utils.Connections.Add(
		self,
		"teleported",
		self._player:GetAttributeChangedSignal("teleported"):Connect(function()
			self._fallStartPosition = nil
		end)
	)

	Utils.Connections.Add(
		self,
		"characterAdded",
		self._player.CharacterAdded:Connect(function(character)
			self:_CharacterAdded(character)
		end)
	)

	Utils.Connections.Add(
		self,
		"characterRemoving",
		self._player.CharacterRemoving:Connect(function()
			self:_CharacterAdded(nil)
		end)
	)

	self:_UpdateFallDamageFactor()
	self:_CharacterAdded(self._player.Character)
end

function FallDamage:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function FallDamage:_UpdateFallDamageFactor()
	local fallDamageFactor = 1

	if self._painTolerancePerk then
		local painTolerancePerkInfo = PerksInfo.byKey.painTolerance
		fallDamageFactor -= painTolerancePerkInfo.value
	end

	self._fallDamageFactor = fallDamageFactor
end

function FallDamage:_CharacterAdded(character: Model?)
	if not character or not character.Parent then
		Utils.Connections.DisconnectKeyConnection(self, "humanoidStateChanged")
		self._fallStartPosition = nil
		return
	end

	local humanoid = character:WaitForChild("Humanoid")

	Utils.Connections.Add(
		self,
		"humanoidStateChanged",
		humanoid.StateChanged:Connect(function(oldState, newState)
			if self._player:GetAttribute("teleported") then
				self._fallStartPosition = nil
				return
			end

			if newState == Enum.HumanoidStateType.Freefall then
				self._fallStartPosition = humanoid.RootPart.Position
			elseif
				(
					newState == Enum.HumanoidStateType.Landed
					or newState == Enum.HumanoidStateType.Running
					or newState == Enum.HumanoidStateType.RunningNoPhysics
				) and self._fallStartPosition
			then
				local fallEndPosition = humanoid.RootPart.Position
				local fallDistance = self._fallStartPosition.Y - fallEndPosition.Y

				if fallDistance > SAFE_FALL_HEIGHT then
					local floorMaterial = humanoid.FloorMaterial or Enum.Material.Plastic
					local damage = (fallDistance - SAFE_FALL_HEIGHT) ^ EXPONENT
						* (MATERIAL_MULTIPLIER[floorMaterial] or 1)
					self._stateManager:IncrementHP(-damage)
				end

				self._fallStartPosition = nil
			end
		end)
	)
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

return FallDamage
