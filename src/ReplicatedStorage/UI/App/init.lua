-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local ReplicatedSource = ReplicatedStorage:WaitForChild("Source")
local ReplicatedPlaywooEngine = ReplicatedSource:WaitForChild("PlaywooEngine")
local ReplicatedConfigs = ReplicatedSource:WaitForChild("Configs")
local ReplicatedInfo = ReplicatedSource:WaitForChild("Info")
local ReplicatedTypes = ReplicatedSource:WaitForChild("Types")
local ReplicatedBaseModules = ReplicatedPlaywooEngine:WaitForChild("BaseModules")
local ReplicatedGameModules = ReplicatedSource:WaitForChild("GameModules")
local BaseControllers = ReplicatedPlaywooEngine:WaitForChild("BaseControllers")
local GameControllers = ReplicatedSource:WaitForChild("GameControllers")

local UI = ReplicatedSource:WaitForChild("UI")
local PlaywooEngineUI = ReplicatedPlaywooEngine:WaitForChild("UI")
local BaseComponents = PlaywooEngineUI:WaitForChild("BaseComponents")
local GlobalComponents = PlaywooEngineUI:WaitForChild("GlobalComponents")

-- Modulescripts
local React = require(Packages:WaitForChild("React"))
local ReactRedux = require(Packages:WaitForChild("ReactRedux"))
-- local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))
-- local CameraManager = require(ReplicatedBaseModules:WaitForChild("CameraManager"))

-- KnitControllers

-- Instances

-- MainComponents

-- GlobalComponents

-- LocalComponents
local StartScreen = require(script:WaitForChild("StartScreen"))
local Messages = require(script:WaitForChild("Messages"))
local LobbyCreate = require(script:WaitForChild("LobbyCreate"))
local LobbyLoad = require(script:WaitForChild("LobbyLoad"))
local LobbyNew = require(script:WaitForChild("LobbyNew"))
local HUDLobby = require(script:WaitForChild("HUDLobby"))
local HUDLobbyRightSide = require(script:WaitForChild("HUDLobbyRightSide"))
local Teleporting = require(script:WaitForChild("Teleporting"))
local Stamina = require(script:WaitForChild("Stamina"))
local MobileControls = require(script:WaitForChild("MobileControls"))
local GameState = require(script:WaitForChild("GameState"))

-- Configs

-- Types
type Props = {
	screenGUI: ScreenGui,
	lobbyApp: boolean,
}

-- Variables
local e = React.createElement

-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function App(props)
	-- SELECTORS -----------------------------------------------------------------------------------------------------------------------------------
	local appEnabled = ReactRedux.useSelector(function(state)
		return state.app.appEnabled
	end)

	-- MEMOIZE -----------------------------------------------------------------------------------------------------------------------------------

	-- EFFECTS -----------------------------------------------------------------------------------------------------------------------------------
	React.useEffect(function()
		task.defer(function()
			game.ReplicatedFirst:WaitForChild("GuisLoaded").Value = true
		end)
	end, {})

	React.useEffect(function()
		props.screenGUI.Enabled = appEnabled
	end, appEnabled)

	-- COMPONENT ----------------------------------------------------------------------------------------------------------------------------------

	if props.lobbyApp then
		return {
			StartScreen = e(StartScreen),
			Messages = e(Messages),
			LobbyCreate = e(LobbyCreate),
			LobbyLoad = e(LobbyLoad),
			LobbyNew = e(LobbyNew),
			HUDLobby = e(HUDLobby),
			HUDLobbyRightSide = e(HUDLobbyRightSide),
			Teleporting = e(Teleporting),
			Stamina = e(Stamina),
			MobileControls = e(MobileControls),
		}
	else
		return {
			Messages = e(Messages),
			Teleporting = e(Teleporting),
			Stamina = e(Stamina),
			MobileControls = e(MobileControls),
			GameState = e(GameState),
		}
	end
end

return App
