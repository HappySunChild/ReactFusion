--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")


local player = Players.LocalPlayer
local playerGui = player.PlayerGui


local Rusion = require(ReplicatedStorage.Libraries.ReactFusion)


local function hoverStart(label: TextLabel)
	label.BorderSizePixel = 1
	label.ZIndex = 100
end

local function hoverEnd(label: TextLabel)
	label.BorderSizePixel = 0
	label.ZIndex = 1
end



local function simpleButton(props, children)
	local text = Rusion.createValue(props.text)
	
	return Rusion.createElement('TextButton', {
		BackgroundColor3 = Color3.fromRGB(27, 27, 27),
		BorderColor3 = Color3.new(1, 0, 1),
		TextColor3 = Color3.new(1, 1, 1),
		
		BorderSizePixel = 0,
		
		Position = props.position,
		Size = props.size or UDim2.new(1, 0, 0, 18),
		Text = text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextScaled = true,
		
		[Rusion.Event.InputBegan] = function(rbx, input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				hoverStart(rbx)
				
				if props.hoverText then
					text:set(props.hoverText)
				end
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
				if props.callback then
					props.callback()
				end
			end
		end,
		[Rusion.Event.InputEnded] = function(rbx, input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				hoverEnd(rbx)
				
				if props.hoverText then
					text:set(props.text)
				end
			end
		end
	}, children)
end


local containerSizeX = Rusion.createValue(50)


local labels = {}

for i = 1, 16 do
	labels[i] = Rusion.createElement(simpleButton, {
		position = UDim2.fromOffset(0, 18 * (i - 1)),
		text = 'Label',
		hoverText = i,
		
		callback = function()
			containerSizeX:set(i * 10)
		end
	})
end


local container = Rusion.createElement('Frame', {
	Size = containerSizeX:map(function(xSize)
		return UDim2.fromOffset(xSize, 300)
	end),
}, labels)




local gui = Rusion.createElement('ScreenGui', {
	ResetOnSpawn = false
}, {
	CoolFrame = container
})

Rusion.mount(gui, playerGui)

-- hydration example
Rusion.hydrate(workspace:FindFirstChild('HydrationLabel', true), {
	Text = Rusion.createComputed(function(use)
		local x = use(containerSizeX)
		
		return 'Hello, I am a hydrated element!\n' .. x
	end),
	
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.5, 0.5),
	
	[Rusion.Event.MouseEnter] = function(label)
		hoverStart(label)
	end,
	[Rusion.Event.MouseLeave] = function(label)
		hoverEnd(label)
	end
}, {
	Frame = Rusion.createElement('Frame')
})