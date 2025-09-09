return {
	METADATA_CONFIGS = {
		announcement = {
			PrefixText = "[SERVER]",
			PrefixTextColor3 = Color3.fromRGB(255, 0, 0),
			TextColor3 = Color3.fromRGB(255, 109, 0),
		},
	},
	VIP = {
		PrefixText = "[VIP]",
		PrefixTextColor3 = Color3.fromRGB(255, 170, 0),
		PrefixTextColorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 4)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 170, 0)),
			ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.6, Color3.fromRGB(85, 255, 0)),
			ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 170, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 85, 255)),
		}),
	},
}
