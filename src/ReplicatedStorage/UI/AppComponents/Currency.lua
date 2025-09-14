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
local BaseComponents = PlaywooEngineUI:WaitForChild("BaseComponents")
local GlobalComponents = PlaywooEngineUI:WaitForChild("GlobalComponents")

-- Modulescripts -------------------------------------------------------------------
local React = require(Packages:WaitForChild("React"))
local ReactRedux = require(Packages:WaitForChild("ReactRedux"))
local UIUtils = require(ReplicatedPlaywooEngine:WaitForChild("UIUtils"))
local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))
local BaseContexts = require(PlaywooEngineUI:WaitForChild("BaseContexts"))
local BaseHooks = PlaywooEngineUI:WaitForChild("BaseHooks")

-- Knit Controllers ----------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- BaseComponents ----------------------------------------------------------------
local TextLabel = require(BaseComponents:WaitForChild("TextLabel"))
local UIStroke = require(BaseComponents:WaitForChild("UIStroke"))
local ImageButton = require(BaseComponents:WaitForChild("ImageButton"))

-- GlobalComponents ----------------------------------------------------------------

-- LocalComponents -----------------------------------------------------------------

-- AppComponents -------------------------------------------------------------------

-- Hooks ---------------------------------------------------------------------------
local useMotorMappedBinding = require(BaseHooks:WaitForChild("useMotorMappedBinding"))

-- Info ---------------------------------------------------------------------------
local ResourcesInfo = require(ReplicatedInfo:WaitForChild("ResourcesInfo"))

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
type CurrencyType = "coins" | "gems" | "revives"
type Props = {
	visible: boolean,
	type: CurrencyType,
	layoutOrder: number,
}

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------

-- Selectors --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function Currency(props: Props)
	-- SELECTORS/CONTEXTS -----------------------------------------------------------------------------------------------------------
	local dispatch = ReactRedux.useDispatch()
	local currencyCount = ReactRedux.useSelector(function(state)
		return state.data[props.type] or 0
	end)

	-- STATES/REFS/BINDINGS ---------------------------------------------------------------------------------------
	local motorRef = React.useRef(UIUtils.Motor.SnapBackMotor.new(4))
	local previousCountRef = React.useRef(currencyCount)

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------
	local resourceInfo = React.useMemo(function()
		return ResourcesInfo.byKey[props.type] or {}
	end, { props.type })

	local positionMappedBinding = useMotorMappedBinding(motorRef, function(value)
		return UDim2.fromScale(
			0.25,
			0.5
				+ (
					0.175
					* math.sin(
						math.pi * 2 * TweenService:GetValue(value, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					)
				)
		)
	end, UDim2.fromScale(0.25, 0.5))

	-- EFFECTS -------------------------------------------------------------------------------------------------------------
	React.useEffect(function()
		if not props.visible then
			return
		end

		if previousCountRef.current == currencyCount then
			return
		end
		previousCountRef.current = currencyCount

		motorRef.current:Restart(true)
	end, { props.visible, currencyCount })

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e("Frame", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.35,
		LayoutOrder = props.layoutOrder,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0.2, 0),
		}),

		-- UIStroke = e(UIStroke, {
		-- 	Thickness = 2,
		-- }),

		ImageButton = e(ImageButton, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.025, 0.5),
			Size = resourceInfo.imageSize or UDim2.fromScale(0.65, 1.6),
			Image = resourceInfo.image,
			smallRatio = 0.95,
			largeRatio = 1.05,
			onClick = function()
				dispatch({
					type = "SetShopCategory",
					value = props.type,
				})
				dispatch({
					type = "ShowWindow",
					value = "Shop",
				})
			end,
		}),

		TextLabelValue = e(TextLabel, {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = positionMappedBinding,
			Size = UDim2.fromScale(0.5, 1),
			Text = Utils.Number.ToEnglish(currencyCount),
			TextColor3 = resourceInfo.colorSequence and Color3.fromRGB(255, 255, 255) or resourceInfo.color,
			TextStrokeTransparency = 0.5,
		}, {
			UIStroke = e(UIStroke, {
				Thickness = 2,
				textStroke = true,
			}),
			UIGradient = resourceInfo.colorSequence and e("UIGradient", {
				Color = resourceInfo.colorSequence,
				Rotation = 90,
			}),
		}),

		ImageButtonPlus = e(ImageButton, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.875, 0.5),
			Size = UDim2.fromScale(0.3, 1),
			Image = "rbxassetid://13770909236",
			ImageColor3 = resourceInfo.color,
			onClick = function()
				dispatch({
					type = "SetShopCategory",
					value = props.type,
				})
				dispatch({
					type = "ShowWindow",
					value = "Shop",
				})
			end,
		}),
	})
end

return Currency
