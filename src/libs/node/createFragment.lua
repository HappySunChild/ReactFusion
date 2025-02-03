local Types = require(script.Parent.Types)

local function createFragment(elements)
	local newFragment = {
		[Types.Type] = Types.Fragment,
		elements = elements
	}
	
	return newFragment
end

return createFragment