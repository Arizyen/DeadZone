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
local TextLabel = require(BaseComponents:WaitForChild("TextLabel"))

-- GlobalComponents ----------------------------------------------------------------

-- AppComponents -------------------------------------------------------------------

-- LocalComponents -----------------------------------------------------------------

-- Hooks ---------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
local SaveTypes = require(ReplicatedTypes:WaitForChild("SaveTypes"))
type Props = { save: SaveTypes.SaveInfo }

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------
local DifficultiesInfo = require(ReplicatedInfo:WaitForChild("DifficultiesInfo"))

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------

-- Selectors --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function SaveInfo(props: Props)
	-- SELECTORS/CONTEXTS/HOOKS --------------------------------------------------------------------------------------------

	-- STATES/REFS/BINDINGS/HOOKS ------------------------------------------------------------------------------------------

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------

	-- EFFECTS -------------------------------------------------------------------------------------------------------------

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e(
		"Frame",
		Utils.Table.Dictionary.mergeInstanceProps({
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.02, 0.5),
			Size = UDim2.fromScale(0.69, 0.9),
		}, props),
		{
			Frame1 = e("Frame", {
				UIListLayout = e("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				TextLabelSaveName = e(TextLabel, {
					LayoutOrder = 1,
					Size = UDim2.fromScale(1, 0.4),
					Text = props.props.save.name or "???",
					textStroke = true,
				}),
				TextLabelDifficulty = e(TextLabel, {
					LayoutOrder = 2,
					Size = UDim2.fromScale(1, 0.3),
					Text = props.save.difficulty or "???",
					textStroke = true,
					textColorSequence = Utils.Color.Configs.colorSequences[DifficultiesInfo.byKey[DifficultiesInfo.keys[props.save.difficulty or 2]].colorName]
						or Utils.Color.Configs.colorSequences.white,
				}),
				TextLabelNightsSurvived = e(TextLabel, {
					LayoutOrder = 3,
					Size = UDim2.fromScale(1, 0.3),
					RichText = true,
					Text = string.format(
						"Nights Survived: <font color='rgb(255,0,0)'>%s</font>",
						tostring(props.save.nightsSurvived or 0)
					),
					textStroke = true,
				}),
			}),

			Frame2 = e("Frame", {
				UIListLayout = e("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				TextLabelPlaytime = e(TextLabel, {
					LayoutOrder = 1,
					Size = UDim2.fromScale(1, 0.3),
					RichText = true,
					Text = string.format(
						"Playtime: <font color='rgb(28,141,244)'>%s</font>",
						Utils.Time.Format(props.save.playTime or 0)
					),
					textStroke = true,
				}),
				TextLabelCreatedAt = e(TextLabel, {
					LayoutOrder = 2,
					Size = UDim2.fromScale(1, 0.3),
					RichText = true,
					Text = string.format(
						"Created At: <font color='rgb(28,141,244)'>%s</font>",
						Utils.Time.FormatUnixToLocal(props.save.createdAt or 0)
					),
					textStroke = true,
				}),
				TextLabelUpdatedAt = e(TextLabel, {
					LayoutOrder = 3,
					Size = UDim2.fromScale(1, 0.3),
					RichText = true,
					Text = string.format(
						"Updated At: <font color='rgb(28,141,244)'>%s</font>",
						Utils.Time.FormatUnixToLocal(props.save.updatedAt or 0)
					),
					textStroke = true,
				}),
			}),
		}
	)
end

return SaveInfo
