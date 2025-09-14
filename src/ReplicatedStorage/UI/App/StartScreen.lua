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
local GameHandlers = ReplicatedSource:WaitForChild("GameHandlers")

local UI = ReplicatedSource:WaitForChild("UI")
local PlaywooEngineUI = ReplicatedPlaywooEngine:WaitForChild("UI")
local GlobalComponents = PlaywooEngineUI:WaitForChild("GlobalComponents")
local BaseComponents = PlaywooEngineUI:WaitForChild("BaseComponents")
local AppComponents = UI:WaitForChild("AppComponents")
local BaseHooks = PlaywooEngineUI:WaitForChild("BaseHooks")

-- Modulescripts -------------------------------------------------------------------
local React = require(Packages:WaitForChild("React"))
local ReactRedux = require(Packages:WaitForChild("ReactRedux"))
local UIUtils = require(ReplicatedPlaywooEngine:WaitForChild("UIUtils"))
local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))
local Contexts = require(UI:WaitForChild("Contexts"))
local BaseContexts = require(PlaywooEngineUI:WaitForChild("BaseContexts"))
local CameraManager = require(ReplicatedBaseModules:WaitForChild("CameraManager"))
local GameConfigs = require(ReplicatedConfigs:WaitForChild("GameConfigs"))

-- Handlers ----------------------------------------------------------------
local PlayerHandler = require(GameHandlers:WaitForChild("PlayerHandler"))

-- Instances -----------------------------------------------------------------------

-- BaseComponents ----------------------------------------------------------------

-- GlobalComponents ----------------------------------------------------------------

-- LocalComponents -----------------------------------------------------------------

-- AppComponents -------------------------------------------------------------------
local CustomButton = require(AppComponents:WaitForChild("CustomButton"))

-- Hooks ---------------------------------------------------------------------------
local useMotorMappedBinding = require(BaseHooks:WaitForChild("useMotorMappedBinding"))

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local WINDOW_NAME = "StartScreen"

-- Types ---------------------------------------------------------------------------
type Props = {}

-- Variables -----------------------------------------------------------------------
local e = React.createElement
local canRunCinematic = true

-- Tables --------------------------------------------------------------------------
local windowsWithCameraAnimation = {
	StartScreen = true,
	ChooseServer = true,
	Teleporting = true,
	Tutorial = true,
}

-- Selectors --------------------------------------------------------------------------
local selector = UIUtils.Selector.Create({
	window = { "windowShown" },
	data = { "newPlayer", "savedGameMode" },
})

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function StartScreen(props: Props)
	local dispatch = ReactRedux.useDispatch()

	-- SELECTORS/CONTEXTS -----------------------------------------------------------------------------------------------------------
	local storeState = ReactRedux.useSelector(selector)

	local motorRef = React.useRef(UIUtils.Motor.OscillatingMotor.new(1 / 1.5))

	-- STATES/REFS/BINDINGS ---------------------------------------------------------------------------------------

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------
	local sizeMappedBinding = useMotorMappedBinding(motorRef, function(value)
		return UDim2.fromScale(0.7, 0.5):Lerp(
			UDim2.fromScale(0.7, 0.6),
			TweenService:GetValue(value, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		)
	end, UDim2.fromScale(0.7, 0.5))

	-- EFFECTS -------------------------------------------------------------------------------------------------------------
	-- Cleanup
	React.useEffect(function()
		return function()
			motorRef.current:Destroy()
		end
	end, {})

	-- Window shown changed
	React.useEffect(function()
		if storeState.windowShown == WINDOW_NAME then
			canRunCinematic = true
			-- task.spawn(RunCinematic)
			motorRef.current:Start()
		elseif storeState.windowShown ~= WINDOW_NAME then
			canRunCinematic = false
			motorRef.current:Stop()
		end

		if not windowsWithCameraAnimation[storeState.windowShown] then
			CameraManager.DisconnectConnections()
		end
	end, { storeState.windowShown })

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = storeState.windowShown == WINDOW_NAME,
		ZIndex = 2,
	}, {
		ImageLabelLogo = e("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.35),
			Size = sizeMappedBinding,
			Image = "rbxassetid://117041876607097",
			ScaleType = Enum.ScaleType.Fit,
		}),
		FrameButton1 = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.69),
			Size = UDim2.fromScale(0.45, 0.135),
		}, {
			UIListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0.02, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			TextButtonPlay = e(CustomButton, {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.fromScale(0.485, 1),
				Visible = storeState.windowShown == WINDOW_NAME,
				LayoutOrder = 1,
				text = "Play",
				onClick = function()
					--TODO Implement logic
					PlayerHandler.Spawn():andThen(function(success)
						if success then
							UIUtils.Window.Close(WINDOW_NAME)
						end
					end)
				end,
				shineAnimation = true,
				colorSequence = Utils.Color.Configs.colorSequences["green"],
				smallRatio = 0.97,
				largeRatio = 1.03,
			}),
		}),
	})
end

return StartScreen
