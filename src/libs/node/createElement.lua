local Symbols = require(script.Parent.Symbols)
local Types = require(script.Parent.Types)

type element = Types.Element
type component = Types.ElementComponent
type props = Types.ElementProps

local Children = Symbols.Children

local function createElement(component: component, props: props, children: {element}?): element
	if props == nil then
		props = {}
	end
	
	if children ~= nil then
		props[Children] = children
	end
	
	local newElement = {
		[Symbols.Type] = Types.Element,
		
		component = component,
		props = props
	}
	
	return newElement
end

return createElement