local ToolsManager = {}
ToolsManager.__index = ToolsManager

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
local ToolHandler = require(GameHandlers.ToolHandler)

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ToolsManager.new(player: Player)
	local self = setmetatable({}, ToolsManager)

	-- Booleans
	self._destroyed = false

	-- Instances
	self._player = player

	self:_Init()

	return self
end

function ToolsManager:_Init()
	-- Connections
	Utils.Connections.Add(
		self,
		"HotbarChanged",
		PlayerDataHandler.ObservePlayerPath(self._player.UserId, { "hotbar" }, function(new, prev)
			if not prev and new then
				-- Initial population of hotbar
				for _, objectId in pairs(new) do
					ToolHandler.AddToBackpack(self._player, objectId)
				end
			else
				-- Remove tools that are no longer in the hotbar
				for _, objectId in pairs(prev) do
					if not new[objectId] then
						ToolHandler.RemoveFromBackpack(self._player, objectId)
					end
				end

				-- Add tools that are newly added to the hotbar
				for _, objectId in pairs(new) do
					if not prev[objectId] then
						ToolHandler.AddToBackpack(self._player, objectId)
					end
				end
			end
		end)
	)

	Utils.Connections.Add(
		self,
		"CharacterAdded",
		self._player.CharacterAdded:Connect(function(character)
			self:_AddCharacterConnections(character)
		end)
	)

	-- Add tools from hotbar on initialization
	local hotbar = PlayerDataHandler.GetPathValue(self._player.UserId, { "hotbar" })

	if hotbar then
		for _, objectId in pairs(hotbar) do
			ToolHandler.AddToBackpack(self._player, objectId)
		end
	end

	-- Run functions
	self:_AddCharacterConnections(self._player.Character)
end

function ToolsManager:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Utils.Connections.DisconnectKeyConnections(self)
end

------------------------------------------------------------------------------------------------------------------------
-- PRIVATE CLASS METHODS -----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ToolsManager:_AddCharacterConnections(character: Model)
	if not character then
		return
	end

	Utils.Connections.Add(
		self,
		"ToolAdded",
		character.ChildAdded:Connect(function(child)
			if child:IsA("Tool") then
				ToolHandler.ToolEquipped(self._player, child)
			end
		end)
	)

	Utils.Connections.Add(
		self,
		"ToolRemoved",
		character.ChildRemoved:Connect(function(child)
			if child:IsA("Tool") then
				ToolHandler.ToolUnequipped(self._player, child)
			end
		end)
	)

	Utils.Connections.Add(
		self,
		"CharacterRemoving",
		self._player.CharacterRemoving:Connect(function()
			ToolHandler.UnequipTool(self._player)
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

return ToolsManager
