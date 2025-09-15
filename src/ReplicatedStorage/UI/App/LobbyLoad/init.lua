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
local SaveInfo = require(script:WaitForChild("SaveInfo"))

-- Hooks ---------------------------------------------------------------------------
local usePrevious = require(BaseHooks:WaitForChild("usePrevious"))

-- Types ---------------------------------------------------------------------------
type Props = {}

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local LobbyConfigs = require(ReplicatedConfigs:WaitForChild("LobbyConfigs"))
local WINDOW_NAME = "LobbyLoad"

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------

-- Selectors --------------------------------------------------------------------------
local selector = UIUtils.Selector.Create({
	window = { "windowShown" },
	lobby = { "lobbyCreationTimeLimit" },
	data = { "saves" },
})

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function LobbyLoad(props: Props)
	-- SELECTORS/CONTEXTS/HOOKS --------------------------------------------------------------------------------------------
	local storeState = ReactRedux.useSelector(selector)

	-- STATES/REFS/BINDINGS/HOOKS ------------------------------------------------------------------------------------------
	local saveIndexSelected, setSaveIndexSelected = React.useState(nil)
	local maxPlayers, setMaxPlayers = React.useState(4)
	local friendsOnly, setFriendsOnly = React.useState(false)

	local prevWindowShown = usePrevious(storeState.windowShown)

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------
	local saves = React.useMemo(function()
		local frames = {}

		for index, save in ipairs(storeState.saves) do
			frames["Save" .. index] = e("Frame", {
				BackgroundColor3 = Color3.fromRGB(15, 15, 15),
				LayoutOrder = index,
				Size = UDim2.fromScale(0.975, 0.3),
			}, {
				UICorner = e("UICorner", {
					CornerRadius = UDim.new(0.1, 0),
				}),
				UIStroke = e(UIStroke, {
					Thickness = 2,
				}),

				FrameContent = e(SaveInfo, {
					save = save,
				}),

				FrameLoad = e("Frame", {
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.73, 0),
					Size = UDim2.fromScale(0.25, 1),
				}, {
					TextButtonLoad = e(CustomButton, {
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.875, 0.55),
						textSize = UDim2.fromScale(0.67, 0.855),
						text = "Load",
						colorSequence = Utils.Color.Configs.colorSequences.orange,
						image = "rbxassetid://127374615809191",
						imageSize = UDim2.fromScale(0.3, 1),
						onClick = function()
							setSaveIndexSelected(index)
						end,
					}),
				}),
			})
		end

		return frames
	end, { storeState.saves })

	-- EFFECTS -------------------------------------------------------------------------------------------------------------
	-- On window shown
	React.useLayoutEffect(function()
		if storeState.window == WINDOW_NAME and prevWindowShown ~= WINDOW_NAME then
			setSaveIndexSelected(nil)
		end
	end, { storeState.window })

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e(CustomWindow, {
		windowName = WINDOW_NAME,
		title = "Load Game",
		titleColorSequence = Utils.Color.Configs.colorSequences.blue,
		onCloseButtonClicked = function()
			UIUtils.Window.Show("LobbyCreate")
		end,
		Size = UDim2.fromScale(0.5, 0.55),
	}, {
		FrameNoSaves = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.05),
			Size = UDim2.fromScale(0.95, 0.8),
			Visible = #storeState.saves == 0,
		}, {
			UIListLayout = e("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			TextLabel1 = e(TextLabel, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				LayoutOrder = 1,
				Size = UDim2.fromScale(0.9, 0.25),
				Text = "No saves found",
				textStroke = true,
				textColorSequence = Utils.Color.Configs.colorSequences.red,
			}),
			TextLabel2 = e(TextLabel, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				LayoutOrder = 2,
				Size = UDim2.fromScale(0.9, 0.15),
				Text = "Create a new game to start playing!",
				textStroke = true,
			}),
		}),

		ScrollingFrameSaves = e(
			"ScrollingFrame",
			{
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.05),
				Size = UDim2.fromScale(0.95, 0.8),
				Visible = #storeState.saves > 0 and saveIndexSelected == nil,
				CanvasSize = UDim2.fromScale(0, 0.7),
				ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
				ScrollBarThickness = 16,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
			},
			Utils.Table.Dictionary.merge({
				UIListLayout = e("UIListLayout", {
					Padding = UDim.new(0.025, 0),
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
				}),
				FrameStart = e("Frame", {
					Size = UDim2.fromScale(1, 0.001),
					BackgroundTransparency = 1,
					LayoutOrder = 0,
				}),
				FrameEnd = e("Frame", {
					Size = UDim2.fromScale(1, 0.01),
					BackgroundTransparency = 1,
					LayoutOrder = 1000,
				}),
			}, saves)
		),

		FrameSelectSettings = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.05),
			Size = UDim2.fromScale(0.95, 0.8),
			Visible = #storeState.saves > 0 and saveIndexSelected ~= nil,
		}, {
			FrameSaveInfo = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.fromRGB(15, 15, 15),
				BackgroundTransparency = 0,
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.fromScale(0.975, 0.3),
			}, {
				UICorner = e("UICorner", {
					CornerRadius = UDim.new(0.1, 0),
				}),
				UIStroke = e(UIStroke, {
					Thickness = 2,
				}),
				SaveInfo = saveIndexSelected and e(SaveInfo, {
					save = storeState.saves[saveIndexSelected],
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.85, 0.9),
				}) or nil,
			}),

			FrameSettings = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.35),
				Size = UDim2.fromScale(0.65, 0.4),
			}, {
				UIListLayout = e("UIListLayout", {
					Padding = UDim.new(0.05, 0),
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				FrameMaxPlayers = e("Frame", {
					BackgroundTransparency = 1,
					LayoutOrder = 1,
					Size = UDim2.fromScale(1, 0.4),
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
							number = 5,
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
					LayoutOrder = 2,
					Size = UDim2.fromScale(1, 0.4),
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
				Position = UDim2.fromScale(0.5, 0.8),
				Size = UDim2.fromScale(0.8, 0.2),
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
						setSaveIndexSelected(nil)
					end,
				}),

				ButtonLoad = e(CustomButton, {
					LayoutOrder = 2,
					Size = UDim2.fromScale(0.4, 1),
					text = "Load",
					colorSequence = Utils.Color.Configs.colorSequences.orange,
					image = "rbxassetid://127374615809191",
					onClick = function()
						if saveIndexSelected then
							LobbyHandler.CreateLobby({
								difficulty = storeState.saves[saveIndexSelected].difficulty,
								maxPlayers = maxPlayers,
								friendsOnly = friendsOnly,
								saveIndex = saveIndexSelected,
							})
						end
					end,
				}),
			}),
		}),

		ProgressBar = e(ProgressBar, {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.955),
			Size = UDim2.fromScale(0.85, 0.06),
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

return LobbyLoad
