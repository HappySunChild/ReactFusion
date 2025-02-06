local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")


local player = Players.LocalPlayer


local Rusion = require(ReplicatedStorage.Libraries.ReactFusion)

local frameSizeX = Rusion.createValue(0)
local background = Rusion.createValue(player.TeamColor.Color)

Rusion.mount(Rusion.createElement('ScreenGui', nil, {
	Frame = Rusion.createElement('Frame', {
		BackgroundColor3 = background,
		Size = frameSizeX:map(function(v)
			return UDim2.fromOffset(v, 100)
		end)
	})
}), player.PlayerGui)

frameSizeX:tween(100, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out))

player:GetPropertyChangedSignal('TeamColor'):Connect(function()
	local newColor = player.TeamColor.Color
	
	background:tween(newColor, TweenInfo.new(3, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut))
end)