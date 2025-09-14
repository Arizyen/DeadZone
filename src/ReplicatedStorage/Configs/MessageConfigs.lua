local MessageConfigs = {}

-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local ReplicatedSource = ReplicatedStorage:WaitForChild("Source")
local ReplicatedPlaywooEngine = ReplicatedSource:WaitForChild("PlaywooEngine")
local ReplicatedBaseModules = ReplicatedPlaywooEngine:WaitForChild("BaseModules")
local ReplicatedConfigs = ReplicatedSource:WaitForChild("Configs")
local ReplicatedInfo = ReplicatedSource:WaitForChild("Info")
local ReplicatedTypes = ReplicatedSource:WaitForChild("Types")

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))
local StoreObserver = require(ReplicatedBaseModules:WaitForChild("StoreObserver"))

-- Handlers ----------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
local MessageTypes = require(ReplicatedTypes:WaitForChild("Message"))

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
MessageConfigs.DEFAULT_MESSAGE_WINDOW_PROPS = {
	maxMessages = 3,
	AnchorPoint = Vector2.new(0.5, 1),
	BackgroundTransparency = 1,
	Position = UDim2.fromScale(0.5, 0.875),
	Size = UDim2.fromScale(0.65, 0.075),
	ZIndex = 15,
} :: MessageTypes.MessageWindowProps -- This gets merged with any new props set in the reducer

local WINDOWS_MESSAGE_WINDOW_CONFIGS = {}

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function NewWindowShown(windowName: string)
	if windowName and WINDOWS_MESSAGE_WINDOW_CONFIGS[windowName] then
		Utils.Signals.Fire("DispatchAction", {
			type = "SetMessageWindowProps",
			value = Utils.Table.Dictionary.merge(
				MessageConfigs.DEFAULT_MESSAGE_WINDOW_PROPS,
				WINDOWS_MESSAGE_WINDOW_CONFIGS[windowName]
			),
		})
	end
end

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
StoreObserver.Observe(function(state)
	return state.window.windowShown
end, function(windowName)
	NewWindowShown(windowName)
end, { fireImmediately = true })

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
Utils.Signals.Connect("ClientStarted", function()
	Utils.Signals.Fire("DispatchAction", {
		type = "SetMessageWindowProps",
		value = MessageConfigs.DEFAULT_MESSAGE_WINDOW_PROPS,
	})
end)

return MessageConfigs
