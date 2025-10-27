local ZoneConfigs = {}

ZoneConfigs.RANGE = 150

-- FUNCTIONS ----------------------------------------------------------------------------------------------------

function ZoneConfigs.GetZoneKey(position: Vector3): string
	local x, y, z =
		math.floor(position.X / ZoneConfigs.RANGE),
		math.floor(position.Y / ZoneConfigs.RANGE),
		math.floor(position.Z / ZoneConfigs.RANGE)
	return tostring(x) .. "," .. tostring(y) .. "," .. tostring(z)
end

function ZoneConfigs.GetZoneKeysInRange(origin: string | Vector3): { string }
	if typeof(origin) == "Vector3" then
		origin = ZoneConfigs.GetZoneKey(origin)
	end

	local inRangeZoneKeys = {}
	local coordinates = string.split(origin, ",")
	local x, y, z = tonumber(coordinates[1]), tonumber(coordinates[2]), tonumber(coordinates[3])

	for i = x - 1, x + 1 do
		for j = y - 1, y + 1 do
			for k = z - 1, z + 1 do
				table.insert(inRangeZoneKeys, i .. "," .. j .. "," .. k)
			end
		end
	end

	return inRangeZoneKeys
end

return ZoneConfigs
