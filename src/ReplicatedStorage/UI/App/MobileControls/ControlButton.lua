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

-- Hooks ---------------------------------------------------------------------------
local usePreloadAssets = require(BaseHooks:WaitForChild("usePreloadAssets"))
local usePrevious = require(BaseHooks:WaitForChild("usePrevious"))

-- Types ---------------------------------------------------------------------------
type Props = {
	isToggle: boolean?,
	activated: boolean?,
	externalDeactivation: boolean?,
	onActiveImage: string?,
	onActivation: (() -> ())?,
	onDeactivation: (() -> ())?,
}

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------

-- Selectors --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function ControlButton(props: Props)
	-- SELECTORS/CONTEXTS/HOOKS --------------------------------------------------------------------------------------------

	-- STATES/BINDINGS/REFS/HOOKS ------------------------------------------------------------------------------------------
	local isActive, setIsActive = React.useState(false)

	local prevActivated = usePrevious(props.activated)
	usePreloadAssets({ props.Image, props.onActiveImage }, "ImageLabel")

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------

	-- EFFECTS -------------------------------------------------------------------------------------------------------------
	-- Deactivate on external change
	React.useEffect(function()
		if prevActivated == true and not props.activated then
			setIsActive(false)
			if props.onDeactivation then
				props.onDeactivation()
			end
		end
	end, { props.activated })

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e(
		"ImageButton",
		Utils.Table.Dictionary.mergeInstanceProps(props, {
			BackgroundTransparency = 1,
			[React.Event.MouseButton1Down] = function()
				if not isActive then
					setIsActive(true)
					if props.onActivation then
						props.onActivation()
					end
				else
					if props.externalDeactivation then
						return
					end

					setIsActive(false)
					if props.onDeactivation then
						props.onDeactivation()
					end
				end
			end,
			[React.Event.MouseButton1Up] = function()
				if not props.isToggle and isActive and not props.externalDeactivation then
					setIsActive(false)
					if props.onDeactivation then
						props.onDeactivation()
					end
				end
			end,
			Image = isActive and props.onActiveImage or props.Image,
			ScaleType = Enum.ScaleType.Fit,
		}),
		{
			UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
				AspectRatio = 1,
			}),

			UICorner = e("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
		}
	)
end

return ControlButton
