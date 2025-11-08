-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

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
local ObjectsInfo = require(ReplicatedInfo:WaitForChild("ObjectsInfo"))

-- Configs -------------------------------------------------------------------------
local HAIR_WIDTH = 8
local HAIR_HEIGHT = 2
local HAIR_LONG_WIDTH = 14
local HAIR_LONG_HEIGHT = 2

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
	local weaponEquipped, setWeaponEquipped = React.useState(false)
	local hairLongColor, setHairLongColor = React.useState(Color3.new(1, 1, 1))

	local positionBinding, setPositionBinding = React.useBinding(UDim2.fromScale(0.5, 0.5))

	local longHairMotorRef = React.useRef(UIUtils.Motor.BoomerangMotor.new(1 / 0.1))
	local hairMotorRef = React.useRef(UIUtils.Motor.BoomerangMotor.new(1 / 0.07))

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------
	local mappedLongHairTransparency = useMotorMappedBinding(longHairMotorRef, function(value)
		return 1 - value
	end, 1, { longHairMotorRef.current })

	local hairs = React.useMemo(function()
		local hairWidth = storeState.isOnSmallScreen and HAIR_WIDTH * 1.25 or HAIR_WIDTH
		local hairHeight = storeState.isOnSmallScreen and HAIR_HEIGHT * 1.25 or HAIR_HEIGHT

		return {
			-- Right Hair
			Hair1 = e(Hair, {
				motorRef = hairMotorRef,
				endPosition = UDim2.new(0.5, hairWidth * 1.5, 0.5, 0),
				Position = UDim2.new(0.5, hairWidth, 0.5, 0),
				Size = UDim2.new(0, hairWidth, 0, hairHeight),
				Visible = weaponEquipped and not storeState.windowShown,
			}),

			-- Bottom hair
			Hair2 = e(Hair, {
				motorRef = hairMotorRef,
				endPosition = UDim2.new(0.5, 0, 0.5, hairWidth * 1.5),
				Position = UDim2.new(0.5, 0, 0.5, hairWidth),
				Size = UDim2.new(0, hairHeight, 0, hairWidth),
				Visible = weaponEquipped and not storeState.windowShown,
			}),

			-- Left hair
			Hair3 = e(Hair, {
				motorRef = hairMotorRef,
				endPosition = UDim2.new(0.5, -hairWidth * 1.5, 0.5, 0),
				Position = UDim2.new(0.5, -hairWidth, 0.5, 0),
				Size = UDim2.new(0, hairWidth, 0, hairHeight),
				Visible = weaponEquipped and not storeState.windowShown,
			}),

			-- Top hair
			Hair4 = e(Hair, {
				motorRef = hairMotorRef,
				endPosition = UDim2.new(0.5, 0, 0.5, -hairWidth * 1.5),
				Position = UDim2.new(0.5, 0, 0.5, -hairWidth),
				Size = UDim2.new(0, hairHeight, 0, hairWidth),
				Visible = weaponEquipped and not storeState.windowShown,
			}),
		}
	end, { storeState.windowShown, storeState.isOnSmallScreen, weaponEquipped })

	local hairsLong = React.useMemo(function()
		local hairWidth = storeState.isOnSmallScreen and HAIR_WIDTH * 1.25 or HAIR_WIDTH
		local hairLongWidth = storeState.isOnSmallScreen and HAIR_LONG_WIDTH * 1.25 or HAIR_LONG_WIDTH
		local hairLongHeight = storeState.isOnSmallScreen and HAIR_LONG_HEIGHT * 1.25 or HAIR_LONG_HEIGHT

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
				Visible = weaponEquipped and not storeState.windowShown,
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
				Visible = weaponEquipped and not storeState.windowShown,
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
				Visible = weaponEquipped and not storeState.windowShown,
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
				Visible = weaponEquipped and not storeState.windowShown,
			}),
		}
	end, { storeState.windowShown, storeState.isOnSmallScreen, weaponEquipped, hairLongColor })

	-- EFFECTS -------------------------------------------------------------------------------------------------------------

	-- Crosshair visibility
	React.useEffect(function()
		local connection = localPlayer:GetAttributeChangedSignal("equippedObjectKey"):Connect(function()
			local objectInfo = ObjectsInfo.byKey[localPlayer:GetAttribute("equippedObjectKey")]
			if objectInfo and objectInfo.attackType ~= nil then
				setWeaponEquipped(true)
			else
				setWeaponEquipped(false)
			end
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	-- Motor management
	React.useEffect(function()
		local connectionActivated = Utils.Signals.Connect("ToolActivated", function()
			hairMotorRef.current:Restart(true, hairMotorRef.current:GetValue())
		end)

		local connectionHit = Utils.Signals.Connect("ToolHit", function()
			setHairLongColor(Color3.new(1, 1, 1))
			longHairMotorRef.current:Restart(true, longHairMotorRef.current:GetValue())
		end)

		local connectionKill = Utils.Signals.Connect("ToolKill", function()
			setHairLongColor(Color3.new(1, 0, 0))
			longHairMotorRef.current:Restart(true, longHairMotorRef.current:GetValue())
		end)

		return function()
			connectionActivated:Disconnect()
			connectionHit:Disconnect()
			connectionKill:Disconnect()
		end
	end, {})

	-- Mouse position tracking
	React.useEffect(function()
		local connectionsManager = Utils.ConnectionsManager.new()

		local function ActivateMouseTracking()
			connectionsManager:Add(
				"MouseTracking",
				UserInputService.InputChanged:Connect(function(input: InputObject)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						local mouseLocation = UserInputService:GetMouseLocation()
						setPositionBinding(UDim2.fromOffset(mouseLocation.X, mouseLocation.Y))

						-- setPositionBinding(UDim2.fromOffset(input.Position.X, input.Position.Y)) -- Ignores GUI inset
					end
				end)
			)

			-- Initial update
			local mouseLocation = UserInputService:GetMouseLocation()
			setPositionBinding(UDim2.fromOffset(mouseLocation.X, mouseLocation.Y))
		end

		local function DeactivateMouseTracking()
			connectionsManager:Disconnect("MouseTracking")
			setPositionBinding(UDim2.fromScale(0.5, 0.5))
		end

		local function Update()
			local equippedObjectId = localPlayer:GetAttribute("equippedObjectId")
			local shiftLockDisabled = localPlayer:GetAttribute("shiftLockDisabled") or false

			if equippedObjectId and shiftLockDisabled then
				ActivateMouseTracking()
			else
				DeactivateMouseTracking()
			end
		end

		connectionsManager:Add(
			"toolEquippedChanged",
			localPlayer:GetAttributeChangedSignal("equippedObjectId"):Connect(Update)
		)
		connectionsManager:Add(
			"shiftLockDisabledChanged",
			localPlayer:GetAttributeChangedSignal("shiftLockDisabled"):Connect(Update)
		)

		return function()
			connectionsManager:Destroy()
		end
	end, {})

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = positionBinding,
		Size = UDim2.fromScale(1, 1),
	}, e(React.Fragment, nil, hairs, hairsLong))
end

return Crosshair
