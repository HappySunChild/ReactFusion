local package = script.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)
local Renderer = require(package.Renderer)

local assign = require(package.assign)

local Name = Symbols.named('Name')
local Internal = Symbols.named('Internal')


local METATABLE = table.freeze({
	__tostring = function(self)
		return self[Name]
	end
})

local Component = setmetatable({
	[Symbols.Type] = Types.StatefulComponent,
	[Name] = 'Component'
}, METATABLE)
Component.__index = Component


function Component:extend(name: string)
	local newComponent = setmetatable({}, METATABLE)
	
	for key, value in self do
		if key == 'extend' then
			continue
		end
		
		newComponent[key] = value
	end
	
	newComponent[Name] = name
	newComponent.__index = newComponent
	
	return newComponent
end

function Component:render()
	error(`Component "{self[Name]}" is missing the 'render' method.`)
end

function Component:setState(newState)
	self.state = newState
end


-- init
-- didMount
-- willUnmount


function Component:__mount(virtualNode: Types.VirtualNode)
	local currentElement = virtualNode.currentElement
	local hostParent = virtualNode.hostParent
	
	local instance = setmetatable({
		[Internal] = {
			node = virtualNode
		},
		props = assign({}, currentElement.props),
		state = {}
	}, self)
	
	if instance.init then
		instance:init(instance.props)
	end
	
	local result = instance:render()
	Renderer.updateNodeChildren(virtualNode, hostParent, result)
	
	if instance.didMount then
		instance:didMount()
	end
end

return Component