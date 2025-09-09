return {
	allKeys = { -- Keys that are modifiable by the client (MUST NOT BE A TABLE)
		newPlayer = "boolean",
		musicVolume = "number",
		soundEffectsVolume = "number",
		rainbowNametagEnabled = "boolean",
	},
	tableKeys = { -- Table allKeys modifiable by the client
		adShownTimes = {
			vip = "number",
		},
	},
}
