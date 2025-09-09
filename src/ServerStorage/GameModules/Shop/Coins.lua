local Coins = {}
local Shop = require(script.Parent)
setmetatable(Coins, { __index = Shop })
-- Services ------------------------------------------------------------------------

-- Folders -------------------------------------------------------------------------

-- Modulescripts -------------------------------------------------------------------

-- KnitServices --------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Coins:ProcessReceipt(receiptInfo)
	local player = self:GetPlayerFromReceiptInfo(receiptInfo)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local info = self:GetInfo(receiptInfo.ProductId)
	local coinsAmount = info.amount

	if self.CurrencyManager.Add(player, coinsAmount, "coins", true) then
		self.MessageHandler.SendMessageToPlayer(
			player,
			string.format("You have purchased %s coins!", self.Utils.Number.ToEnglish(coinsAmount)),
			"PurchaseSuccessful"
		)
		self:PlayerSpentRobux(player, receiptInfo.CurrencySpent)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		self.MessageHandler.SendMessageToPlayer(
			player,
			string.format(
				"Your purchase of %s coins cannot currently be processed.",
				self.Utils.Number.ToEnglish(coinsAmount)
			),
			"Error"
		)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

function Coins:GetInfo(id: number)
	for _, eachInfo in pairs(self.CoinsInfo.byKey) do
		if eachInfo.id == id then
			return eachInfo
		end
	end
end

------------------------------------------------------------------------------------------------------------------------
-- VIRTUAL METHODS IMPLEMENTATION --------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Coins:IsValid(id: number)
	return self:GetInfo(id) ~= nil
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Coins
