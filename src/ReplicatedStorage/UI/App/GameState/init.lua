-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

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
local GameHandler = require(ReplicatedGameHandlers:WaitForChild("GameHandler"))
local MessageHandler = require(ReplicatedBaseHandlers:WaitForChild("MessageHandler"))

-- BaseComponents ----------------------------------------------------------------
local TextLabel = require(BaseComponents:WaitForChild("TextLabel"))
local UIStroke = require(BaseComponents:WaitForChild("UIStroke"))
local UIAspectRatioConstraint = require(BaseComponents:WaitForChild("UIAspectRatioConstraint"))

-- GlobalComponents ----------------------------------------------------------------

-- AppComponents -------------------------------------------------------------------
local CustomButton = require(AppComponents:WaitForChild("CustomButton"))

-- LocalComponents -----------------------------------------------------------------

-- Hooks ---------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
type Props = {}

-- Instances -----------------------------------------------------------------------

-- Info ----------------------------------------------------------------------------
local DifficultiesInfo = require(ReplicatedInfo:WaitForChild("DifficultiesInfo"))

-- Configs -------------------------------------------------------------------------
local TimeConfigs = require(ReplicatedConfigs:WaitForChild("TimeConfigs"))

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------

-- Selectors --------------------------------------------------------------------------
local selector = UIUtils.Selector.Create({
	gameState = { "difficulty", "isDay", "nightsSurvived", "zombiesLeft", "skipVotes" },
	window = { "windowShown", "hideHUD" },
	players = { "playersCount" },
})

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function GameState(props: Props)
	-- SELECTORS/CONTEXTS --------------------------------------------------------------------------------------------
	local storeState = ReactRedux.useSelector(selector)

	-- STATES/BINDINGS/REFS/HOOKS ------------------------------------------------------------------------------------------
	local votedSkipDay, setVotedSkipDay = React.useState(false)

	local progressColorBinding, setProgressColor = React.useBinding(Utils.Color.Configs.colorSequences.green)
	local progressTransparencyBinding, setProgressTransparency =
		React.useBinding(Utils.NumberSequence.CooldownSequence(0))
	local textTimeLeftBinding, setTextTimeLeft = React.useBinding("")

	local connectionsManagerRef = React.useRef(Utils.ConnectionsManager.new())

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------

	-- EFFECTS -------------------------------------------------------------------------------------------------------------
	-- Nights changed
	React.useEffect(function()
		setVotedSkipDay(false)
	end, { storeState.nightsSurvived })

	-- Day/Night changed
	React.useLayoutEffect(function()
		if storeState.isDay then
			local difficultyKey = DifficultiesInfo.keys[storeState.difficulty] or DifficultiesInfo.keys[1]
			local difficultyInfo = DifficultiesInfo.byKey[difficultyKey] :: DifficultiesInfo.DifficultyInfo
			local dayDuration = difficultyInfo.dayDuration

			connectionsManagerRef.current:Add(
				"DayTimeProgress",
				RunService.Heartbeat:Connect(function()
					local timeNow = Lighting.ClockTime

					-- Determine time left in the day (based on TimeConfigs)
					local dayTimeLeft = TimeConfigs.DAY_END_TIME - timeNow
					dayTimeLeft = timeNow > TimeConfigs.DAY_START_TIME and dayTimeLeft or 0
					local timeLeft =
						math.clamp((dayTimeLeft / TimeConfigs.TOTAL_DAY_DURATION) * dayDuration, 0, dayDuration)

					-- Update progress bar transparency
					setProgressTransparency(Utils.NumberSequence.CooldownSequence(timeLeft / dayDuration))

					-- Update progress bar color
					if timeLeft <= dayDuration * 0.2 then
						setProgressColor(Utils.Color.Configs.colorSequences.red)
					elseif timeLeft <= dayDuration * 0.4 then
						setProgressColor(Utils.Color.Configs.colorSequences.yellow)
					else
						setProgressColor(Utils.Color.Configs.colorSequences.green)
					end

					-- Update time left text
					setTextTimeLeft(Utils.Time.Format(timeLeft))
				end)
			)
		else
			connectionsManagerRef.current:Disconnect("DayTimeProgress")
		end
	end, { storeState.isDay, storeState.difficulty })

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0, 10),
		Size = UDim2.fromScale(0.4, 0.065),
		Visible = not storeState.hideHUD and not storeState.windowShown,
	}, {
		UIAspectRatioConstraint = e(UIAspectRatioConstraint, {
			size = UDim2.fromScale(0.4, 0.065),
		}),

		TextLabelNights = e(TextLabel, {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(1, 0.55),
			RichText = true,
			Text = string.format("Nights Survived: <font color ='rgb(255,0,0)'>%d</font>", storeState.nightsSurvived),
		}),

		FrameDay = e(
			"Frame",
			{ BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = storeState.isDay },
			{
				ProgressBarTimeLeft = e("Frame", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.fromRGB(150, 150, 150),
					BackgroundTransparency = 0.8,
					Position = UDim2.fromScale(0.5, 0.65),
					Size = UDim2.fromScale(0.5, 0.35),
				}, {
					UICorner = e("UICorner", {
						CornerRadius = UDim.new(0.5, 0),
					}),
					UIStroke = e(UIStroke, {
						Color = Color3.fromRGB(240, 240, 240),
						Thickness = 1.5,
						Transparency = 0.25,
					}),

					FrameProgress = e("Frame", {
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						Size = UDim2.fromScale(1, 1),
					}, {
						UICorner = e("UICorner", {
							CornerRadius = UDim.new(0.5, 0),
						}),
						UIGradient = e("UIGradient", {
							Color = progressColorBinding,
							Transparency = progressTransparencyBinding,
						}),
					}),

					TextLabelTime = e(TextLabel, {
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.fromScale(0.5, 0),
						Size = UDim2.fromScale(1, 1),
						Text = textTimeLeftBinding,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						ZIndex = 2,
					}),
				}),

				FrameSkipDay = e("Frame", {
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.75, 0),
					Size = UDim2.fromScale(0.25, 1),
				}, {
					TextLabelVotes = e(TextLabel, {
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.fromScale(0.5, 0),
						Size = UDim2.fromScale(1, 0.425),
						Text = string.format("Votes: %d/%d", storeState.skipVotes, storeState.playersCount),
						TextColor3 = Color3.fromRGB(255, 255, 255),
					}),

					ButtonSkipDay = e(CustomButton, {
						Position = UDim2.fromScale(0.5, 0.75),
						Size = UDim2.fromScale(0.7, 0.5),
						colorSequence = Utils.Color.Configs.colorSequences[votedSkipDay and "gray" or "green"],
						text = "Skip Day",
						textSize = UDim2.fromScale(0.9, 1),
						onClick = function()
							if votedSkipDay then
								MessageHandler.ShowMessage("You have already voted to skip the day.", "Error")
								return
							end

							GameHandler.VoteSkipDay():andThen(function(success)
								if success then
									setVotedSkipDay(true)
								end
							end)
						end,
					}),
				}),
			}
		),

		FrameNight = e(
			"Frame",
			{ BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = not storeState.isDay },
			{
				TextLabelZombiesLeft = e(TextLabel, {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.fromScale(0.5, 0.55),
					Size = UDim2.fromScale(1, 0.45),
					RichText = true,
					Text = string.format("<font color ='rgb(255,0,0)'>%d</font> Zombies Left", storeState.zombiesLeft),
				}),
			}
		),
	})
end

return GameState
