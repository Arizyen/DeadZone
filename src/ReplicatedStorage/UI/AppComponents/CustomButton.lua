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
local TextLabelAutoSize2 = require(BaseComponents:WaitForChild("TextLabelAutoSize2"))
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

-- Selectors --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function CustomButton(props: Props)
	-- SELECTORS/CONTEXTS -----------------------------------------------------------------------------------------------------------

	-- STATES/REFS/BINDINGS ---------------------------------------------------------------------------------------
	local isHovering, setIsHovering = React.useState(false)

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
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
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
			UICorner = e("UICorner", { CornerRadius = props.cornerRadius or UDim.new(0.1, 0) }),
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
				UICorner = e("UICorner", { CornerRadius = props.cornerRadius or UDim.new(0.1, 0) }),
			}),

			FrameForeground = e(
				"Frame",
				{
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Size = UDim2.new(1, 0, 1, -5),
					ZIndex = 2,
				},
				Utils.Table.Dictionary.merge({
					UICorner = e("UICorner", { CornerRadius = props.cornerRadius or UDim.new(0.1, 0) }),
					UIGradient = e("UIGradient", {
						Color = props.colorSequence or Utils.Color.Configs.colorSequences["green"],
						Rotation = 90,
					}),

					FrameContent = (props.image or props.text) and e("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.85, 1),
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
							ZIndex = 3,
						}),

						TextLabel = props.text and e(TextLabelAutoSize2, {
							LayoutOrder = 2,
							Size = props.textSize or UDim2.fromScale(0.7, 0.85),
							TextColor3 = props.textColor3 or Color3.fromRGB(255, 255, 255),
							FontFace = props.fontFace,
							Text = props.text or "",
							RichText = props.richText or false,
							ZIndex = 3,
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
						BackgroundTransparency = 0.9,
						Visible = isHovering,
						ZIndex = 2,
					}, {
						UICorner = e("UICorner", { CornerRadius = props.cornerRadius or UDim.new(0.1, 0) }),
					}),

					FrameShine = props.shineAnimation and e("Frame", {
						Size = UDim2.fromScale(1, 1),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						Visible = props.shineAnimation or false,
						ZIndex = 0,
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
				}, props.children)
			),
		}
	)
end

return CustomButton
