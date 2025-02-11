local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Rusion = require(ReplicatedStorage.Libraries.ReactFusion)

local Name = Rusion.createValue(workspace.Value.Value, 'Value')
Name:bindToInstanceProperty(workspace.Value, 'Value')

Name:onChange(function(new)
	print(new)
end)

local Greetings = Name:map(function(v)
	print('greetings recomputed', v)

	return `Hello, {v}!`
end)

Greetings:onChange(function(new)
	print(new)
end)
