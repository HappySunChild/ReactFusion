local Symbols = require(script.Parent.Parent.Symbols)

local castToState = require(script.Parent.castToState)
local evaluate = require(script.Parent.evaluate)

local function peek(target)
	if castToState(target) then
		evaluate(target)
		
		return target[Symbols.HiddenValue]
	end
	
	return target
end

return peek