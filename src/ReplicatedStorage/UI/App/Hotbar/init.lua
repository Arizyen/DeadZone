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
local ToolHandler = require(ReplicatedGameHandlers:WaitForChild("ToolHandler"))

-- BaseComponents ----------------------------------------------------------------

-- GlobalComponents ----------------------------------------------------------------

-- AppComponents -------------------------------------------------------------------

-- LocalComponents -----------------------------------------------------------------
local Slot = require(script:WaitForChild("Slot"))

-- Hooks ---------------------------------------------------------------------------
local usePrevious = require(BaseHooks:WaitForChild("usePrevious"))

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
	data = { { "stats", "hotbarSlots" }, "hotbar", "objects", { "loadout", "equippedObjectId" } },
	window = { "windowShown", "hideHUD" },
	app = { "deviceType" },
})

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function Hotbar(props: Props)
	-- SELECTORS/CONTEXTS --------------------------------------------------------------------------------------------
	local storeState = ReactRedux.useSelector(selector)

	-- STATES/BINDINGS/REFS/HOOKS ------------------------------------------------------------------------------------------
	local selectedSlotNumber, setSelectedSlotNumber = React.useState(0)

	local prevEquippedObjectId = usePrevious(storeState.equippedObjectId)

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------
	local setSelected = React.useCallback(function(slotNumber: number, objectId: string, state: boolean)
		if state then
			ToolHandler.Equip(objectId)
		else
			ToolHandler.Unequip()
		end

		setSelectedSlotNumber(state and slotNumber or 0)
	end, {})

	-- MEMOS ---------------------------------------------------------------------------------------------------------------
	local slots = React.useMemo(function()
		local slots = {}
		for i = 1, storeState.hotbarSlots do
			local objectId = storeState.hotbar["slot" .. i]

			slots["slot" .. i] = e(Slot, {
				object = storeState.objects[objectId],
				equipped = (
					storeState.equippedObjectId == objectId
					and (selectedSlotNumber == nil or selectedSlotNumber == i)
				) or selectedSlotNumber == i,
				setSelected = setSelected,
				LayoutOrder = i,
			})
		end
		return slots
	end, {
		storeState.hotbarSlots,
		storeState.hotbar,
		storeState.objects,
		storeState.equippedObjectId,
		selectedSlotNumber,
	})

	-- EFFECTS -------------------------------------------------------------------------------------------------------------
	-- On equipped object change, reset selected slot
	React.useEffect(function()
		if prevEquippedObjectId ~= storeState.equippedObjectId then
			setSelectedSlotNumber(0)
		end
	end, { storeState.equippedObjectId })

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.99),
			Size = UDim2.fromScale(0.05, 0.09),
			Visible = not storeState.windowShown and not storeState.hideHUD,
		},
		e(React.Fragment, nil, slots, {
			UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
				AspectRatio = 1,
			}),
			UIListLayout = e("UIListLayout", {
				Padding = UDim.new(0.065, 0),
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
		})
	)
end

return Hotbar
