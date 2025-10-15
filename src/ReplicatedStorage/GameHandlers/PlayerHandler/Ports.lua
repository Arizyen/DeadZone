export type Ports = {
	KnitLoaded: () -> (),
	Freeze: (state: boolean) -> (),
	Spawn: () -> boolean,
	Reset: () -> (),
	ReplicateAxes: (pitchRad: number, yawRad: number) -> (),
}

local Ports = {} :: Ports

return Ports
