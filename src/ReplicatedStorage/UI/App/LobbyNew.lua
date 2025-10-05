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
local UIStroke = require(BaseComponents:WaitForChild("UIStroke"))

-- GlobalComponents ----------------------------------------------------------------
local NumericUpDown1 = require(GlobalComponents:WaitForChild("NumericUpDown1"))
local Toggle = require(GlobalComponents:WaitForChild("Toggle"))
local ProgressBar = require(GlobalComponents:WaitForChild("ProgressBar"))

-- AppComponents -------------------------------------------------------------------
local CustomWindow = require(AppComponents:WaitForChild("CustomWindow"))
local CustomButton = require(AppComponents:WaitForChild("CustomButton"))

-- LocalComponents -----------------------------------------------------------------

-- Hooks ---------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
type Props = {}

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------
local DifficultiesInfo = require(ReplicatedInfo:WaitForChild("DifficultiesInfo"))

-- Configs -------------------------------------------------------------------------
local LobbyConfigs = require(ReplicatedConfigs:WaitForChild("LobbyConfigs"))
local WINDOW_NAME = "LobbyNew"

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------

-- Selectors --------------------------------------------------------------------------
local selector = UIUtils.Selector.Create({
	window = { "windowShown" },
	lobby = { "lobbyCreationTimeLimit" },
})
------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function LobbyNew(props: Props)
	-- SELECTORS/CONTEXTS/HOOKS --------------------------------------------------------------------------------------------
	local storeState = ReactRedux.useSelector(selector)

	-- STATES/REFS/BINDINGS/HOOKS ------------------------------------------------------------------------------------------
	local difficultyIndex, setDifficultyIndex = React.useState(LobbyConfigs.DEFAULT_DIFFICULTY)
	local friendsOnly, setFriendsOnly = React.useState(false)
	local maxPlayers, setMaxPlayers = React.useBinding(LobbyConfigs.DEFAULT_MAX_PLAYERS)

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------
	local difficultyButtons = React.useMemo(function()
		return Utils.Table.Dictionary.map(DifficultiesInfo.byKey, function(difficultyInfo)
			return e(CustomButton, {
				LayoutOrder = difficultyInfo.index,
				Size = UDim2.fromScale(0.315, 0.85),
				text = difficultyInfo.name,
				colorSequence = difficultyIndex == difficultyInfo.index
						and Utils.Color.Configs.colorSequences[difficultyInfo.colorName]
					or Utils.Color.Configs.colorSequences.silver,
				onClick = function()
					setDifficultyIndex(difficultyInfo.index)
				end,
			})
		end)
	end, { difficultyIndex })

	-- EFFECTS -------------------------------------------------------------------------------------------------------------

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e(CustomWindow, {
		windowName = WINDOW_NAME,
		title = "New Game",
		titleColorSequence = Utils.Color.Configs.colorSequences.blue,
		onCloseButtonClicked = function()
			UIUtils.Window.Show("LobbyCreate")
		end,
		Size = UDim2.fromScale(0.5, 0.475),
	}, {
		FrameSelectSettings = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.05),
			Size = UDim2.fromScale(0.95, 0.8),
		}, {
			FrameSettings = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.fromScale(0.65, 0.695),
			}, {
				UIListLayout = e("UIListLayout", {
					Padding = UDim.new(0.05, 0),
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				FrameDifficulty = e("Frame", {
					BackgroundTransparency = 1,
					LayoutOrder = 1,
					Size = UDim2.fromScale(1.35, 0.266),
				}, {
					FrameLeft = e("Frame", {
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0, 0),
						Size = UDim2.fromScale(0.31, 1),
					}, {
						TextLabel = e(TextLabel, {
							Position = UDim2.fromScale(0, 0),
							Size = UDim2.fromScale(1, 1),
							Text = "Difficulty:",
							textStroke = true,
						}),
					}),

					FrameRight = e("Frame", {
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.37, 0),
						Size = UDim2.fromScale(0.63, 1),
					}, {
						UIListLayout = e("UIListLayout", {
							Padding = UDim.new(0.03, 0),
							FillDirection = Enum.FillDirection.Horizontal,
							SortOrder = Enum.SortOrder.LayoutOrder,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
						}),
						Buttons = e(React.Fragment, nil, difficultyButtons),
					}),
				}),

				FrameMaxPlayers = e("Frame", {
					BackgroundTransparency = 1,
					LayoutOrder = 2,
					Size = UDim2.fromScale(1, 0.266),
				}, {
					FrameLeft = e("Frame", {
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0, 0),
						Size = UDim2.fromScale(0.5, 1),
					}, {
						TextLabel = e(TextLabel, {
							Position = UDim2.fromScale(0, 0),
							Size = UDim2.fromScale(1, 1),
							Text = "Max Players:",
							textStroke = true,
						}),
					}),

					FrameRight = e("Frame", {
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.5, 0),
						Size = UDim2.fromScale(0.5, 1),
					}, {
						NumericUpDown1 = e(NumericUpDown1, {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(0.65, 0.85),
							number = maxPlayers:getValue(),
							minNumber = 1,
							maxNumber = LobbyConfigs.MAX_PLAYERS,
							increment = 1,
							onUpdate = function(value)
								setMaxPlayers(value)
							end,
						}),
					}),
				}),

				FrameFriendsOnly = e("Frame", {
					BackgroundTransparency = 1,
					LayoutOrder = 3,
					Size = UDim2.fromScale(1, 0.266),
				}, {
					FrameLeft = e("Frame", {
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0, 0),
						Size = UDim2.fromScale(0.5, 1),
					}, {
						TextLabel = e(TextLabel, {
							Position = UDim2.fromScale(0, 0),
							Size = UDim2.fromScale(1, 1),
							Text = "Friends Only:",
							textStroke = true,
						}),
					}),

					FrameRight = e("Frame", {
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.5, 0),
						Size = UDim2.fromScale(0.5, 1),
					}, {
						Toggle = e(Toggle, {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(0.325, 0.7),
							isOn = friendsOnly,
							onClick = function()
								setFriendsOnly(not friendsOnly)
							end,
						}),
					}),
				}),
			}),

			FrameButtons = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.735),
				Size = UDim2.fromScale(0.8, 0.231),
			}, {
				UIListLayout = e("UIListLayout", {
					Padding = UDim.new(0.025, 0),
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				ButtonBack = e(CustomButton, {
					LayoutOrder = 1,
					Size = UDim2.fromScale(0.4, 1),
					text = "Go Back",
					colorSequence = Utils.Color.Configs.colorSequences.red,
					image = "rbxassetid://76533847836378",
					onClick = function()
						UIUtils.Window.Show("LobbyCreate")
						UIUtils.Window.Close(WINDOW_NAME)
					end,
				}),

				ButtonNew = e(CustomButton, {
					LayoutOrder = 2,
					Size = UDim2.fromScale(0.4, 1),
					text = "New",
					colorSequence = Utils.Color.Configs.colorSequences.green,
					image = "rbxassetid://85710190932350",
					onClick = function()
						LobbyHandler.CreateLobby({
							difficulty = difficultyIndex,
							maxPlayers = maxPlayers:getValue(),
							friendsOnly = friendsOnly,
						})
					end,
				}),
			}),
		}),

		ProgressBar = e(ProgressBar, {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.955),
			Size = UDim2.fromScale(0.85, 0.07),
			active = storeState.windowShown == WINDOW_NAME,
			timeLimit = LobbyConfigs.MAX_TIME_WAIT_LOBBY_CREATION,
			timePassed = LobbyConfigs.MAX_TIME_WAIT_LOBBY_CREATION - (storeState.lobbyCreationTimeLimit - os.clock()),
			onEnd = function()
				UIUtils.Window.Close("LobbyCreate")
				UIUtils.Window.Close(WINDOW_NAME)
			end,
		}),
	})
end

return LobbyNew
