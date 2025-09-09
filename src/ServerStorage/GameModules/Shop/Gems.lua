local Gems = {}
local Shop = require(script.Parent)
setmetatable(Gems, { __index = Shop })

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
function Gems:ProcessReceipt(receiptInfo)
	local player = self:GetPlayerFromReceiptInfo(receiptInfo)

	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local info = self:GetInfo(receiptInfo.ProductId)
	local gemsCount = info.amount

	if self.CurrencyManager.Add(player, gemsCount, "gems", true) then
		self.MessageHandler.SendMessageToPlayer(
			player,
			string.format("You have purchased %s gems!", self.Utils.Number.ToEnglish(gemsCount)),
			"GemPurchase"
		)
		self:PlayerSpentRobux(player, receiptInfo.CurrencySpent)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		self.MessageHandler.SendMessageToPlayer(
			player,
			string.format(
				"Error: your purchase of %s gems cannot currently be processed.",
				self.Utils.Number.ToEnglish(gemsCount)
			),
			"Error"
		)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

function Gems:GetInfo(id: number)
	for _, eachInfo in pairs(self.GemsInfo.byKey) do
		if eachInfo.id == id then
			return eachInfo
		end
	end
end

------------------------------------------------------------------------------------------------------------------------
-- VIRTUAL METHODS IMPLEMENTATION --------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Gems:IsValid(id)
	return self:GetInfo(id) ~= nil
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Gems
