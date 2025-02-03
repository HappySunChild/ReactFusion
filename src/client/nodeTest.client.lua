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


local function simpleLabel(props, children)
	local text = Node.createBinding(props.text)
	
	return Node.createElement('TextLabel', {
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





local labels = {}


for i = 1, 10 do
	labels[i] = Node.createElement(simpleLabel, {
		position = UDim2.fromOffset(0, 19 * (i - 1)),
		text = 'Label',
		hoverText = i
	})
end


local container = Node.createElement('Frame', {
	Size = UDim2.fromOffset(100, 300),
	
	[Node.Event.MouseEnter] = function(rbx: Frame)
		rbx.BackgroundColor3 = Color3.new(math.random(), math.random(), math.random())
	end
}, {
	Node.createFragment(labels)
})




local gui = Node.createElement('ScreenGui', {
	ResetOnSpawn = false
}, {
	container
})


Node.mount(gui, playerGui)