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
local ReplicatedBaseHandlers = ReplicatedPlaywooEngine:WaitForChild("BaseHandlers")
local ReplicatedGameHandlers = ReplicatedSource:WaitForChild("GameHandlers")

local UI = ReplicatedSource:WaitForChild("UI")
local PlaywooEngineUI = ReplicatedPlaywooEngine:WaitForChild("UI")
local BaseHooks = PlaywooEngineUI:WaitForChild("BaseHooks")
local GlobalComponents = PlaywooEngineUI:WaitForChild("GlobalComponents")
local BaseComponents = PlaywooEngineUI:WaitForChild("BaseComponents")
local AppComponents = UI:WaitForChild("AppComponents")

-- Modules -------------------------------------------------------------------
local React = require(Packages:WaitForChild("React"))
local ReactRedux = require(Packages:WaitForChild("ReactRedux"))
local UIUtils = require(ReplicatedPlaywooEngine:WaitForChild("UIUtils"))
local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))
local Contexts = require(UI:WaitForChild("Contexts"))
local BaseContexts = require(PlaywooEngineUI:WaitForChild("BaseContexts"))

-- Handlers ----------------------------------------------------------------

-- BaseComponents ----------------------------------------------------------------
local UIAspectRatioConstraint = require(BaseComponents:WaitForChild("UIAspectRatioConstraint"))
local UIStroke = require(BaseComponents:WaitForChild("UIStroke"))
local TextLabel = require(BaseComponents:WaitForChild("TextLabel"))

-- GlobalComponents ----------------------------------------------------------------

-- AppComponents -------------------------------------------------------------------

-- LocalComponents -----------------------------------------------------------------

-- Hooks ---------------------------------------------------------------------------
local useMotorMappedBinding = require(BaseHooks:WaitForChild("useMotorMappedBinding"))

-- Types ---------------------------------------------------------------------------
type Props = {}

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------

-- Selectors --------------------------------------------------------------------------
local selector = UIUtils.Selector.Create({
	stamina = { "stamina", "isHoldingSprint" },
	data = { { "stats", "maxStamina" }, { "stats", "staminaConsumptionRate" } },
	window = { "windowShown", "hideHUD" },
})

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function Stamina(props: Props)
	-- SELECTORS/CONTEXTS/HOOKS --------------------------------------------------------------------------------------------
	local storeState = ReactRedux.useSelector(selector)

	-- STATES/BINDINGS/REFS/HOOKS ------------------------------------------------------------------------------------------
	local motorRef =
		React.useRef(UIUtils.Motor.BoomerangMotor.new(1 / (storeState.maxStamina / storeState.staminaConsumptionRate)))

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS -------------------------------------------------------------------------------------------------------------
	local staminaTransparencyBinding = useMotorMappedBinding(motorRef, function(value)
		return Utils.NumberSequence.CooldownSequence(1 - value)
	end, UDim2.fromScale(1, 1), {})

	local staminaColorBinding = useMotorMappedBinding(motorRef, function(value)
		return (1 - value) * 100 > 11 and Utils.Color.Configs.colorSequences.blueStatic
			or Utils.Color.Configs.colorSequences.redStatic
	end, Utils.Color.Configs.colorSequences.blueStatic, { storeState.maxStamina })

	local textStaminaBinding = useMotorMappedBinding(motorRef, function(value)
		return string.format("%d", (1 - value) * storeState.maxStamina)
	end, "100", { storeState.maxStamina })

	-- EFFECTS -------------------------------------------------------------------------------------------------------------
	-- Update motor
	React.useLayoutEffect(function()
		if storeState.windowShown or storeState.hideHUD or not storeState.isHoldingSprint then
			motorRef.current:Stop()
		elseif storeState.isHoldingSprint then
			motorRef.current:Restart(
				true,
				1 - (storeState.stamina / storeState.maxStamina),
				1 / (storeState.maxStamina / storeState.staminaConsumptionRate)
			)
		end
	end, {
		storeState.stamina,
		storeState.isHoldingSprint,
		storeState.maxStamina,
		storeState.staminaConsumptionRate,
		storeState.windowShown,
		storeState.hideHUD,
	})

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = Color3.fromRGB(150, 150, 150),
		BackgroundTransparency = 0.8,
		Position = UDim2.fromScale(0.5, 0.85),
		Size = UDim2.fromScale(0.2, 0.02),
		Visible = not storeState.windowShown and not storeState.hideHUD and storeState.isHoldingSprint,
	}, {
		UIAspectRatioConstraint = e(UIAspectRatioConstraint, {
			size = UDim2.fromScale(0.2, 0.02),
		}),
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0.5, 0),
		}),
		UIStroke = e(UIStroke, {
			Color = Color3.fromRGB(240, 240, 240),
			Thickness = 1.5,
			Transparency = 0.25,
		}),

		FrameProgress = e("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.fromScale(1, 1),
		}, {
			UICorner = e("UICorner", {
				CornerRadius = UDim.new(0.5, 0),
			}),
			UIGradient = e("UIGradient", {
				Color = staminaColorBinding,
				Transparency = staminaTransparencyBinding,
			}),
		}),

		TextLabelStamina = e(TextLabel, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.3, 1),
			Text = textStaminaBinding,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			ZIndex = 2,
			textStrokeThickness = 1,
		}),
	})
end

return Stamina
