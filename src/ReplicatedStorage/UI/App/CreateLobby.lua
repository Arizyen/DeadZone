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

-- Instances -----------------------------------------------------------------------

-- BaseComponents ----------------------------------------------------------------

-- GlobalComponents ----------------------------------------------------------------

-- AppComponents -------------------------------------------------------------------
local CustomWindow = require(AppComponents:WaitForChild("CustomWindow"))

-- LocalComponents -----------------------------------------------------------------

-- Hooks ---------------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local WINDOW_NAME = "CreateLobby"

-- Types ---------------------------------------------------------------------------
type Props = {}

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------

-- Selectors --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function CreateLobby(props: Props)
	-- SELECTORS/CONTEXTS/HOOKS --------------------------------------------------------------------------------------------

	-- STATES/REFS/BINDINGS/HOOKS ------------------------------------------------------------------------------------------

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------

	-- EFFECTS -------------------------------------------------------------------------------------------------------------

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e(CustomWindow, {
		windowName = WINDOW_NAME,
		title = "Create Lobby",
		titleColorSequence = Utils.Color.Configs.colorSequences.blue,
	})
end

return CreateLobby
