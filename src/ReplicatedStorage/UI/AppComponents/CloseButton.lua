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
local CustomButton = require(AppComponents:WaitForChild("CustomButton"))

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
	onCloseCustom: (() -> nil)?,
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
	return e(CustomButton, {
		Size = props.Size,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		ZIndex = props.ZIndex,
		FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),
		Text = "X",
		aspectRatio = 1,
		textSize = UDim2.fromScale(1, 1),
		colorSequence = Utils.Color.Configs.colorSequences.red,
		onClick = function()
			if props.onCloseCustom then
				props.onCloseCustom()
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
	})
end

return CloseButton
