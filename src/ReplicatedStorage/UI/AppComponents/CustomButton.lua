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
local TextLabel = require(BaseComponents:WaitForChild("TextLabel"))
local UIStroke = require(BaseComponents:WaitForChild("UIStroke"))

-- GlobalComponents ----------------------------------------------------------------
local Button = require(GlobalComponents:WaitForChild("Button"))

-- LocalComponents -----------------------------------------------------------------

-- AppComponents -------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
type Props = {
	Visible: boolean,
	Size: UDim2,
	Text: string?,
	textAnchorPoint: Vector2?,
	textPosition: UDim2?,
	textSize: number?,
	smallRatio: number?,
	largeRatio: number?,
	onClick: (() -> nil)?,
	onHold: (() -> nil)?,
	onHoldEnd: (() -> nil)?,
	noButtonAnimation: boolean?,
	shineAnimation: boolean?,
	shineAnimationVelocity: number?,
	shineAnimationColor3: Color3?,
	strokeThickness: number?,
	strokeColor3: Color3?,
	strokeTransparency: number?,
	colorSequence: ColorSequence?,
	cornerRadius: UDim?,
	aspectRatio: number?,
	image: string?,
	imageAnchorPoint: Vector2?,
	imagePosition: UDim2?,
	imageSize: UDim2?,
	imageVisible: boolean?,
	imageColor3: Color3?,
	imageTransparency: number?,
	imageUIAspectRatio: number?,
}

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------

-- Selectors --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function CustomButton(props: Props)
	-- SELECTORS/CONTEXTS -----------------------------------------------------------------------------------------------------------

	-- STATES/REFS/BINDINGS ---------------------------------------------------------------------------------------

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------
	local shineAnimationMotorConfigs = React.useMemo(function()
		if props.shineAnimation then
			return UIUtils.Flipper.CreateLoopingMotor(props.shineAnimationVelocity or 0.8)
		end
	end, { props.shineAnimation })

	-- EFFECTS -------------------------------------------------------------------------------------------------------------
	-- Cleanup
	React.useEffect(function()
		return function()
			if shineAnimationMotorConfigs then
				shineAnimationMotorConfigs:Destroy()
			end
		end
	end, {})

	-- Update shineAnimationMotorConfigs
	React.useLayoutEffect(function()
		if not props.shineAnimation and shineAnimationMotorConfigs then
			shineAnimationMotorConfigs:Destroy()
		elseif props.shineAnimation and shineAnimationMotorConfigs then
			-- Update velocity
			if shineAnimationMotorConfigs.velocity ~= props.shineAnimationVelocity then
				shineAnimationMotorConfigs:UpdateVelocity(props.shineAnimationVelocity)
			end

			-- Update active state
			if (props.Visible or props.Visible == nil) and not shineAnimationMotorConfigs.active then
				shineAnimationMotorConfigs:Start(true)
			elseif props.Visible == false and shineAnimationMotorConfigs.active then
				shineAnimationMotorConfigs:Start(false)
			end
		end
	end, { props.shineAnimation, props.shineAnimationVelocity, props.Visible })

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e(
		Button,
		Utils.Table.Dictionary.merge(props, {
			AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
			Position = props.Position or UDim2.fromScale(0.5, 0.5),
			Size = props.Size or UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			smallRatio = props.smallRatio,
			largeRatio = props.largeRatio,
			onClick = props.onClick,
			onHold = props.onHold,
			onHoldEnd = props.onHoldEnd,
			noButtonAnimation = props.noButtonAnimation,
		}),
		Utils.Table.Dictionary.merge({
			UICorner = e("UICorner", { CornerRadius = props.cornerRadius or UDim.new(0.1, 0) }),
			TextLabel = props.Text and e(TextLabel, {
				TextColor3 = props.TextColor3 or Color3.fromRGB(255, 255, 255),
				AnchorPoint = props.textAnchorPoint or Vector2.new(0.5, 0.5),
				Position = props.textPosition or UDim2.fromScale(0.5, 0.5),
				Size = props.textSize or UDim2.fromScale(0.8, 0.8),
				Font = props.Font,
				TextStrokeColor3 = props.TextStrokeColor3 or Color3.fromRGB(0, 0, 0),
				TextStrokeTransparency = props.TextStrokeTransparency or 0.8,
				Text = props.Text or "",
				RichText = props.RichText or false,
				ZIndex = 2,
			}),
			UIStroke = props.strokeThickness ~= 0 and e(UIStroke, {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				LineJoinMode = Enum.LineJoinMode.Round,
				Color = props.strokeColor3 or Color3.fromRGB(255, 255, 255),
				Thickness = props.strokeThickness or 2,
				Transparency = props.strokeTransparency or 0,
			}),
			UIGradient = e("UIGradient", {
				Color = props.colorSequence or Utils.Color.Configs.colorSequences["green5"],
				Rotation = 90,
			}),
			UIAspectRatioConstraint = props.aspectRatio and e("UIAspectRatioConstraint", {
				AspectRatio = props.aspectRatio,
			}),
			FrameShine = props.shineAnimation and e("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				ZIndex = 0,
				Visible = props.shineAnimation or false,
			}, {
				UICorner = e("UICorner", { CornerRadius = props.cornerRadius or UDim.new(0.1, 0) }),
				UIGradient = e("UIGradient", {
					Color = Utils.Color.ColorSequence({
						props.shineAnimationColor3 or Color3.fromRGB(235, 235, 235),
					}),
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0.3, 1),
						NumberSequenceKeypoint.new(0.5, 0.7),
						NumberSequenceKeypoint.new(0.7, 1),
						NumberSequenceKeypoint.new(1, 1),
					}),
					Offset = shineAnimationMotorConfigs.binding:map(function(value)
						return Vector2.new(Utils.Math.Lerp(-0.6, 0.6, value), 0)
					end),
				}),
			}),
			ImageLabel = props.image and e("ImageLabel", {
				BackgroundTransparency = 1,
				AnchorPoint = props.imageAnchorPoint or Vector2.new(0.5, 0.5),
				Position = props.imagePosition or UDim2.fromScale(0.5, 0.5),
				Size = props.imageSize or UDim2.fromScale(1, 1),
				Image = props.image or "rbxassetid://9128622454",
				ImageColor3 = props.imageColor3 or Color3.fromRGB(255, 255, 255),
				ImageTransparency = props.imageTransparency or 0,
				ScaleType = Enum.ScaleType.Fit,
				Visible = props.imageVisible or (props.imageVisible == nil),
			}, {
				UIAspectRatioConstraint = props.imageUIAspectRatio and e("UIAspectRatioConstraint", {
					AspectRatio = props.imageUIAspectRatio,
				}),
			}),
		}, props.children or {})
	)
end

return CustomButton
