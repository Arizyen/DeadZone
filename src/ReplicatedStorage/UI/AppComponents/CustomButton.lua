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
local BaseHooks = PlaywooEngineUI:WaitForChild("BaseHooks")

-- Knit Controllers ----------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- BaseComponents ----------------------------------------------------------------
local TextLabel = require(BaseComponents:WaitForChild("TextLabel"))
local TextLabelAutoSize2 = require(BaseComponents:WaitForChild("TextLabelAutoSize2"))
local UIStroke = require(BaseComponents:WaitForChild("UIStroke"))

-- GlobalComponents ----------------------------------------------------------------
local Button = require(GlobalComponents:WaitForChild("Button"))

-- LocalComponents -----------------------------------------------------------------

-- AppComponents -------------------------------------------------------------------

-- Hooks ---------------------------------------------------------------------------
local useMotorMappedBinding = require(BaseHooks:WaitForChild("useMotorMappedBinding"))

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
type Props = {
	Visible: boolean,
	Size: UDim2,
	text: string?,
	richText: boolean?,
	fontFace: Font?,
	textSize: UDim2?,
	textBold: boolean?,
	textItalic: boolean?,
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
	imageSize: UDim2?,
	imageVisible: boolean?,
	imageColor3: Color3?,
	imageTransparency: number?,
}

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------
local screenSizeCornerRadius = {
	large = UDim.new(0.125, 0),
	small = UDim.new(0.175, 0),
}
local screenSizeButtonOffset = {
	large = -5,
	small = -2,
}

-- Selectors --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function CustomButton(props: Props)
	-- SELECTORS/CONTEXTS -----------------------------------------------------------------------------------------------------------
	local isOnSmallScreen = ReactRedux.useSelector(function(state)
		return state.theme.isOnSmallScreen
	end)

	-- STATES/REFS/BINDINGS ---------------------------------------------------------------------------------------
	local isHoveringBinding, setIsHovering = React.useBinding(false)
	local motorRef = React.useRef(
		props.shineAnimation and UIUtils.Motor.OscillatingMotor.new(props.shineAnimationVelocity or 0.8) or nil
	)

	local screenSize = isOnSmallScreen and "small" or "large"

	-- CALLBACKS ----------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------
	local offsetMappedBinding = useMotorMappedBinding(motorRef, function(value)
		return Vector2.new(Utils.Math.Lerp(-0.6, 0.6, value), 0)
	end, Vector2.new(-0.6, 0), { motorRef.current })

	-- EFFECTS -------------------------------------------------------------------------------------------------------------
	-- Cleanup
	React.useEffect(function()
		return function()
			if motorRef.current then
				motorRef.current:Destroy()
			end
		end
	end, {})

	-- Update motorRef
	React.useLayoutEffect(function()
		-- If shineAnimation is false, destroy motor if it exists
		if not props.shineAnimation then
			if motorRef.current then
				motorRef.current:Destroy()
				motorRef.current = nil
			end
			return
		end

		-- Create motor if it doesn't exist
		if not motorRef.current then
			motorRef.current = UIUtils.Motor.OscillatingMotor.new(props.shineAnimationVelocity or 0.8)
		end

		-- Update velocity
		motorRef.current:SetVelocity(props.shineAnimationVelocity or 0.8)
		-- Update motor state based on visibility
		local isVisible = props.Visible == nil or props.Visible
		if isVisible then
			motorRef.current:Start()
		else
			motorRef.current:Stop()
		end
	end, { props.shineAnimation, props.shineAnimationVelocity, props.Visible })

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e(
		Button,
		Utils.Table.Dictionary.merge(props, {
			AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
			AutoButtonColor = false,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			Position = props.Position or UDim2.fromScale(0.5, 0.5),
			Size = props.Size or UDim2.fromScale(1, 1),
			smallRatio = props.smallRatio,
			largeRatio = props.largeRatio,
			onClick = props.onClick,
			onHold = props.onHold,
			onHoldEnd = props.onHoldEnd,
			noButtonAnimation = props.noButtonAnimation,
			onMouseEnter = function()
				setIsHovering(true)
			end,
			onMouseLeave = function()
				setIsHovering(false)
			end,
		}),
		{
			UICorner = e("UICorner", { CornerRadius = props.cornerRadius or screenSizeCornerRadius[screenSize] }),
			UIAspectRatioConstraint = props.aspectRatio and e("UIAspectRatioConstraint", {
				AspectRatio = props.aspectRatio,
			}),
			UIStroke = props.strokeThickness ~= 0 and e(UIStroke, {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = props.strokeColor3 or Color3.fromRGB(25, 25, 25),
				Thickness = props.strokeThickness or 2.5,
				Transparency = props.strokeTransparency or 0,
			}),

			FrameBackground = e("Frame", {
				BackgroundColor3 = (props.colorSequence or Utils.Color.Configs.colorSequences["green"]).Keypoints[1].Value,
				BackgroundTransparency = 0.5,
				Size = UDim2.fromScale(1, 1),
			}, {
				UICorner = e("UICorner", { CornerRadius = props.cornerRadius or screenSizeCornerRadius[screenSize] }),
			}),

			FrameForeground = e(
				"Frame",
				{
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Size = UDim2.new(1, 0, 1, screenSizeButtonOffset[screenSize] or -5),
					ZIndex = 2,
				},
				Utils.Table.Dictionary.merge({
					UICorner = e(
						"UICorner",
						{ CornerRadius = props.cornerRadius or screenSizeCornerRadius[screenSize] }
					),
					UIGradient = e("UIGradient", {
						Color = props.colorSequence or Utils.Color.Configs.colorSequences["green"],
						Rotation = 90,
					}),

					FrameContent = (props.image or props.text) and e("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.85, 1),
						ZIndex = 3,
					}, {
						UIListLayout = e("UIListLayout", {
							Padding = UDim.new(0.035, 0),
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
						}),

						ImageLabel = props.image and e("ImageLabel", {
							BackgroundTransparency = 1,
							LayoutOrder = 1,
							Size = props.imageSize or UDim2.fromScale(0.23, 1),
							Image = props.image or "",
							ImageColor3 = props.imageColor3 or Color3.fromRGB(255, 255, 255),
							ImageTransparency = props.imageTransparency or 0,
							Visible = props.image and (props.imageVisible or (props.imageVisible == nil)) or false,
							ScaleType = Enum.ScaleType.Fit,
						}),

						TextLabel = props.text and e(props.textSize and TextLabel or TextLabelAutoSize2, {
							LayoutOrder = 2,
							Size = props.textSize or UDim2.fromScale(0.7, 0.85),
							TextColor3 = props.textColor3 or Color3.fromRGB(255, 255, 255),
							FontFace = props.fontFace,
							Text = props.text or "",
							RichText = props.richText or false,
							bold = props.textBold,
							italic = props.textItalic,
							lengthAtMaxScaleX = 7,
							minScaleX = 0.5,
						}, {
							UIStroke = e(UIStroke, {
								Thickness = 2.5,
								textStroke = true,
							}),
						}),
					}),

					FrameHover = e("Frame", {
						Size = UDim2.fromScale(1, 1),
						BackgroundColor3 = Color3.fromRGB(0, 0, 0),
						BackgroundTransparency = 0.925,
						Visible = isHoveringBinding,
						ZIndex = 2,
					}, {
						UICorner = e(
							"UICorner",
							{ CornerRadius = props.cornerRadius or screenSizeCornerRadius[screenSize] }
						),
					}),

					FrameShine = props.shineAnimation and e("Frame", {
						Size = UDim2.fromScale(1, 1),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						Visible = props.shineAnimation or false,
					}, {
						UICorner = e(
							"UICorner",
							{ CornerRadius = props.cornerRadius or screenSizeCornerRadius[screenSize] }
						),
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
							Offset = props.shineAnimation and offsetMappedBinding or Vector2.new(-0.6, 0),
						}),
					}),
				}, props.children)
			),
		}
	)
end

return CustomButton
