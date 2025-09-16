-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local ReplicatedSource = ReplicatedStorage:WaitForChild("Source")
local ReplicatedPlaywooEngine = ReplicatedSource:WaitForChild("PlaywooEngine")
local ReplicatedConfigs = ReplicatedSource:WaitForChild("Configs")
local ReplicatedInfo = ReplicatedSource:WaitForChild("Info")
local ReplicatedTypes = ReplicatedSource:WaitForChild("Types")
local ReplicatedBaseModules = ReplicatedPlaywooEngine:WaitForChild("BaseModules")
local ReplicatedGameModules = ReplicatedSource:WaitForChild("GameModules")
local BaseControllers = ReplicatedPlaywooEngine:WaitForChild("BaseControllers")
local GameControllers = ReplicatedSource:WaitForChild("GameControllers")

local UI = ReplicatedSource:WaitForChild("UI")
local PlaywooEngineUI = ReplicatedPlaywooEngine:WaitForChild("UI")
local BaseComponents = PlaywooEngineUI:WaitForChild("BaseComponents")
local GlobalComponents = PlaywooEngineUI:WaitForChild("GlobalComponents")
local AppComponents = UI:WaitForChild("AppComponents")

-- Modulescripts -------------------------------------------------------------------
local React = require(Packages:WaitForChild("React"))
local ReactRedux = require(Packages:WaitForChild("ReactRedux"))
local Flipper = require(Packages:WaitForChild("Flipper"))
local UIUtils = require(ReplicatedPlaywooEngine:WaitForChild("UIUtils"))
local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))

-- Knit Controllers ----------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- BaseComponents ----------------------------------------------------------------
local TextLabel = require(BaseComponents:WaitForChild("TextLabel"))

-- GlobalComponents ----------------------------------------------------------------

-- AppComponents -------------------------------------------------------------------
local CustomWindow = require(AppComponents:WaitForChild("CustomWindow"))

-- LocalComponents -----------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local _WINDOW_NAME = "Teleporting"

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Types ---------------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

-- Selectors --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function Teleporting(props)
	-- Requires:
	-- Optional:
	-- SELECTORS/CONTEXTS -----------------------------------------------------------------------------------------------------------

	-- REFS/BINDINGS/STATES ---------------------------------------------------------------------------------------

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------

	-- EFFECTS -------------------------------------------------------------------------------------------------------------

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e(CustomWindow, {
		Size = UDim2.fromScale(0.35, 0.35),
		windowName = _WINDOW_NAME,
		title = "Teleporting",
		titleColorSequence = Utils.Color.Configs.colorSequences.blue,
		noCloseButton = true,
	}, {
		TextLabelTeleporting = e(TextLabel, {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(0.9, 1),
			Text = "You are being teleported. Please wait...",
			TextColor3 = Color3.fromRGB(255, 255, 255),
		}),
	})
end

game.Players.LocalPlayer:GetAttributeChangedSignal("isTeleporting"):Connect(function()
	local teleporting = game.Players.LocalPlayer:GetAttribute("isTeleporting")
	if teleporting then
		UIUtils.Window.Show(_WINDOW_NAME, true, true)
	else
		UIUtils.Window.Close(_WINDOW_NAME)
	end
end)

return Teleporting
