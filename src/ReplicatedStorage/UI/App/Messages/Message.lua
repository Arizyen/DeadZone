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

-- Instances -----------------------------------------------------------------------

-- BaseComponents ----------------------------------------------------------------
local TextLabel = require(BaseComponents:WaitForChild("TextLabel"))
local UIStroke = require(BaseComponents:WaitForChild("UIStroke"))

-- GlobalComponents ----------------------------------------------------------------

-- AppComponents -------------------------------------------------------------------

-- LocalComponents -----------------------------------------------------------------

-- Hooks ---------------------------------------------------------------------------
local usePrevious = require(BaseHooks:WaitForChild("usePrevious"))
local useMotorMappedBinding = require(BaseHooks:WaitForChild("useMotorMappedBinding"))

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
local MessageTypes = require(ReplicatedTypes:WaitForChild("MessageTypes"))
type Props = { LayoutOrder: number, message: MessageTypes.Message }

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------

-- Selectors --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function Message(props: Props)
	local dispatch = ReactRedux.useDispatch()

	-- SELECTORS/CONTEXTS/HOOKS --------------------------------------------------------------------------------------------

	-- STATES/REFS/BINDINGS/HOOKS ------------------------------------------------------------------------------------------
	local prevCount = usePrevious(props.message.count, props.message.count)
	local initMotorRef = React.useRef(UIUtils.Motor.SimpleMotor.new(3.5))
	local textBounceMotorRef = React.useRef(UIUtils.Motor.SnapBackMotor.new(4))
	local timerScheduleRef = React.useRef()

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------
	local function cancelTimer()
		if timerScheduleRef.current then
			timerScheduleRef.current:Disconnect()
			timerScheduleRef.current = nil
		end
	end

	local function setTimer()
		cancelTimer()
		timerScheduleRef.current = Utils.Scheduler.Add(props.message.props.duration, function()
			dispatch({
				type = "RemoveMessage",
				value = props.message.id,
			})
		end)
	end

	-- MEMOS ---------------------------------------------------------------------------------------------------------------
	local sizeMappedBinding = useMotorMappedBinding(initMotorRef, function(value: number)
		return UDim2.fromScale(1, 0):Lerp(
			UDim2.fromScale(1, 1),
			TweenService:GetValue(value, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		)
	end)
	local textPositionMappedBinding = useMotorMappedBinding(textBounceMotorRef, function(value: number)
		return UDim2.fromScale(0, 0.5 + (math.sin(math.pi * 2 * value) * 0.05))
	end)

	-- EFFECTS -------------------------------------------------------------------------------------------------------------

	-- Register events to motors
	React.useLayoutEffect(function()
		initMotorRef.current:SetEvents({
			onReachedEndValue = function()
				setTimer()
			end,
		})
	end, {})

	-- On mount
	React.useEffect(function()
		-- Start initial animation
		initMotorRef.current:Start()

		return function()
			-- Cleanup timer
			cancelTimer()

			-- Cleanup motors
			initMotorRef.current:Destroy()
			textBounceMotorRef.current:Destroy()
		end
	end, {})

	-- On message changed
	React.useEffect(function()
		-- Play sound
		if props.message.props.soundInfoKey then
			local soundInfo = Utils.Sound.Info.byKey[props.message.props.soundInfoKey]
			if soundInfo then
				Utils.Sound.Play(soundInfo)
			end
		end

		-- Detect if new message
		if prevCount ~= props.message.count then
			-- Same message, count increased
			setTimer()
			textBounceMotorRef.current:Restart(true)
		end
	end, { props.message })

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Size = sizeMappedBinding,
	}, {
		TextLabel = e(
			TextLabel,
			Utils.Table.Dictionary.mergeInstanceProps({
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = textPositionMappedBinding,
				Size = UDim2.fromScale(1, 1),
				Text = if props.message.count > 1
					then props.message.message .. " (x" .. tostring(props.message.count) .. ")"
					else props.message.message,
				TextColor3 = Color3.fromRGB(255, 255, 255),
			}, props.message.props),
			{
				UIStroke = e(UIStroke, {
					textStroke = true,
					Thickness = props.message.props.strokeThickness or 2.5,
				}),
			}
		),
	})
end

return Message
