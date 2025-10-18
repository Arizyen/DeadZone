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

-- Modules -------------------------------------------------------------------
local Utils = require(ReplicatedPlaywooEngine:WaitForChild("Utils"))
local Knit = require(Packages:WaitForChild("Knit"))

-- Handlers -----------------------------------------------------------------------
local InventoryHandler = require(ReplicatedGameHandlers:WaitForChild("InventoryHandler"))

-- Knit Controllers ----------------------------------------------------------------
local InventoryController = Knit.CreateController({
	Name = "Inventory",
})

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
local knitServices = {}
------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS ------------------------------------------------------------------------------------------------------

-- Require Knit Services in KnitInit(). KnitStart() is called after all KnitInit() have been completed.
function InventoryController:KnitInit()
	knitServices["Inventory"] = Knit.GetService("Inventory")
end

-- KnitStart() fires after all KnitInit() have been completed.
function InventoryController:KnitStart() end

-------------------------------------------------------------------------------------------------------------------------
-- CLIENT FUNCTIONS -----------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------

return InventoryController
