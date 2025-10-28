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
local LobbyHandler = require(ReplicatedGameHandlers:WaitForChild("LobbyHandler"))

-- BaseComponents ----------------------------------------------------------------
local TextLabel = require(BaseComponents:WaitForChild("TextLabel"))

-- GlobalComponents ----------------------------------------------------------------

-- AppComponents -------------------------------------------------------------------
local CustomButton = require(AppComponents:WaitForChild("CustomButton"))

-- LocalComponents -----------------------------------------------------------------

-- Hooks ---------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
type Props = {}

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local LobbyConfigs = require(ReplicatedConfigs:WaitForChild("LobbyConfigs"))

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------

-- Selectors --------------------------------------------------------------------------
local selector = UIUtils.Selector.Create({
	lobby = { "lobbyStates", "currentLobbyId" },
	window = { "windowShown" },
})

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function HUDLobby(props: Props)
	-- SELECTORS/CONTEXTS/HOOKS --------------------------------------------------------------------------------------------
	local storeState = ReactRedux.useSelector(selector)

	-- STATES/BINDINGS/REFS/HOOKS ------------------------------------------------------------------------------------------
	local lobbyState, setLobbyState = React.useState(storeState.lobbyStates[storeState.currentLobbyId] or {})
	local timeLeftBinding, setTimeLeft = React.useBinding(LobbyConfigs.START_TIME_WAIT)
	local motorRef = React.useRef(UIUtils.Motor.PulseMotor.new(2))

	local isHost = lobbyState.players and lobbyState.players[1] == game.Players.LocalPlayer
	local isCustomSave = lobbyState and lobbyState.settings and type(lobbyState.settings.saveId) == "string"

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------

	-- EFFECTS -------------------------------------------------------------------------------------------------------------
	-- On currentLobbyId changed
	React.useEffect(function()
		local currentLobbyState = storeState.lobbyStates[storeState.currentLobbyId] or {}
		if currentLobbyState and currentLobbyState.state == "Starting" and currentLobbyState.serverStartTime then
			local serverStartTime = currentLobbyState.serverStartTime
			local updateTimeLeft = function()
				setTimeLeft(
					math.round(
						math.clamp(serverStartTime - game.Workspace:GetServerTimeNow(), 0, LobbyConfigs.START_TIME_WAIT)
					)
				)
			end

			motorRef.current.onStart = updateTimeLeft
			motorRef.current.onReachedEndValue = updateTimeLeft

			motorRef.current:Start()
		else
			setTimeLeft(LobbyConfigs.START_TIME_WAIT)
			motorRef.current:Stop()
		end

		setLobbyState(currentLobbyState)
	end, { storeState.currentLobbyId, storeState.lobbyStates })

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.95),
		Size = UDim2.fromScale(0.175, 0.15),
		Visible = lobbyState.state == "Starting" and not storeState.windowShown,
	}, {
		TextLabel = e(TextLabel, {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.385),
			Size = UDim2.fromScale(1, 0.35),
			Text = timeLeftBinding:map(function(value)
				return string.format("Starting in %ss", value)
			end),
		}),

		ButtonLeave = e(CustomButton, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.75),
			Size = UDim2.fromScale(1, 0.6),
			colorSequence = Utils.Color.Configs.colorSequences.red,
			text = (isHost and isCustomSave) and "Close Lobby" or "Leave",
			onClick = function()
				LobbyHandler.LeaveLobby()
			end,
			image = (isHost and isCustomSave) and "rbxassetid://132036811628342" or "rbxassetid://111546384446445",
		}),
	})
end

return HUDLobby
