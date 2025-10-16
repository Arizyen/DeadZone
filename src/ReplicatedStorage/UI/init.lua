local UI = {}
-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GUIService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")

-- Folders -------------------------------------------------------------------------
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

local PlaywooEngineUI = ReplicatedPlaywooEngine:WaitForChild("UI")

-- Modulescripts -------------------------------------------------------------------
local React = require(Packages:WaitForChild("React"))
local ReactRoblox = require(Packages:WaitForChild("ReactRoblox"))
local ReactRedux = require(Packages:WaitForChild("ReactRedux"))
local App = require(script:WaitForChild("App"))
local Store = require(PlaywooEngineUI:WaitForChild("Store"))
local AllContextProviders = require(PlaywooEngineUI:WaitForChild("AllContextProviders"))
local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))

-- Knit Controllers ----------------------------------------------------------------

-- Instances -----------------------------------------------------------------------
local localPlayer = game.Players.LocalPlayer
local Mouse = localPlayer:GetMouse()
local PlayerGui = localPlayer:WaitForChild("PlayerGui")

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local MapConfigs = require(ReplicatedConfigs:WaitForChild("MapConfigs"))

-- Types ---------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------
local store = Store.GetStore()
local e = React.createElement

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function CreateCameraViewportSizeConnection()
	local viewportSize

	game.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		viewportSize = game.Workspace.CurrentCamera.ViewportSize
		local lastSize = viewportSize

		-- Update window size only after 1 second of the window no longer changing size
		task.wait(0.5)

		if lastSize == viewportSize then
			Utils.Signals.Fire("DispatchAction", {
				type = "UpdateThemeState",
				value = {
					guiInset = GUIService:GetGuiInset(),
					cameraViewportSize = viewportSize,
					totalScreenSize = viewportSize.X + viewportSize.Y,
					screenResolution = Mouse and Mouse.ViewSizeX and Vector2.new(Mouse.ViewSizeX, Mouse.ViewSizeY),
				},
			})
		end
	end)

	viewportSize = game.Workspace.CurrentCamera and game.Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
	Utils.Signals.Fire("DispatchAction", {
		type = "UpdateThemeState",
		value = {
			guiInset = GUIService:GetGuiInset(),
			cameraViewportSize = viewportSize,
			totalScreenSize = viewportSize.X + viewportSize.Y,
			screenResolution = Mouse and Mouse.ViewSizeX and Vector2.new(Mouse.ViewSizeX, Mouse.ViewSizeY),
		},
	})
end

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function UI.MountApp()
	Utils.Signals.Fire("DispatchAction", {
		type = "SetCameraViewportSize",
	})

	local screenGUI = Instance.new("ScreenGui")
	screenGUI.Name = "MainGui"
	screenGUI.Enabled = false
	screenGUI.Parent = PlayerGui
	screenGUI.IgnoreGuiInset = true
	screenGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGUI.ResetOnSpawn = false

	local root = ReactRoblox.createRoot(screenGUI)

	root:render(e(
		ReactRedux.Provider,
		{
			store = store,
		},
		e(
			AllContextProviders,
			nil,
			e(App, {
				screenGUI = screenGUI,
				lobbyApp = MapConfigs.IS_LOBBY_PLACE,
			})
		)
	))

	Utils.Signals.Fire("DispatchAction", {
		type = "SetAppState",
		value = {
			gameLoading = false,
			appEnabled = true,
		},
	})

	-- Show StartScreen or join directly the game
	-- local teleportData = TeleportService:GetLocalPlayerTeleportData()

	if MapConfigs.IS_LOBBY_PLACE then
		-- Spawning is not handled automatically in the Lobby, so showing the StartScreen
		Utils.Signals.Fire("DispatchAction", {
			type = "ShowWindow",
			value = "StartScreen",
		})
	end

	Utils.Signals.Fire("AppMounted")
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
CreateCameraViewportSizeConnection()

return UI
