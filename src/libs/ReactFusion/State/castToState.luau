local Symbols = require(script.Parent.Parent.Symbols)
local Types = require(script.Parent.Parent.Types)

local function castToState(target)
	if Types.kindOf(target) == Symbols.State then
		return target
	end
	
	return nil
end

return castToState