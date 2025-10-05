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
local PlayerHandler = require(ReplicatedGameHandlers:WaitForChild("PlayerHandler"))

-- BaseComponents ----------------------------------------------------------------

-- GlobalComponents ----------------------------------------------------------------

-- AppComponents -------------------------------------------------------------------

-- LocalComponents -----------------------------------------------------------------
local ControlHold = require(script:WaitForChild("ControlHold"))
local ControlButton = require(script:WaitForChild("ControlButton"))

-- Hooks ---------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
type Props = {}

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------
local WeaponsInfo = require(ReplicatedInfo:WaitForChild("WeaponsInfo"))

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------

-- Selectors --------------------------------------------------------------------------
local selector = UIUtils.Selector.Create({
	app = { "deviceType" },
	theme = { "totalScreenSize" },
	playerAttributes = { "isAlive" },
	data = { { "loadout", "equippedTool" } },
})
------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function MobileControls(props: Props)
	-- SELECTORS/CONTEXTS/HOOKS --------------------------------------------------------------------------------------------
	local storeState = ReactRedux.useSelector(selector)

	-- STATES/BINDINGS/REFS/HOOKS ------------------------------------------------------------------------------------------
	local hasWeaponEquippedBinding, setHasWeaponEquipped = React.useBinding(false)

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------

	-- EFFECTS -------------------------------------------------------------------------------------------------------------
	React.useEffect(function()
		if storeState.equippedTool then
			local tool = storeState.equippedTool

			if tool.category == "Weapon" then
				local weaponInfo = WeaponsInfo.byKey[tool.key]
				if weaponInfo and weaponInfo.class.ranged then
					setHasWeaponEquipped(true)
					return
				end
			end
		end

		setHasWeaponEquipped(false)
	end, { storeState.equippedTool })

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = storeState.totalScreenSize >= 1350 and UDim2.new(1, -170, 1, -210) or UDim2.new(1, -95, 1, -90),
		Size = storeState.totalScreenSize >= 1350 and UDim2.fromOffset(240, 240) or UDim2.fromOffset(140, 140),
		Visible = storeState.isAlive and storeState.deviceType == "mobile",
	}, {
		UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = 1,
		}),

		SprintButton = e(ControlButton, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.75, 0.22),
			Size = UDim2.fromScale(0.5, 0.5),
			Visible = true,
			Image = "rbxassetid://73877726555771",
			isToggle = true,
			onActiveImage = "rbxassetid://72404599210474",
			onActivation = function()
				PlayerHandler.HoldSprint(true)
			end,
			onDeactivation = function()
				PlayerHandler.HoldSprint(false)
			end,
		}),

		AimButton = e(ControlHold, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.22, 0.22),
			Size = UDim2.fromScale(0.5, 0.5),
			Visible = hasWeaponEquippedBinding,
			Image = "rbxassetid://95484305126311",
			onActiveImage = "rbxassetid://78688992914092",
			onActivation = function() end,
			onDeactivation = function() end,
			draggable = true,
		}),

		ReloadButton = e(ControlButton, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.22, 0.75),
			Size = UDim2.fromScale(0.35, 0.35),
			Visible = hasWeaponEquippedBinding,
			Image = "rbxassetid://85265793481466",
			onActiveImage = "rbxassetid://94491897619211",
			onActivation = function() end,
			onDeactivation = function() end,
			draggable = true,
		}),
	})
end

return MobileControls
