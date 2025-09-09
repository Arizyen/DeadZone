-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
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

-- GlobalComponents ----------------------------------------------------------------

-- AppComponents -------------------------------------------------------------------

-- LocalComponents -----------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
type Props = {
	Size: UDim2,
	windowName: string,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	ZIndex: number?,
	onClose: (() -> nil)?,
	customOnClose: (() -> nil)?,
	largeRatio: number?,
	smallRatio: number?,
}

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------

-- Selectors --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function CloseButton(props: Props)
	-- SELECTORS/CONTEXTS -----------------------------------------------------------------------------------------------------------
	local dispatch = ReactRedux.useDispatch()

	-- STATES/REFS/BINDINGS ---------------------------------------------------------------------------------------
	local clicked = React.useRef(false)
	local buttonRef = React.useRef()

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------

	-- EFFECTS -------------------------------------------------------------------------------------------------------------
	local backgroundColor, setBackgroundColor = React.useState(Color3.fromRGB(255, 0, 0))

	local closeMotor, closeMotorBinding = React.useMemo(function()
		return UIUtils.Flipper.CreateMotor(0.5)
	end, {})

	-- Unmount effect
	React.useEffect(function()
		if buttonRef.current then
			CollectionService:AddTag(buttonRef.current, "Button")
		end

		return function()
			closeMotor:destroy()
		end
	end, {})

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e(
		"TextButton",
		Utils.Table.Dictionary.mergeInstanceProps({
			AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
			Position = props.Position or UDim2.fromScale(0.98, 0),
			Size = closeMotorBinding:map(function(value)
				if value > 0.5 then
					return props.Size:Lerp(
						UDim2.fromScale(
							props.Size.X.Scale * (props.largeRatio or 1.1),
							props.Size.Y.Scale * (props.largeRatio or 1.1)
						),
						TweenService:GetValue((value / 0.5) - 1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
					)
				elseif value < 0.5 then
					if clicked.current then
						return UDim2.fromScale(
							props.Size.X.Scale * (props.smallRatio or 0.9),
							props.Size.Y.Scale * (props.smallRatio or 0.9)
						):Lerp(
							props.Size,
							TweenService:GetValue((value / 0.5), Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
						)
					else
						return UDim2.fromScale(
							props.Size.X.Scale * (props.smallRatio or 0.9),
							props.Size.Y.Scale * (props.smallRatio or 0.9)
						):Lerp(
							props.Size,
							TweenService:GetValue((value / 0.5), Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
						)
					end
				else
					return props.Size
				end
			end),
			BackgroundColor3 = backgroundColor,
			AutoButtonColor = false,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Text = "",
			ref = buttonRef,
			[React.Event.MouseEnter] = function()
				-- setBackgroundColor(Color3.fromRGB(125, 0, 0))
				closeMotor:setGoal(Flipper.Linear.new(1, { velocity = 1 / 0.25 }))
			end,
			[React.Event.MouseLeave] = function()
				-- setBackgroundColor(Color3.fromRGB(150, 0, 0))
				closeMotor:setGoal(Flipper.Linear.new(0.5, { velocity = 1 / 0.25 }))
			end,
			[React.Event.MouseButton1Down] = function()
				-- setBackgroundColor(Color3.fromRGB(175, 0, 0))
				clicked.current = true
				closeMotor:setGoal(Flipper.Instant.new(0))
			end,
			[React.Event.Activated] = function()
				-- setBackgroundColor(Color3.fromRGB(150, 0, 0))
				clicked.current = false
				closeMotor:setGoal(Flipper.Linear.new(0.5, { velocity = 1 / 0.4 }))

				if props.customOnClose then
					props.customOnClose()
				elseif props.windowName then
					dispatch({
						type = "CloseWindow",
						value = props.windowName,
					})
					dispatch({
						type = "SetWindowOverlayPosition",
						windowName = props.windowName,
						position = nil,
					})

					if props.onClose then
						props.onClose()
					end
				elseif props.onClose then
					props.onClose()
				end
			end,
			ZIndex = props.ZIndex or 2,
		}, props),
		{
			UICorner = e("UICorner", { CornerRadius = UDim.new(1, 0) }),
			UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
				AspectRatio = 1,
			}),
			UIStroke = e(UIStroke, {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = 3,
			}),
			UIGradient = e("UIGradient", {
				Color = Utils.Color.Configs.colorSequences["red"],
				Rotation = 90,
			}),
			-- TextLabel = e("TextLabel", {
			-- 	AnchorPoint = Vector2.new(0.5, 0.5),
			-- 	Position = UDim2.fromScale(0.5, 0.5),
			-- 	Size = UDim2.fromScale(0.85, 0.85),
			-- 	BackgroundTransparency = 1,
			-- 	BorderSizePixel = 0,
			-- 	Font = Enum.Font.FredokaOne,
			-- 	Text = "X",
			-- 	TextColor3 = Color3.fromRGB(255, 255, 255),
			-- 	TextScaled = true,
			-- 	TextStrokeTransparency = 0,
			-- 	ZIndex = 4,
			-- }),
			ImageLabel = e("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.65, 0.65),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = "rbxassetid://71189948716406",
				ZIndex = 4,
				ScaleType = Enum.ScaleType.Fit,
			}),
		}
	)
end

return CloseButton
