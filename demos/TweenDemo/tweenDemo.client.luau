local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Rusion = require(ReplicatedStorage.Libraries.ReactFusion)
local Element = Rusion.createElement
local Value = Rusion.createValue

local size = Value(UDim2.fromOffset(100, 100))

local Frame = Element('Frame', {
	Size = Rusion.createTween(size, TweenInfo.new(0.5)),

	[Rusion.Event.InputBegan] = function(_, input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			size:set(UDim2.fromOffset(math.random(100, 200), math.random(100, 200)))
		end
	end,
})

Rusion.mount(
	Element('ScreenGui', nil, {
		Frame,
	}),
	Players.LocalPlayer.PlayerGui,
	'TweenDemo'
)
