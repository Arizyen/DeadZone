local GameConfigs = {}
-- Services
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Folders
-- local Packages = ReplicatedStorage:WaitForChild("Packages")
-- local Source = ReplicatedStorage:WaitForChild("Source")
--
--
-- Modulescripts

-- KnitControllers

-- Instances

-- Configs

-- Default Variables
GameConfigs.DEV_MODE = false -- Enable dev mode features
GameConfigs.CUSTOM_SHIFT_LOCK = true
GameConfigs.SHIFT_LOCK_DISABLED_DEFAULT_STATE = false

-- Custom Variables
GameConfigs.INVENTORY_SLOTS = 500 -- Maximum inventory slots
GameConfigs.HOTBAR_SLOTS = 6
GameConfigs.LOADOUT_SLOTS = 6 -- head, chest, legs, backpack, pants, shirt
GameConfigs.STORAGE_CAPACITY = 500 -- Maximum weight capacity

-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS -------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------

return GameConfigs
