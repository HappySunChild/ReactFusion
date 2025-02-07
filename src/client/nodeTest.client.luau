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

player:GetPropertyChangedSignal('Team'):Connect(function()
	local newColor = player.TeamColor.Color
	
	background:tween(newColor, TweenInfo.new(4, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut))
end)

task.wait(4)

frameSizeX:tween(500, TweenInfo.new(4, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut))