local Shop = {}
-- Services ------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

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
local BaseServices = PlaywooEngine.BaseServices
local GameServices = ServerSource.GameServices

-- Modulescripts -------------------------------------------------------------------
local PlayersData = require(BaseHandlers.PlayerDataHandler.PlayersData)
Shop.CurrencyManager = require(BaseModules.CurrencyManager)
Shop.NameTag = require(BaseModules.PlayerManager.NameTag)
Shop.Utils = require(ReplicatedPlaywooEngine.Utils)

-- Handlers ----------------------------------------------------------------------------------------------------
local LeaderboardHandler = require(BaseHandlers.LeaderboardHandler)

-- KnitServices --------------------------------------------------------------------
Shop.PlayerDataHandler = require(BaseHandlers.PlayerDataHandler)
Shop.MessageHandler = require(BaseHandlers.MessageHandler)

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------
Shop.GamepassesInfo = require(ReplicatedInfo.Shop.GamepassesInfo)
Shop.GemsInfo = require(ReplicatedInfo.Shop.GemsInfo)
Shop.CoinsInfo = require(ReplicatedInfo.Shop.CoinsInfo)

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL METHODS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Shop:PlayerSpentRobux(player, amount)
	if amount <= 0 or not PlayersData.sortedData["robux"] then
		return
	end

	if PlayersData.sortedData["robux"].allTime[player.UserId] then
		PlayersData.sortedData["robux"].allTime[player.UserId] += amount
		self.PlayerDataHandler.SavePlayerData(player.UserId, LeaderboardHandler.GetDataStore("robux", true))
		self.PlayerDataHandler.SetPathValue(
			player.UserId,
			{ "statistics", "robuxAllTime" },
			PlayersData.sortedData["robux"].allTime[player.UserId]
		)
	end

	if PlayersData.sortedData["robux"].weekly[player.UserId] then
		PlayersData.sortedData["robux"].weekly[player.UserId] += amount
		self.PlayerDataHandler.SavePlayerData(player.UserId, LeaderboardHandler.GetDataStore("robux", false))
		self.PlayerDataHandler.SetPathValue(
			player.UserId,
			{ "statistics", "robuxWeekly" },
			PlayersData.sortedData["robux"].weekly[player.UserId]
		)
	end
end

function Shop:GetPlayerFromReceiptInfo(receiptInfo)
	return Players:GetPlayerByUserId(receiptInfo.PlayerId)
end

-- PRODUCTS ----------------------------------------------------------------------------------------------------
function Shop:GetProductInfo(productId, infoType: Enum.InfoType)
	local success, productInfo = pcall(function()
		return self.MarketplaceService:GetProductInfo(productId, infoType)
	end)
	if success then
		return productInfo
	end
end

function Shop:GetProductPrice(productId, infoType: Enum.InfoType)
	local productInfo = self:GetProductInfo(tonumber(productId), infoType)
	return productInfo and productInfo["PriceInRobux"] or 0
end

------------------------------------------------------------------------------------------------------------------------
-- VIRTUAL METHODS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Shop:IsValid(assetId)
	return false
end

function Shop:CanPurchase(player, assetId)
	return true
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Shop
