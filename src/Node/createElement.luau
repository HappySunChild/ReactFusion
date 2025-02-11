local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local Children = Symbols.Children

local function createElement(component: Types.Component, props: Types.Properties?, children: {Types.Element}?): Types.Element
	if props == nil then
		props = {}
	end
	
	if children ~= nil then
		props[Children] = children
	end
	
	local newElement = table.freeze({
		[Symbols.Type] = Types.Element,
		
		component = component,
		props = props
	})
	
	return newElement
end

return createElement