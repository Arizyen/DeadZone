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

-- GlobalComponents ----------------------------------------------------------------

-- AppComponents -------------------------------------------------------------------

-- LocalComponents -----------------------------------------------------------------
local Hair = require(script:WaitForChild("Hair"))

-- Hooks ---------------------------------------------------------------------------
local useMotorMappedBinding = require(BaseHooks:WaitForChild("useMotorMappedBinding"))

-- Types ---------------------------------------------------------------------------
type Props = {}

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local HAIR_WIDTH = 14
local HAIR_HEIGHT = 4
local HAIR_LONG_WIDTH = 24
local HAIR_LONG_HEIGHT = 4

-- Variables -----------------------------------------------------------------------
local e = React.createElement
local localPlayer = game.Players.LocalPlayer

-- Tables --------------------------------------------------------------------------

-- Selectors --------------------------------------------------------------------------
local selector = UIUtils.Selector.Create({
	window = { "windowShown" },
	theme = { "isOnSmallScreen" },
})

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function Crosshair(props: Props)
	-- SELECTORS/CONTEXTS --------------------------------------------------------------------------------------------
	local storeState = ReactRedux.useSelector(selector)

	-- STATES/BINDINGS/REFS/HOOKS ------------------------------------------------------------------------------------------
	local toolEquipped, setToolEquipped = React.useState(localPlayer:GetAttribute("toolEquipped") or false)
	local hairLongColor, setHairLongColor = React.useState(Color3.new(1, 1, 1))

	local motorRef = React.useRef(UIUtils.Motor.BoomerangMotor.new(1 / 0.1))

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------
	local mappedLongHairTransparency = useMotorMappedBinding(motorRef, function(value)
		return 1 - value
	end, 1, { motorRef.current })

	local hairs = React.useMemo(function()
		local hairWidth = storeState.isOnSmallScreen and HAIR_WIDTH * 0.5 or HAIR_WIDTH
		local hairHeight = storeState.isOnSmallScreen and HAIR_HEIGHT * 0.5 or HAIR_HEIGHT

		return {
			-- Right Hair
			Hair1 = e(Hair, {
				motorRef = motorRef,
				endPosition = UDim2.new(0.5, hairWidth * 1.5, 0.5, 0),
				Position = UDim2.new(0.5, hairWidth, 0.5, 0),
				Size = UDim2.new(0, hairWidth, 0, hairHeight),
				Visible = toolEquipped and not storeState.windowShown,
			}),

			-- Bottom hair
			Hair2 = e(Hair, {
				motorRef = motorRef,
				endPosition = UDim2.new(0.5, 0, 0.5, hairWidth * 1.5),
				Position = UDim2.new(0.5, 0, 0.5, hairWidth),
				Size = UDim2.new(0, hairHeight, 0, hairWidth),
				Visible = toolEquipped and not storeState.windowShown,
			}),

			-- Left hair
			Hair3 = e(Hair, {
				motorRef = motorRef,
				endPosition = UDim2.new(0.5, -hairWidth * 1.5, 0.5, 0),
				Position = UDim2.new(0.5, -hairWidth, 0.5, 0),
				Size = UDim2.new(0, hairWidth, 0, hairHeight),
				Visible = toolEquipped and not storeState.windowShown,
			}),

			-- Top hair
			Hair4 = e(Hair, {
				motorRef = motorRef,
				endPosition = UDim2.new(0.5, 0, 0.5, -hairWidth * 1.5),
				Position = UDim2.new(0.5, 0, 0.5, -hairWidth),
				Size = UDim2.new(0, hairHeight, 0, hairWidth),
				Visible = toolEquipped and not storeState.windowShown,
			}),
		}
	end, { storeState.windowShown, storeState.isOnSmallScreen, toolEquipped })

	local hairsLong = React.useMemo(function()
		local hairWidth = storeState.isOnSmallScreen and HAIR_WIDTH * 0.5 or HAIR_WIDTH
		local hairLongWidth = storeState.isOnSmallScreen and HAIR_LONG_WIDTH * 0.5 or HAIR_LONG_WIDTH
		local hairLongHeight = storeState.isOnSmallScreen and HAIR_LONG_HEIGHT * 0.5 or HAIR_LONG_HEIGHT

		return {
			-- Top right
			HairLong1 = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = hairLongColor,
				BackgroundTransparency = mappedLongHairTransparency,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, hairWidth, 0.5, -hairWidth),
				Rotation = -45,
				Size = UDim2.new(0, hairLongWidth, 0, hairLongHeight),
				Visible = toolEquipped and not storeState.windowShown,
			}),

			-- Bottom right
			HairLong2 = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = hairLongColor,
				BackgroundTransparency = mappedLongHairTransparency,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, hairWidth, 0.5, hairWidth),
				Rotation = 45,
				Size = UDim2.new(0, hairLongWidth, 0, hairLongHeight),
				Visible = toolEquipped and not storeState.windowShown,
			}),

			-- Bottom left
			HairLong3 = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = hairLongColor,
				BackgroundTransparency = mappedLongHairTransparency,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, -hairWidth, 0.5, hairWidth),
				Rotation = -45,
				Size = UDim2.new(0, hairLongWidth, 0, hairLongHeight),
				Visible = toolEquipped and not storeState.windowShown,
			}),

			-- Top left
			HairLong4 = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = hairLongColor,
				BackgroundTransparency = mappedLongHairTransparency,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, -hairWidth, 0.5, -hairWidth),
				Rotation = 45,
				Size = UDim2.new(0, hairLongWidth, 0, hairLongHeight),
				Visible = toolEquipped and not storeState.windowShown,
			}),
		}
	end, { storeState.windowShown, storeState.isOnSmallScreen, toolEquipped, hairLongColor })

	-- EFFECTS -------------------------------------------------------------------------------------------------------------

	-- Crosshair visibility
	React.useEffect(function()
		local connection = localPlayer:GetAttributeChangedSignal("toolEquipped"):Connect(function()
			setToolEquipped(localPlayer:GetAttribute("toolEquipped") or false)
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	-- Motor management
	React.useEffect(function()
		local connectionHit = localPlayer:GetAttributeChangedSignal("hit"):Connect(function()
			local hit = localPlayer:GetAttribute("hit")
			if hit then
				setHairLongColor(Color3.new(1, 1, 1))
				motorRef.current:Restart(true, motorRef.current:GetValue())
			end
		end)

		local connectionKill = localPlayer:GetAttributeChangedSignal("kill"):Connect(function()
			local kill = localPlayer:GetAttribute("kill")
			if kill then
				setHairLongColor(Color3.new(1, 0, 0))
				motorRef.current:Restart(true, motorRef.current:GetValue())
			end
		end)

		return function()
			connectionHit:Disconnect()
			connectionKill:Disconnect()
		end
	end, {})

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e(React.Fragment, nil, hairs, hairsLong)
end

return Crosshair
