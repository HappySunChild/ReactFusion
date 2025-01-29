local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player.PlayerGui

local gui = Instance.new('ScreenGui')
gui.ResetOnSpawn = false
gui.Parent = playerGui

local Node = require(ReplicatedStorage.Node)

local element = Node.createElement('Frame', {
	Size = UDim2.fromOffset(100, 100)
}, {
	Node.createElement('TextLabel', {
		Size = UDim2.new(1, 0, 0, 15),
		Text = 'Hi'
	})
})

Node.render(element, gui, 'CoolFrame')