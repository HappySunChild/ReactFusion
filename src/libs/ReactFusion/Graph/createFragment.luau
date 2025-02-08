local package = script.Parent.Parent

local Types = require(package.Types)
local Symbols = require(package.Symbols)

local function createFragment(elements: {Types.Element}): Types.Fragment
	local newFragment = table.freeze({
		[Symbols.Type] = Types.Fragment,
		
		elements = table.freeze(elements)
	})
	
	return newFragment
end

return createFragment