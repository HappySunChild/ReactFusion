local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")


local player = Players.LocalPlayer


local Rusion = require(ReplicatedStorage.Libraries.ReactFusion)


local testComponent = Rusion.createComponent('TestComponent')

function testComponent:init()
	task.spawn(function()
		task.wait(4)
		
		self:setState({evil = true})
	end)
end

function testComponent:render()
	local state = self.state
	
	local children = {}
	local backgroundColor = Color3.new(1, 1, 1)
	
	if state.evil then
		backgroundColor = Color3.new(1, 0, 0)
		
		children.Label = Rusion.createElement('TextLabel', {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = 'EVIL!!'
		})
	end
	
	return Rusion.createElement('Frame', {
		Size = UDim2.fromOffset(100, 100),
		BackgroundColor3 = backgroundColor,
		
		[Rusion.Event.MouseLeave] = function()
			self:setState({evil = false})
		end,
		[Rusion.Event.MouseEnter] = function()
			self:setState({evil = true})
		end
	}, children)
end

Rusion.mount(Rusion.createElement('ScreenGui', nil, {
	Component = Rusion.createElement(testComponent)
}), player.PlayerGui)