local Symbols = require(script.Parent.Parent.Symbols)
local Types = require(script.Parent.Parent.Types)

local castToState = require(script.Parent.castToState)
local evaluate = require(script.Parent.evaluate)

local function peek<T>(target: Types.StateObject<T> | T): T
	if castToState(target) then
		evaluate(target)
		
		return target[Symbols.Internal] :: T
	end
	
	return target :: T
end

return peek