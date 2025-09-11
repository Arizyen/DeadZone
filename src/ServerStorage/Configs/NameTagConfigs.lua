local NameTagConfigs = {}
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
local BaseServices = PlaywooEngine.BaseServices
local GameServices = ServerSource.GameServices
local BaseHandlers = PlaywooEngine.BaseHandlers

-- Modulescripts -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine.Utils)

-- Handlers --------------------------------------------------------------------
local PlayerDataHandler = require(BaseHandlers.PlayerDataHandler)

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------
local LevelsInfo = require(ReplicatedInfo.LevelsInfo)

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
NameTagConfigs.PLAYER_INSTANCES_UPDATER = {
	TextLabelName = function(player, instance)
		instance.Text = player.DisplayName
	end,
	TextLabelLevel = function(player, instance)
		local level = PlayerDataHandler.GetKeyValue(player.UserId, "level")

		local updateFunction = function(newValue)
			instance.Text = type(newValue) == "number" and Utils.Number.Spaced(newValue) or "???"
		end
		updateFunction(level)

		NameTagConfigs.CreateInstanceConnection(player, "level", instance, updateFunction)
	end,
	ImageLabelLevel = function(player, instance)
		local level = PlayerDataHandler.GetKeyValue(player.UserId, "level")
		level = type(level) == "number" and level or 1

		local updateFunction = function(newValue)
			instance.Image = newValue > #LevelsInfo and LevelsInfo[#LevelsInfo] or LevelsInfo[newValue]
		end
		updateFunction(level)

		NameTagConfigs.CreateInstanceConnection(player, "level", instance, updateFunction)
	end,
}

NameTagConfigs.DUMMY_INSTANCES_UPDATER = {
	TextLabelLevel = function(data, instance)
		instance.Text = type(data.level) == "number" and Utils.Number.Spaced(data.level) or "???"
	end,
	ImageLabelLevel = function(data, instance)
		local level = type(data.level) == "number" and data.level or 1
		instance.Image = level > #LevelsInfo and LevelsInfo[#LevelsInfo] or LevelsInfo[level]
	end,
}

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function NameTagConfigs.CreateInstanceConnection(player, key, instance, updateFunction: ((newValue: any) -> nil)?)
	Utils.Connections.Add(
		player,
		"NameTag_" .. instance.Name,
		PlayerDataHandler.ObservePlayerKey(player.UserId, key, function(newValue)
			if not instance.Parent then
				Utils.Connections.DisconnectKeyConnection(player, "NameTag_" .. instance.Name)
				return
			end

			if updateFunction then
				updateFunction(newValue)
			else
				instance.Text = newValue or "???"
			end
		end)
	)
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return NameTagConfigs
