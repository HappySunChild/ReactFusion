local package = script.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local createElement = require(package.createElement)
local getElementKind = require(package.getElementKind)
local defaultProperties = require(package.Instance.defaultProperties)
local applyProperties = require(package.Instance.applyProperties)

local Children = Symbols.Children
local Redirect = Symbols.Redirect
local Ref = Symbols.Ref


local renderer = {}


local function applyRef(ref, hostInstance: Instance)
	if not ref then
		return
	end
	
	if type(ref) == 'function' then
		ref(hostInstance)
	elseif Types.of(ref) == Types.Ref then
		ref:set(hostInstance)
	end
end

local function createVirtualNode(element, hostParent: Instance, hostKey: string?)
	local virtualNode = {
		[Symbols.Type] = Types.VirtualNode,
		
		currentElement = element,
		hostInstance = nil,
		hostParent = hostParent,
		hostKey = hostKey,
		
		children = {},
		
		bindings = {},
		connections = {}
	}
	
	return virtualNode
end



local function iterateElements(elementOrElements)
	if Types.of(elementOrElements) == Types.Element then
		local debounce = false
		
		return function ()
			if debounce then
				return nil
			end
			
			debounce = true
			
			return Symbols.UseParentKey, elementOrElements
		end
	end
	
	return next, elementOrElements
end



function renderer.updateNode(virtualNode, newElement: Types.Element)
	local currentElement = virtualNode.currentElement
	
	if currentElement == newElement then
		return virtualNode
	end
	
	if not newElement then
		renderer.unmountNode(virtualNode)
		
		return
	end
	
	if virtualNode.hostInstance then
		applyProperties(virtualNode, currentElement.props, newElement.props)
	end
end

function renderer.updateNodeChildren(virtualNode, hostParent: Instance, newChildren: {Types.Element}|Types.Element)
	for childKey, childElement in iterateElements(newChildren) do
		local useKey = childKey
		
		if childKey == Symbols.UseParentKey then
			useKey = virtualNode.hostKey
			childKey = 1
		end
		
		local childNode = renderer.mount(childElement, hostParent, useKey)
		
		if childNode then
			virtualNode.children[childKey] = childNode
		end
	end
end



function renderer.hydrateNode(virtualNode, hostInstance: Instance)
	local element = virtualNode.currentElement
	local props = element.props
	
	assert(props.Name == nil, 'Name can not be passed as a property!')
	assert(props.Parent == nil, 'Parent can not be passed as a property!')
	
	-- im still not entirely sure about this behavior,
	-- i think they should act like redirects.
	
	-- if virtualNode.hostParent ~= nil then
	-- 	hostInstance.Parent = virtualNode.hostParent
	-- end
	
	-- redirect behavior
	virtualNode.hostParent = hostInstance.Parent
	
	virtualNode.hostInstance = hostInstance
	virtualNode.hostKey = hostInstance.Name
	
	applyProperties(virtualNode, props)
	
	
	-- another thing i'm thinking about it automatically translating all of the
	-- children of the instance into virtual nodes, but i think that is also very unnecessary
	local children = props[Children]
	
	if children then
		renderer.updateNodeChildren(virtualNode, hostInstance, children)
	end
	
	applyRef(props[Ref], hostInstance)
end

function renderer.renderHostNode(hostNode, hostParent: Instance)
	local hostElement = hostNode.currentElement
	
	local className = hostElement.component
	local props = hostElement.props
	
	assert(type(className) == 'string', 'Expected "component" field of passed element to be a string!')
	
	assert(props.Name == nil, 'Name can not be passed as a property!')
	assert(props.Parent == nil, 'Parent can not be passed as a property!')
	
	
	local hostInstance = Instance.new(className)
	hostNode.hostInstance = hostInstance
	
	local default = defaultProperties[className]
	
	if default then
		for key, value in default do
			hostInstance[key] = value
		end
	end
	
	applyProperties(hostNode, props)
	
	
	local children = props[Children]
	
	if children then
		renderer.updateNodeChildren(hostNode, hostInstance, children)
	end
	
	
	hostInstance.Name = tostring(hostNode.hostKey)
	hostInstance.Parent = hostParent
	
	
	applyRef(props[Ref], hostInstance)
end



function renderer.mount(element, hostParent: Instance?, key: string?)
	if key == nil then
		key = 'NodeTree'
	end
	
	local kind = getElementKind(element)
	
	local component = element.component
	local props = element.props
	
	if props[Redirect] then
		hostParent = props[Redirect]
	end
	
	local virtualNode = createVirtualNode(element, hostParent, key)
	
	if kind == Symbols.Host then
		renderer.renderHostNode(virtualNode, hostParent)
	elseif kind == Symbols.Hydration then
		renderer.hydrateNode(virtualNode, component)
	elseif kind == Symbols.Function then
		local result = component(props, props[Children])
		
		renderer.updateNodeChildren(virtualNode, hostParent, result)
	elseif kind == Symbols.Fragment then
		renderer.updateNodeChildren(virtualNode, hostParent, element.elements)
	else
		error(`Invalid element component, {typeof(component)} '{component}'`, 2)
	end
	
	return virtualNode
end

function renderer.unmountNode(virtualNode)
	for _, childNode in virtualNode.children do
		renderer.unmountNode(childNode)
	end
	
	local element = virtualNode.element
	
	if element then
		applyRef(element.props[Ref], nil)
	end
	
	if virtualNode.hostInstance then
		virtualNode.hostInstance:Destroy()
	end
	
	for _, disconnect in virtualNode.bindings do
		disconnect()
	end
	
	for _, connection in virtualNode.connections do
		connection:Disconnect()
	end
end

function renderer.hydrate(target: Instance, props: Types.ElementProps, children: {Types.Element}?)
	local element = createElement(target, props, children)
	
	return renderer.mount(element)
end

return renderer