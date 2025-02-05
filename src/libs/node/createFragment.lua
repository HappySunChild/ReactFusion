local Types = require(script.Parent.Types)
local Symbols = require(script.Parent.Symbols)

local function createFragment(elements: {Types.Element}): Types.Fragment
	local newFragment = {
		[Symbols.Type] = Types.Fragment,
		
		elements = elements
	}
	
	return newFragment
end

return createFragment