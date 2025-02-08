local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rusion = require(ReplicatedStorage.Libraries.ReactFusion)
local Value = Rusion.createValue
local Element = Rusion.createElement

local currentTime = Value(Lighting.ClockTime)
currentTime:bindToInstanceProperty(Lighting, 'ClockTime')

local numbers = {}

for i = 1, 12 do
	local x = (math.sin(i / 12 * math.pi * 2) + 1) / 2
	local y = 1 - (math.cos(i / 12 * math.pi * 2) + 1) / 2
	
	local label = Element('TextLabel', {
		AutomaticSize = Enum.AutomaticSize.XY,
		AnchorPoint = Vector2.new(x, y),
		Position = UDim2.fromScale(x, y),
		
		TextColor3 = currentTime:map(function(v)
			local hour = math.floor(v) % 12
			
			if hour == i % 12 then
				return Color3.new(1, 0, 0)
			end
			
			return Color3.new(0, 0, 0)
		end),
		BackgroundTransparency = 1,
		
		Text = tostring(i),
		TextSize = 18
	})
	
	numbers[i] = label
end

Rusion.hydrate(workspace:WaitForChild('HydrationDemo'), nil, Element('SurfaceGui', nil, {
	Background = Element('Frame', {
		Size = UDim2.fromOffset(100, 100),
		BorderSizePixel = 1
	}, {
		Round = Element('UICorner', {
			CornerRadius = UDim.new(1, 0)
		}),
		Stroke = Element('UIStroke', {
			Color = Color3.new(0, 0, 0),
			Thickness = 2
		}),
		
		Padding = Element('Frame', {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.9, 0.9),
			
			BackgroundTransparency = 1
		}, numbers),
		Label = Element('TextLabel', {
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 25),
			
			BackgroundTransparency = 1,
			
			Text = currentTime:map(function(v: number)
				local hours = math.floor(v)
				local minutes = math.floor(v * 60) % 60
				
				return string.format('%02d:%02d', hours, minutes)
			end),
			TextSize = 20,
			TextColor3 = Color3.new(1, 1, 1),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center
		}),
		
		
		Hours = Element('ImageLabel', {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 0.7),
			BackgroundTransparency = 1,
			
			ZIndex = 5,
			
			Rotation = currentTime:map(function(v: number)
				return (v / 12) % 1 * 360
			end),
			
			Image = 'rbxassetid://125755757948111'
		}),
		Minutes = Element('ImageLabel', {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			
			ZIndex = 5,
			
			Rotation = currentTime:map(function(v: number)
				return v * 360
			end),
			
			Image = 'rbxassetid://125755757948111'
		})
	})
}))