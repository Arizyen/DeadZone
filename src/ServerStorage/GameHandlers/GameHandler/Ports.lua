local ReplicatedSource = game:GetService("ReplicatedStorage").Source
local ServerSource = game:GetService("ServerStorage").Source
local ReplicatedTypes = ReplicatedSource.Types
local Types = ServerSource.Types

local GameTypes = require(ReplicatedTypes.GameTypes)

export type Ports = {
	SetGameState: (newState: GameTypes.GameState) -> (),
	SetGameStateKey: (key: string, value: any) -> (),
}

local Ports = {} :: Ports

return Ports
