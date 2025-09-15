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
local GlobalComponents = PlaywooEngineUI:WaitForChild("GlobalComponents")
local BaseComponents = PlaywooEngineUI:WaitForChild("BaseComponents")
local AppComponents = UI:WaitForChild("AppComponents")

-- Modulescripts -------------------------------------------------------------------
local React = require(Packages:WaitForChild("React"))
local ReactRedux = require(Packages:WaitForChild("ReactRedux"))
local UIUtils = require(ReplicatedPlaywooEngine:WaitForChild("UIUtils"))
local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))
local Contexts = require(UI:WaitForChild("Contexts"))
local BaseContexts = require(PlaywooEngineUI:WaitForChild("BaseContexts"))

-- Knit Controllers ----------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- BaseComponents ----------------------------------------------------------------
local UIStroke = require(BaseComponents:WaitForChild("UIStroke"))
local UIAspectRatioConstraint = require(BaseComponents:WaitForChild("UIAspectRatioConstraint"))

-- GlobalComponents ----------------------------------------------------------------
local Window = require(GlobalComponents:WaitForChild("Window"))

-- AppComponents -------------------------------------------------------------------
local CloseButton = require(AppComponents:WaitForChild("CloseButton"))

-- LocalComponents -----------------------------------------------------------------
local WindowIcon = require(script:WaitForChild("WindowIcon"))
local Title = require(script:WaitForChild("Title"))

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
type Props = {
	Size: UDim2,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	windowName: string,
	onClose: (() -> ())?,
	onCloseButtonClicked: (() -> ())?,
	exactSize: boolean?,
	title: string?,
	titleColorSequence: ColorSequence?,
	titleColor: Color3?,
	icon: string?,
	noCloseButton: boolean?,
	clipsDescendants: boolean?,
}

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------

-- Selectors --------------------------------------------------------------------------
local selector = UIUtils.Selector.Create({
	theme = { "maxWindowSizeX", "maxWindowSizeY" },
})
------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function CustomWindow(props: Props)
	-- SELECTORS/CONTEXTS -----------------------------------------------------------------------------------------------------------
	local storeState = ReactRedux.useSelector(selector)

	-- STATES/REFS/BINDINGS ---------------------------------------------------------------------------------------

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------
	local windowSize = React.useMemo(function()
		return (
			props.exactSize
			or (
				props.Size
				and props.Size.X.Scale <= storeState.maxWindowSizeX
				and props.Size.Y.Scale <= storeState.maxWindowSizeY
				and props.Size
			)
		)
			or (
				props.Size ~= nil and UDim2.fromScale(storeState.maxWindowSizeX, storeState.maxWindowSizeY)
				or UDim2.fromScale(0.5, 0.5)
			)
	end, { props.Size, props.exactSize, storeState.maxWindowSizeX, storeState.maxWindowSizeY })

	-- EFFECTS -------------------------------------------------------------------------------------------------------------

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e(Window, {
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.46),
		Position = props.Position or UDim2.fromScale(0.5, 0.5),
		Size = windowSize,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0,
		windowName = props.windowName or "CustomWindow",
		onClose = props.onClose,
	}, {
		UIAspectRatioConstraint = e(UIAspectRatioConstraint, {
			size = windowSize,
		}),
		UIGradient = e("UIGradient", {
			Color = Utils.Color.Configs.colorSequences.blackTotal,
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.05),
				NumberSequenceKeypoint.new(1, 0.15),
			}),
		}),
		UIStroke = e(UIStroke, {
			Color = Color3.fromRGB(230, 230, 230),
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 3.5,
		}),

		FrameTitle = props.title and e(Title, {
			Size = windowSize,
			windowName = props.windowName,
			title = props.title,
			titleColorSequence = props.titleColorSequence,
			titleColor = props.titleColor,
			icon = props.icon,
			noCloseButton = props.noCloseButton,
			onCloseButtonClicked = props.onCloseButtonClicked,
		}),

		FrameContent = e("Frame", {
			AnchorPoint = Vector2.new(0, 0),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2,
			ClipsDescendants = props.clipsDescendants,
		}, props.children or {}),
	})
end

return CustomWindow
