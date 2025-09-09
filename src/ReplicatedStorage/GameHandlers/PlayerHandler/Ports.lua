export type Ports = {
	KnitLoaded: () -> (),
	Freeze: (state: boolean) -> (),
	Spawn: () -> boolean,
	Reset: () -> (),
}

local Ports = {
	KnitLoaded = function() end,
	Freeze = function(_) end,
	Spawn = function()
		return false
	end,
	Reset = function() end,
} :: Ports

return Ports
