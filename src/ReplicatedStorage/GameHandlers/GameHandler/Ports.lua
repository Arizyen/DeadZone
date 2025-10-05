local ReplicatedSource = game:GetService("ReplicatedStorage"):WaitForChild("Source")
local ReplicatedTypes = ReplicatedSource:WaitForChild("Types")
local GameTypes = require(ReplicatedTypes:WaitForChild("GameTypes"))

export type Ports = {
	GetGameState: () -> GameTypes.GameState,
	VoteSkipDay: () -> boolean,
}

local Ports = {} :: Ports

return Ports
