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
local LobbyCreate = require(script:WaitForChild("LobbyCreate"))

-- Configs

-- Variables
local e = React.createElement

-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function App(props)
	-- SELECTORS -----------------------------------------------------------------------------------------------------------------------------------
	local appEnabled = ReactRedux.useSelector(function(state)
		return state.game.appEnabled
	end)

	-- MEMOIZE -----------------------------------------------------------------------------------------------------------------------------------

	-- EFFECTS -----------------------------------------------------------------------------------------------------------------------------------
	React.useEffect(function()
		task.spawn(function()
			game.ReplicatedFirst:WaitForChild("GuisLoaded").Value = true
		end)
	end, {})

	React.useEffect(function()
		props.screenGUI.Enabled = appEnabled
	end, appEnabled)

	-- COMPONENT ----------------------------------------------------------------------------------------------------------------------------------
	return {
		StartScreen = e(StartScreen),
		LobbyCreate = e(LobbyCreate),
	}
end

return App
