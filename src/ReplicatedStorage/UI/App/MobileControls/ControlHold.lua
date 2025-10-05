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

-- Hooks ---------------------------------------------------------------------------
local usePreloadAssets = require(BaseHooks:WaitForChild("usePreloadAssets"))

-- Types ---------------------------------------------------------------------------
type Props = {
	onActiveImage: string?,
	onActivation: (() -> ())?,
	onDeactivation: (() -> ())?,
	draggable: boolean?,
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

local function ControlHold(props: Props)
	-- SELECTORS/CONTEXTS/HOOKS --------------------------------------------------------------------------------------------

	-- STATES/BINDINGS/REFS/HOOKS ------------------------------------------------------------------------------------------
	local isHolding, setIsHolding = React.useState(false)
	local positionBinding, setPositionBinding = React.useState(props.Position or UDim2.new())
	local inputObjectRef = React.useRef(nil :: InputObject?)
	local connectionsManagerRef = React.useRef(Utils.ConnectionsManager.new())

	usePreloadAssets({ props.Image, props.onActiveImage }, "ImageLabel")

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------
	local function ActivateDragging(state: boolean, fnToExecute: (() -> ())?, x, y)
		if fnToExecute then
			fnToExecute()
		end

		-- Create input ended connection
		if state then
			if props.draggable then
				connectionsManagerRef.current:Add(
					"InputEnded",
					UserInputService.InputEnded:Connect(function(input)
						-- Check if dragging and if it's not another finger
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							ActivateDragging(false, props.onDeactivation)
							return
						end
						if
							input == inputObjectRef.current
							or (inputObjectRef.current == nil and (Vector3.new(x, y) - input.Position).Magnitude <= 30)
						then
							ActivateDragging(false, props.onDeactivation)
						end
					end)
				)
				setIsHolding(true)
			end
		else
			inputObjectRef.current = nil
			connectionsManagerRef.current:Disconnect("InputEnded")
			setIsHolding(false)
		end

		-- Create dragging connection
		if props.draggable then
			connectionsManagerRef.current:Disconnect("Dragging")

			if state then
				local inputObjectPositionDifference
				local inputPosition, startPosition, deltaPosition

				startPosition = UDim2.fromOffset(x, y)
				connectionsManagerRef.current:Add(
					"Dragging",
					UserInputService.InputChanged:Connect(function(input)
						local isTouch = input.UserInputType == Enum.UserInputType.Touch
						local isMouseMove = input.UserInputType == Enum.UserInputType.MouseMovement
						if not (isTouch or isMouseMove) then
							return
						end

						if isTouch and not inputObjectRef.current then
							if
								(Vector3.new(startPosition.X.Offset, startPosition.Y.Offset) - input.Position).Magnitude
								<= 144
							then
								inputObjectRef.current = input
								inputObjectPositionDifference = Vector3.new(
									startPosition.X.Offset,
									startPosition.Y.Offset
								) - input.Position
							else
								return
							end
						elseif isTouch and input ~= inputObjectRef.current then
							return
						end

						-- Position feedback
						if isTouch then
							inputPosition = input.Position + inputObjectPositionDifference
						else
							inputPosition = Vector3.new(startPosition.X.Offset, startPosition.Y.Offset, 0)
						end

						-- UI feedback
						deltaPosition = startPosition - UDim2.fromOffset(inputPosition.X, inputPosition.Y)
						setPositionBinding((props.Position or UDim2.new()) - deltaPosition)
					end)
				)
			else
				setPositionBinding(props.Position or UDim2.new())
			end
		end
	end
	-- MEMOS ---------------------------------------------------------------------------------------------------------------

	-- EFFECTS -------------------------------------------------------------------------------------------------------------
	-- Keep external Position in sync when not dragging
	React.useEffect(function()
		if not props.draggable then
			setPositionBinding(props.Position or UDim2.new())
		end
	end, { props.Position, props.draggable })

	-- Cleanup all connections on unmount
	React.useEffect(function()
		return function()
			connectionsManagerRef.current:Destroy()
		end
	end, {})

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e(
		"ImageLabel",
		Utils.Table.Dictionary.mergeInstanceProps(props, {
			BackgroundTransparency = 1,
			Position = props.draggable and positionBinding or (props.Position or UDim2.new()),
			[React.Event.InputBegan] = function(_, input: InputObject)
				if
					(
						input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch
					)
					and input.UserInputState == Enum.UserInputState.Begin
					and not connectionsManagerRef.current:Get("Dragging")
				then
					ActivateDragging(true, props.onActivation, input.Position.X, input.Position.Y)
				end
			end,
			Image = isHolding and props.onActiveImage or props.Image,
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

return ControlHold
