local Types = require(script.Parent.Types)
local Symbols = require(script.Parent.Symbols)

local function createFragment(elements: {Types.Element}): Types.Fragment
	local newFragment = table.freeze({
		[Symbols.Type] = Types.Fragment,
		
		elements = table.freeze(elements)
	})
	
	return newFragment
end

return createFragment