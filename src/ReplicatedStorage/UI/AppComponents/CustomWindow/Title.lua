-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

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
local TextLabel = require(BaseComponents:WaitForChild("TextLabel"))

-- GlobalComponents ----------------------------------------------------------------

-- AppComponents -------------------------------------------------------------------
local CloseButton = require(AppComponents:WaitForChild("CloseButton"))

-- LocalComponents -----------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
type Props = {}

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------

-- Selectors --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function Title(props: Props)
	-- SELECTORS/CONTEXTS -----------------------------------------------------------------------------------------------------------
	local theme = React.useContext(BaseContexts.Theme)

	-- STATES/REFS/BINDINGS ---------------------------------------------------------------------------------------

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------

	-- EFFECTS -------------------------------------------------------------------------------------------------------------

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = props.title and 0 or 1,
		Position = UDim2.fromScale(0, 0),
		Size = UDim2.fromScale(1, 0.23):Lerp(
			UDim2.fromScale(1, 0.105),
			TweenService:GetValue(
				math.clamp(
					(((props.Size and props.Size.Y.Scale or theme.maxWindowSizeY) - 0.3) / (theme.maxWindowSizeY - 0.3)),
					0,
					1
				),
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.Out
			)
		),
		ZIndex = 3,
	}, {
		UIGradient = e("UIGradient", {
			Color = props.titleColorSequence or ColorSequence.new({
				ColorSequenceKeypoint.new(0, props.titleColor or Color3.fromRGB(0, 170, 255)),
				ColorSequenceKeypoint.new(
					1,
					props.titleColor
							and Color3.fromHSV(
								math.clamp(
									({ props.titleColor:ToHSV() })[1] + ({ props.titleColor:ToHSV() })[1] < 0.6 and 0.05
										or -0.05,
									0,
									1
								),
								({ props.titleColor:ToHSV() })[2],
								({ props.titleColor:ToHSV() })[3]
							)
						or Color3.fromRGB(0, 125, 235)
				),
			}),
			Rotation = 90,
		}),

		UIStroke = e(UIStroke, {
			Color = Color3.fromRGB(230, 230, 230),
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 3.5,
			Enabled = props.title and props.title ~= "",
		}),

		TextLabelTitle = e(TextLabel, {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.03, 0.5),
			Size = UDim2.fromScale(0.75, 1),
			Text = props.title or "",
			TextXAlignment = Enum.TextXAlignment.Left,
			bold = true,
			italic = true,
		}, {
			UIStroke = e(UIStroke, {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
				Thickness = 2.5,
				textStroke = true,
			}),
		}),

		ImageLabelIcon = e("ImageLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.01, 0.5),
			Size = UDim2.fromScale(0.1, 1),
			BackgroundTransparency = 1,
			Image = props.icon and "rbxassetid://9435990460" or "",
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 2,
		}, {
			UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
				AspectRatio = 1,
			}),
			ImageLabelIcon = e("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.9, 0.9),
				BackgroundTransparency = 1,
				Image = props.icon or "",
				ScaleType = Enum.ScaleType.Fit,
			}),
		}),

		FrameClose = e("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.98, 0),
			Size = UDim2.fromScale(0.1, 1),
			ZIndex = 2,
		}, {
			CloseButton = not props.noCloseButton and e(CloseButton, {
				windowName = props.windowName,
				onClose = props.onClose,
				onCloseCustom = props.onCloseCustom,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 0.775),
			}),
		}),
	})
end

return Title
