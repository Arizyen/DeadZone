local ColorConfigs = require(script.Parent.Parent:WaitForChild("Configs"):WaitForChild("ColorConfigs"))

local MetaResourcesInfo = {}

MetaResourcesInfo.keys = { "coins", "gems", "revives", "xp" }
MetaResourcesInfo.byKey = {
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
function MetaResourcesInfo.GetResourceInfo(resource: string, infoKey: string?)
	if not MetaResourcesInfo.byKey[resource] then
		return nil
	end

	if infoKey then
		return MetaResourcesInfo.byKey[resource][infoKey]
	end

	return MetaResourcesInfo.byKey[resource]
end

return MetaResourcesInfo
