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
local Flipper = require(Packages:WaitForChild("Flipper"))
local UIUtils = require(ReplicatedPlaywooEngine:WaitForChild("UIUtils"))
local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))
local Contexts = require(UI:WaitForChild("Contexts"))
local BaseContexts = require(PlaywooEngineUI:WaitForChild("BaseContexts"))

-- Knit Controllers ----------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- BaseComponents ----------------------------------------------------------------
local UIStroke = require(BaseComponents:WaitForChild("UIStroke"))

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
	onClose: (() -> nil)?,
	exactSize: boolean?,
	title: string?,
	titleColorSequence: ColorSequence?,
	titleColor: Color3?,
	icon: string?,
	noCloseButton: boolean?,
	customOnClose: boolean?,
	customFrameMainPosition: UDim2?,
	customFrameMainSize: UDim2?,
	clipsDescendants: boolean?,
}

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------

-- Selectors --------------------------------------------------------------------------
local selector = UIUtils.Selector.Create({
	theme = { "maxWindowSizeX", "maxWindowSizeY", "totalScreenSize" },
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
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		Position = props.Position or UDim2.fromScale(0.5, 0.5),
		Size = windowSize,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.1,
		windowName = props.windowName or "CustomWindow",
		onClose = props.noCloseButton and props.onClose,
	}, {
		UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = windowSize and ((windowSize.X.Scale * 1280) / (windowSize.Y.Scale * 720))
				or (0.5 * 1280) / (0.5 * 720),
		}),
		UIStroke = e(UIStroke, {
			Thickness = 3,
		}),
		FrameTitle = props.title and e(Title, {
			Size = windowSize,
			windowName = props.windowName,
			title = props.title,
			titleColorSequence = props.titleColorSequence,
			titleColor = props.titleColor,
			icon = props.icon,
			noCloseButton = props.noCloseButton,
			onClose = props.onClose,
			customOnClose = props.customOnClose,
		}),
		CloseButton = not props.title and not props.noCloseButton and e(CloseButton, {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(1.02, 0.5),
			Size = UDim2.fromScale(0.25, 0.25):Lerp(
				UDim2.fromScale(1, 0.106),
				math.clamp(
					(
						((props.Size and props.Size.Y.Scale or storeState.maxWindowSizeY) - 0.25)
						/ (storeState.maxWindowSizeY - 0.25)
					),
					0,
					1
				)
			),
			onClose = props.onClose,
			customOnClose = props.customOnClose,
			windowName = props.windowName,
		}),
		ImageLabelIcon = not props.title and props.icon and e(WindowIcon, {
			Size = windowSize,
			icon = props.icon,
		}),
		FrameMain = e("Frame", {
			AnchorPoint = Vector2.new(0, 0),
			BackgroundTransparency = 1,
			Position = props.customFrameMainPosition or UDim2.fromScale(0, 0.25):Lerp(
				UDim2.fromScale(0, 0.106),
				math.clamp(((windowSize.Y.Scale - 0.25) / (storeState.maxWindowSizeY - 0.25)), 0, 1)
			),
			Size = props.customFrameMainSize or UDim2.fromScale(1, 0.75):Lerp(
				UDim2.fromScale(1, 0.894),
				math.clamp(((windowSize.Y.Scale - 0.25) / (storeState.maxWindowSizeY - 0.25)), 0, 1)
			),
			ClipsDescendants = props.clipsDescendants,
		}, props.children or {}),
	})
end

return CustomWindow
