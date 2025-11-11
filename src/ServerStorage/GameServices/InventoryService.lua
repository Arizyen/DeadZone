-- Services ------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage.Packages
local ReplicatedSource = ReplicatedStorage.Source
local ServerSource = ServerStorage.Source
local ReplicatedPlaywooEngine = ReplicatedSource.PlaywooEngine
local PlaywooEngine = ServerSource.PlaywooEngine
local ReplicatedBaseModules = ReplicatedPlaywooEngine.BaseModules
local ReplicatedConfigs = ReplicatedSource.Configs
local ReplicatedInfo = ReplicatedSource.Info
local ReplicatedTypes = ReplicatedSource.Types
local BaseModules = PlaywooEngine.BaseModules
local GameModules = ServerSource.GameModules
local BaseHandlers = PlaywooEngine.BaseHandlers
local GameHandlers = ServerSource.GameHandlers

-- Modules -------------------------------------------------------------------
local Knit = require(Packages.Knit)
local RateLimiter = require(BaseModules.RateLimiter)

-- Handlers -------------------------------------------------------------------
local InventoryHandler = require(GameHandlers.InventoryHandler)
local MessageHandler = require(BaseHandlers.MessageHandler)

-- Knit Services --------------------------------------------------------------------
local InventoryService = Knit.CreateService({
	Name = "Inventory",
	Client = {
		ObjectAdded = Knit.CreateSignal(),
		ObjectRemoved = Knit.CreateSignal(), -- Does not replicate for objects of type "ammo"
	},
})

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS ------------------------------------------------------------------------------------------------------

-- Require Knit Services in KnitInit(). KnitStart() is called after all KnitInit() have been completed.
function InventoryService:KnitInit()
	InventoryHandler.Register({
		ObjectAdded = function(player: Player, key: string, quantity: number)
			self.Client.ObjectAdded:Fire(player, key, quantity)
		end,
		ObjectRemoved = function(player: Player, key: string, quantity: number)
			self.Client.ObjectRemoved:Fire(player, key, quantity)
		end,
	})
end

-- KnitStart() fires after all KnitInit() have been completed.
function InventoryService:KnitStart() end

-------------------------------------------------------------------------------------------------------------------------
-- CLIENT FUNCTIONS -----------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
function InventoryService.Client:MoveObject(
	player: Player,
	objectId: string,
	newLocation: "inventory" | "hotbar" | "loadout",
	newSlotId: string
)
	if not RateLimiter.Use(player.UserId, "InventoryService", "MoveObject", 5, 5) then
		return false, "Rate limit exceeded"
	end

	local success, errMsg = InventoryHandler.MoveObject(player, objectId, newLocation, newSlotId)
	if not success then
		MessageHandler.SendMessageToPlayer(player, errMsg or "Cannot move object", "Error")
	end
end

return InventoryService
