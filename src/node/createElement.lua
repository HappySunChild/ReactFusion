local Symbols = require(script.Parent.Symbols)
local Children = Symbols.Children

local function createElement(component, props, children)
	if props == nil then
		props = {}
	end
	
	if children ~= nil then
		props[Children] = children
	end
	
	local newElement = {
		component = component,
		props = props
	}
	
	return newElement
end

return createElement