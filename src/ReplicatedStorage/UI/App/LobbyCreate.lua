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
local Flipper = require(Packages:WaitForChild("Flipper"))
local UIUtils = require(ReplicatedPlaywooEngine:WaitForChild("UIUtils"))
local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))
local Contexts = require(UI:WaitForChild("Contexts"))
local BaseContexts = require(PlaywooEngineUI:WaitForChild("BaseContexts"))

-- Handlers ----------------------------------------------------------------
local LobbyHandler = require(ReplicatedGameHandlers:WaitForChild("LobbyHandler"))

-- Instances -----------------------------------------------------------------------

-- BaseComponents ----------------------------------------------------------------

-- GlobalComponents ----------------------------------------------------------------

-- AppComponents -------------------------------------------------------------------
local CustomWindow = require(AppComponents:WaitForChild("CustomWindow"))
local CustomButton = require(AppComponents:WaitForChild("CustomButton"))
local ProgressBar = require(AppComponents:WaitForChild("ProgressBar"))

-- LocalComponents -----------------------------------------------------------------

-- Hooks ---------------------------------------------------------------------------
local usePrevious = require(BaseHooks:WaitForChild("usePrevious"))

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local LobbyConfigs = require(ReplicatedConfigs:WaitForChild("LobbyConfigs"))
local WINDOW_NAME = "LobbyCreate"

-- Types ---------------------------------------------------------------------------
type Props = {}

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------
local otherLobbyWindows = {
	"LobbyNew",
	"LobbyLoad",
}

-- Selectors --------------------------------------------------------------------------
local selector = UIUtils.Selector.Create({
	window = { "windowShown" },
	lobby = { "lobbyCreationTimeLeft" },
})

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function LobbyCreate(props: Props)
	local dispatch = ReactRedux.useDispatch()

	-- SELECTORS/CONTEXTS/HOOKS --------------------------------------------------------------------------------------------
	local storeState = ReactRedux.useSelector(selector)

	-- STATES/REFS/BINDINGS/HOOKS ------------------------------------------------------------------------------------------
	local previousWindow = usePrevious(storeState.windowShown, nil)

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------

	-- EFFECTS -------------------------------------------------------------------------------------------------------------
	-- On window open
	React.useLayoutEffect(function()
		if
			storeState.windowShown == WINDOW_NAME
			and previousWindow ~= WINDOW_NAME
			and not table.find(otherLobbyWindows, previousWindow)
		then
			dispatch({
				type = "SetLobbyCreationTimeLeft",
				value = LobbyConfigs.MAX_TIME_WAIT_LOBBY_CREATION,
			})
		end
	end, { storeState.windowShown, previousWindow })

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e(CustomWindow, {
		windowName = WINDOW_NAME,
		title = "Create Lobby",
		titleColorSequence = Utils.Color.Configs.colorSequences.blue,
		onCloseButtonClicked = function()
			LobbyHandler.LeaveLobby()
		end,
		Size = UDim2.fromScale(0.3, 0.33),
	}, {
		FrameButtons = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0.835),
		}, {
			UIListLayout = e("UIListLayout", {
				Padding = UDim.new(0.045, 0),
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			ButtonNewGame = e(CustomButton, {
				LayoutOrder = 1,
				Size = UDim2.fromScale(0.75, 0.35),
				text = "New Game",
				colorSequence = Utils.Color.Configs.colorSequences.green,
				image = "rbxassetid://85710190932350",
			}),

			ButtonLoadGame = e(CustomButton, {
				LayoutOrder = 2,
				Size = UDim2.fromScale(0.75, 0.35),
				text = "Load Game",
				colorSequence = Utils.Color.Configs.colorSequences.orange,
				image = "rbxassetid://127374615809191",
			}),
		}),

		ProgressBar = e(ProgressBar, {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.825),
			Size = UDim2.fromScale(0.85, 0.1),
			active = storeState.windowShown == WINDOW_NAME,
			maxTime = LobbyConfigs.MAX_TIME_WAIT_LOBBY_CREATION,
			lobbyCreationTimeLeft = storeState.lobbyCreationTimeLeft,
			onEnd = function()
				UIUtils.Window.Close(WINDOW_NAME)
			end,
		}),
	})
end

return LobbyCreate
