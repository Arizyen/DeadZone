local Gamepasses = {}
local Shop = require(script.Parent)
setmetatable(Gamepasses, { __index = Shop })

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
local function GetGamepassKeyFromId(gamePassId)
	for key, gamepassInfo in pairs(Gamepasses.GamepassesInfo.byKey) do
		if gamepassInfo.id == gamePassId then
			return key
		end
	end
end

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Gamepasses:PlayerPurchasedGamePass(player, gamePassId, success)
	local gamepassKey = GetGamepassKeyFromId(gamePassId)

	if success and gamepassKey then
		print(player.Name .. " purchased the game pass " .. gamepassKey .. " with ID " .. gamePassId .. ".")

		self.PlayerDataHandler.SetKeyIndexValue(player.UserId, "gamepasses", gamepassKey, true, true)
		self.Utils.Signals.Fire("GamepassPurchased", player, gamepassKey)

		if gamepassKey == "vip" then
			self.PlayerDataHandler.SetKeyValue(player.UserId, "rainbowNametagEnabled", true)
			self.NameTag.GiveEntityNameTag(player, player.Character)
		end

		gamepassKey = string.upper(string.sub(gamepassKey, 1, 1)) .. string.sub(gamepassKey, 2)
		self.MessageHandler.SendChatMessage(player.DisplayName .. " has purchased the " .. gamepassKey .. " game pass!")
		self.MessageHandler.SendMessageToPlayer(player, "You have purchased the game pass: " .. gamepassKey, "Success")

		local gamepassInfo = self:GetProductInfo(gamePassId, Enum.InfoType.GamePass)
		local priceInRobux = gamepassInfo and gamepassInfo["PriceInRobux"] or 0
		self:PlayerSpentRobux(player, priceInRobux)
	else
		-- Fire the client to show frame saying not enough robux
		self.MessageHandler.SendMessageToPlayer(
			player,
			"The game pass purchase was not successful. Please try again.",
			"Error"
		)
	end
end

function Gamepasses:GetGamepassId(gamepassKey)
	return self.GamepassesInfo.byKey[gamepassKey] and self.GamepassesInfo.byKey[gamepassKey].id or nil
end

------------------------------------------------------------------------------------------------------------------------
-- VIRTUAL METHODS IMPLEMENTATION --------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Shop:IsValid(gamepassKey)
	return self.GamepassesInfo.byKey[gamepassKey] ~= nil
end

function Shop:CanPurchase(player, gamepassKey)
	if self.PlayerDataHandler.OwnsGamepass(player, gamepassKey) then
		self.MessageHandler.SendMessageToPlayer(
			player,
			string.format("You already own the %s gamepass", self.GamepassesInfo.byKey[gamepassKey].name),
			"Error"
		)
		return false
	end

	return true
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Gamepasses
