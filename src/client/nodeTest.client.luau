--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")


local player = Players.LocalPlayer


local Rusion = require(ReplicatedStorage.Libraries.ReactFusion)

local testComponent = Rusion.Component:extend('test')

function testComponent:init()
	print('init')
end

function testComponent:render()
	print('hello')
	
	return Rusion.createElement('Frame', {
		Size = UDim2.fromOffset(100, 100)
	})
end

Rusion.mount(Rusion.createElement('ScreenGui', nil, {
	Rusion.createElement(testComponent)
}), player.PlayerGui)