local defaultProps = {
	ScreenGui = {
		ResetOnSpawn = false
	},
	BillboardGui = {
		ResetOnSpawn = false
	},
	SurfaceGui = {
		ResetOnSpawn = false
	},
	
	Frame = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0
	},
	ScrollingFrame = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,

		ScrollBarImageColor3 = Color3.new(0, 0, 0)
	},
	TextLabel = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		
		Text = '',
		TextSize = 14,
		TextColor3 = Color3.new(0, 0, 0)
	},
	TextBox = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		
		ClearTextOnFocus = false,
		
		Text = '',
		TextSize = 14,
		TextColor3 = Color3.new(0, 0, 0)
	},
	TextButton = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		
		AutoButtonColor = false,
		
		Text = '',
		TextSize = 14,
		TextColor3 = Color3.new(0, 0, 0)
	}
}

return defaultProps