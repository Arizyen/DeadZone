local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedSource = ReplicatedStorage:WaitForChild("Source")
local ReplicatedPlaywooEngine = ReplicatedSource:WaitForChild("PlaywooEngine")
local ReplicatedBaseModules = ReplicatedPlaywooEngine:WaitForChild("BaseModules")
local S = require(ReplicatedBaseModules:WaitForChild("Schema"))

local ClientDataSchema = S.object({
	profile = S.object({
		newPlayer = S.req(S.boolean(), false),
	}),

	settings = S.object({
		musicVolume = S.opt(S.number(0, 1), 0.55),
		soundEffectsVolume = S.opt(S.number(0, 1), 1),
		rainbowNametagEnabled = S.opt(S.boolean(), false),
	}),
})

return ClientDataSchema
