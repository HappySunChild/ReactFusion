local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reaction = require(ReplicatedStorage.Libraries.reaction)

local Value = Reaction.Value
local Computed = Reaction.Computed

local peek = Reaction.peek

local function preek(...)
	local args = {...}
	
	for index, target in args do
		args[index] = peek(target)
	end
	
	print(unpack(args))
end


local number = Value(10)

local plusOne = Computed(function(use)
	return use(number) + 1
end)

local plusTwo = Computed(function(use)
	return use(plusOne) + 1
end)

preek(number, plusOne, plusTwo)

number:set(0)

preek(number, plusOne, plusTwo)