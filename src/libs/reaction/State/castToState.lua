local Symbols = require(script.Parent.Parent.Symbols)

local function castToState(target)
	if type(target) == 'table' and target[Symbols.Kind] == Symbols.State then
		return target
	end
	
	return nil
end

return castToState