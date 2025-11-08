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
local UIStroke = require(BaseComponents:WaitForChild("UIStroke"))
local TextLabel = require(BaseComponents:WaitForChild("TextLabel"))

-- GlobalComponents ----------------------------------------------------------------

-- AppComponents -------------------------------------------------------------------

-- LocalComponents -----------------------------------------------------------------

-- Hooks ---------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
local ObjectTypes = require(ReplicatedTypes:WaitForChild("ObjectTypes"))
type Props = {
	object: ObjectTypes.ObjectCopy?,
	equipped: boolean,
	setSelected: (slotNumber: number, objectId: string, state: boolean) -> (),
	LayoutOrder: number,
}

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------
local ObjectsInfo = require(ReplicatedInfo:WaitForChild("ObjectsInfo"))

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------
local keyCodeNumber = {
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
	Enum.KeyCode.Six,
	Enum.KeyCode.Seven,
	Enum.KeyCode.Eight,
	Enum.KeyCode.Nine,
}
local keyCodeKeypad = {
	Enum.KeyCode.KeypadOne,
	Enum.KeyCode.KeypadTwo,
	Enum.KeyCode.KeypadThree,
	Enum.KeyCode.KeypadFour,
	Enum.KeyCode.KeypadFive,
	Enum.KeyCode.KeypadSix,
	Enum.KeyCode.KeypadSeven,
	Enum.KeyCode.KeypadEight,
	Enum.KeyCode.KeypadNine,
}
-- Selectors --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function Slot(props: Props)
	-- SELECTORS/CONTEXTS --------------------------------------------------------------------------------------------

	-- STATES/BINDINGS/REFS/HOOKS ------------------------------------------------------------------------------------------
	local objectInfo, setObjectInfo = React.useState({})

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------

	-- EFFECTS -------------------------------------------------------------------------------------------------------------
	-- Input connection
	React.useEffect(function()
		local connection = UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
			if gameProcessedEvent then
				return
			end

			if
				input.KeyCode == keyCodeNumber[props.LayoutOrder]
				or input.KeyCode == keyCodeKeypad[props.LayoutOrder]
			then
				props.setSelected(props.LayoutOrder, props.object and props.object.id, not props.equipped)
			elseif input.KeyCode == Enum.KeyCode.DPadDown and props.equipped then
				props.setSelected(props.LayoutOrder, props.object and props.object.id, false)
			end
		end)

		setObjectInfo(ObjectsInfo.byKey[props.object and props.object.key] or {})

		return function()
			connection:Disconnect()
		end
	end, { props.object, props.equipped })

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e("ImageButton", {
		BackgroundColor3 = Color3.fromRGB(200, 200, 200),
		BackgroundTransparency = 0.8,
		BorderSizePixel = 0,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromScale(1, 1),
		Image = "",
		[React.Event.Activated] = function()
			props.setSelected(props.LayoutOrder, props.object and props.object.id, not props.equipped)
		end,
	}, {
		UIStrokeEquipped = e(UIStroke, {
			Color = Color3.new(1, 1, 1),
			Thickness = 2,
			Enabled = props.equipped,
		}),

		TextLabelSlotNumber = e(TextLabel, {
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.01, 0),
			Size = UDim2.fromScale(0.2, 0.25),
			Visible = props.onPC,
			Text = tostring(props.LayoutOrder),
		}),

		TextLabelName = e(TextLabel, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.9, 0.25),
			Text = not objectInfo.image and objectInfo.name or "",
			TextScaled = true,
		}),

		ImageLabelIcon = e("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.85, 0.85),
			Image = objectInfo.image or "",
			Visible = objectInfo.image ~= nil,
		}),

		TextLabelQuantity = e(TextLabel, {
			AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.95, 0.99),
			Size = UDim2.fromScale(0.65, 0.3),
			Visible = props.object and props.object.quantity,
			Text = props.object and props.object.quantity or "",
		}),

		FrameDurability = props.object and props.object.durability and e("Frame", {
			BackgroundColor3 = Color3.fromRGB(200, 200, 200),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 1.035),
			Size = UDim2.fromScale(1, 0.1),
		}, {
			FrameGreen = e("Frame", {
				BackgroundColor3 = Color3.fromRGB(85, 170, 0),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(math.clamp(props.object.durability or 0, 0, 1), 1),
			}),
			FrameRed = e("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundColor3 = Color3.fromRGB(170, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromScale(math.clamp(1 - (props.object.durability or 0), 0, 1), 1),
			}),
		}),
	})
end

return Slot
