--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")


local player = Players.LocalPlayer
local playerGui = player.PlayerGui


local Node = require(ReplicatedStorage.Libraries.node)


local function hoverStart(label: TextLabel)
	label.BorderSizePixel = 1
	label.ZIndex = 100
end

local function hoverEnd(label: TextLabel)
	label.BorderSizePixel = 0
	label.ZIndex = 1
end



local function simpleButton(props, children)
	local text = Node.createValue(props.text)
	
	return Node.createElement('TextButton', {
		BackgroundColor3 = Color3.fromRGB(27, 27, 27),
		BorderColor3 = Color3.new(1, 0, 1),
		TextColor3 = Color3.new(1, 1, 1),
		
		BorderSizePixel = 0,
		
		Position = props.position,
		Size = props.size or UDim2.new(1, 0, 0, 18),
		Text = text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextScaled = true,
		
		[Node.Event.InputBegan] = function(rbx, input: InputObject)
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
		[Node.Event.InputEnded] = function(rbx, input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				hoverEnd(rbx)
				
				if props.hoverText then
					text:set(props.text)
				end
			end
		end
	}, children)
end


local containerSizeX = Node.createValue(50)


local labels = {}

for i = 1, 16 do
	labels[i] = Node.createElement(simpleButton, {
		position = UDim2.fromOffset(0, 18 * (i - 1)),
		text = 'Label',
		hoverText = i,
		
		callback = function()
			containerSizeX:set(i * 10)
		end
	})
end


local container = Node.createElement('Frame', {
	Size = containerSizeX:map(function(xSize)
		return UDim2.fromOffset(xSize, 300)
	end),
}, labels)




local gui = Node.createElement('ScreenGui', {
	ResetOnSpawn = false
}, {
	CoolFrame = container
})

Node.mount(gui, playerGui)

-- hydration example
Node.hydrate(workspace:FindFirstChild('HydrationLabel', true), {
	Text = Node.createComputed(function(use)
		local x = use(containerSizeX)
		
		return 'Hello, I am a hydrated element!\n' .. x
	end),
	
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.5, 0.5),
	
	[Node.Event.MouseEnter] = function(label)
		hoverStart(label)
	end,
	[Node.Event.MouseLeave] = function(label)
		hoverEnd(label)
	end
}, {
	Frame = Node.createElement('Frame')
})