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
local ToolHandler = require(ReplicatedGameHandlers:WaitForChild("ToolHandler"))

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
local ObjectsInfo = require(ReplicatedInfo:WaitForChild("ObjectsInfo"))

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------
local mobileActivationIcons = {
	ranged = { "rbxassetid://113494186198554", "rbxassetid://71545011517512" },
	melee = { "rbxassetid://91824541248785", "rbxassetid://113180054276793" },
	consumable = { "rbxassetid://127954810762739", "rbxassetid://122636095014142" },
	axe = { "rbxassetid://140308152792906", "rbxassetid://116854439242419" },
	pickaxe = { "rbxassetid://87220871390329", "rbxassetid://113732588420289" },
}

-- Selectors --------------------------------------------------------------------------
local selector = UIUtils.Selector.Create({
	app = { "deviceType", "totalScreenSize" },
	playerAttributes = { "isAlive" },
})

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function MobileControls(props: Props)
	-- SELECTORS/CONTEXTS/HOOKS --------------------------------------------------------------------------------------------
	local storeState = ReactRedux.useSelector(selector)

	-- STATES/BINDINGS/REFS/HOOKS ------------------------------------------------------------------------------------------
	local activationImageKey, setActivationImageKey = React.useState("consumable")
	local hasToolEquippedBinding, setHasToolEquipped = React.useBinding(false)
	local draggable, setDraggable = React.useState(false)
	local toggleable, setToggleable = React.useState(false)
	local reloadable, setReloadable = React.useState(false)

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------

	-- EFFECTS -------------------------------------------------------------------------------------------------------------
	React.useEffect(function()
		local connection = game.Players.LocalPlayer:GetAttributeChangedSignal("equippedObjectKey"):Connect(function()
			local equippedObjectKey = game.Players.LocalPlayer:GetAttribute("equippedObjectKey")
			if equippedObjectKey then
				local objectInfo = ObjectsInfo.byKey[equippedObjectKey]
				if objectInfo then
					-- Set activation image
					if
						objectInfo.category == "weapon"
						or objectInfo.category == "harvesting"
						or objectInfo.category == "hybrid"
					then
						setDraggable(true)
						setToggleable(objectInfo.attackType == "ranged" or false)
						setReloadable(objectInfo.reloadTime ~= nil)
						if objectInfo.resourceType == "wood" then
							setActivationImageKey("axe")
						elseif objectInfo.resourceType == "ore" then
							setActivationImageKey("pickaxe")
						else
							setActivationImageKey(objectInfo.attackType or "melee")
						end
					else
						setDraggable(false)
						setToggleable(false)
						setReloadable(false)
						setActivationImageKey("consumable")
					end

					if objectInfo.attackType ~= nil then
						setHasToolEquipped(true)
					end
				else
					setHasToolEquipped(false)
				end
			else
				setHasToolEquipped(false)
			end
		end)

		setHasToolEquipped(false)

		return function()
			if connection then
				connection:Disconnect()
			end
		end
	end, {})

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

		-- CrosshairButton = e(ControlHold, {
		-- 	AnchorPoint = Vector2.new(0.5, 0.5),
		-- 	Position = UDim2.fromScale(0.22, 0.22),
		-- 	Size = UDim2.fromScale(0.5, 0.5),
		-- 	Visible = hasToolEquippedBinding,
		-- 	Image = "rbxassetid://95484305126311",
		-- 	onActiveImage = "rbxassetid://78688992914092",
		-- 	onActivation = function() end,
		-- 	onDeactivation = function() end,
		-- 	draggable = true,
		-- }),

		ActivationButton = e(draggable and ControlHold or ControlButton, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.22, 0.22),
			Size = UDim2.fromScale(0.5, 0.5),
			Visible = hasToolEquippedBinding,
			Image = mobileActivationIcons[activationImageKey][1],
			isToggle = toggleable,
			onActiveImage = mobileActivationIcons[activationImageKey][2],
			onActivation = function()
				ToolHandler.Activate()
			end,
			onDeactivation = function()
				ToolHandler.Deactivate()
			end,
			draggable = draggable,
		}),

		ReloadButton = e(ControlButton, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.22, 0.75),
			Size = UDim2.fromScale(0.35, 0.35),
			Visible = reloadable,
			Image = "rbxassetid://85265793481466",
			activated = false, -- Todo: Update to binding
			isToggle = true,
			externalDeactivation = true,
			onActiveImage = "rbxassetid://94491897619211",
			onActivation = function() end,
			onDeactivation = function() end,
		}),
	})
end

return MobileControls
