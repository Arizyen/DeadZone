local MapConfigs = {}

MapConfigs.MAPS_PLACE_ID = {
	Lobby = 118829249512783,
	PVE1 = 109035563696830,
}
MapConfigs.PLACES_MAP_TYPE = {
	[MapConfigs.MAPS_PLACE_ID.Lobby] = "Lobby",
	[MapConfigs.MAPS_PLACE_ID.PVE1] = "PVE",
}

-- All Place IDs that are PVE maps
MapConfigs.PVE_PLACE_IDS = {
	MapConfigs.MAPS_PLACE_ID.PVE1,
}

return MapConfigs
