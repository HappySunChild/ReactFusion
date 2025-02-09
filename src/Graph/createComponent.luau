local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)
local Renderer = require(package.Renderer)

local ComponentLifecyclePhase = require(script.Parent.ComponentLifecyclePhase)

local assign = require(package.Utility.assign)

local Name = Symbols.named('Name')
local Internal = Symbols.Internal

local ComponentClass = {
	[Symbols.Type] = Types.StatefulComponent,
}

local METATABLE = table.freeze({ __index = ComponentClass })

local function updateComponent(instance)
	local internal = instance[Internal]
	local virtualNode = internal.virtualNode

	instance.lifecyclePhase = ComponentLifecyclePhase.Render

	local renderResult = instance:render()
	Renderer.updateNodeChildren(virtualNode, virtualNode.hostParent, renderResult)

	instance.lifecyclePhase = ComponentLifecyclePhase.Idle
end

local function createComponent(name): Types.StatefulComponent
	local newComponent = setmetatable({
		[Name] = name,
	}, METATABLE)

	newComponent.__index = newComponent

	return newComponent
end

function ComponentClass:setState(newState)
	local internal = self[Internal]

	self.state = assign(self.state, newState)

	if internal.lifecyclePhase == ComponentLifecyclePhase.Idle then
		updateComponent(self)
	end
end

function ComponentClass:render()
	error(`Component "{self[Name]}" is missing the 'render' method.`)
end

table.freeze(ComponentClass)

return createComponent
