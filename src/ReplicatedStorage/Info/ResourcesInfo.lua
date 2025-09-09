local ColorConfigs = require(script.Parent.Parent:WaitForChild("Configs"):WaitForChild("ColorConfigs"))

local ResourcesInfo = {}

ResourcesInfo.allKeys = { "coins", "gems", "revives", "xp" }
ResourcesInfo.byKey = {
	coins = {
		image = "rbxassetid://101542292067445",
		color = Color3.fromRGB(255, 187, 29),
		colorSequence = ColorConfigs.colorSequences.coins,
		imageSize = UDim2.fromScale(0.65, 1.6),
	},
	gems = {
		image = "rbxassetid://85823663789550",
		color = Color3.fromRGB(46, 164, 255),
		colorSequence = ColorConfigs.colorSequences.gems,
		imageSize = UDim2.fromScale(0.65, 1.7),
	},
	revives = {
		image = "rbxassetid://77032034412857",
		color = Color3.fromRGB(255, 105, 105),
		colorSequence = ColorConfigs.colorSequences.revives,
		imageSize = UDim2.fromScale(0.65, 1.6),
	},
	xp = {
		image = "rbxassetid://96364245070773",
		colorSequence = ColorConfigs.colorSequences.xp,
	},
	robux = { image = "rbxassetid://77480164088097", colorSequence = ColorConfigs.colorSequences.purple },
}

-- FUNCTIONS ----------------------------------------------------------------------------------------------------
function ResourcesInfo.GetResourceInfo(resource: string, infoKey: string?)
	if not ResourcesInfo.byKey[resource] then
		return nil
	end

	if infoKey then
		return ResourcesInfo.byKey[resource][infoKey]
	end

	return ResourcesInfo.byKey[resource]
end

return ResourcesInfo
