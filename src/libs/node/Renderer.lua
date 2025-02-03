local Symbols = require(script.Parent.Symbols)
local Types = require(script.Parent.Types)
local applyInstanceProperty = require(script.Parent.applyInstanceProperty)

local Children = Symbols.Children
local Ref = Symbols.Ref


local renderer = {}


local function connectInstanceEvent(hostNode, eventKey, callback)
	local instance = hostNode.hostInstance
	
	if hostNode.connections[eventKey] then
		hostNode.connections[eventKey]:Disconnect()
	end
	
	if not callback then
		return
	end
	
	local success, err = pcall(function()
		hostNode.connections[eventKey] = instance[eventKey]:Connect(function(...)
			callback(instance, ...)
		end)
	end)
	
	if not success then
		warn(err, eventKey)
	end
end




local function removeBinding(hostNode, key)
	local disconnect = hostNode.bindings[key]
	disconnect()
	
	hostNode.bindings[key] = nil
end

local function applyBinding(hostNode, key, binding)
	local function changed(newValue)
		applyInstanceProperty(hostNode.hostInstance, key, newValue)
	end
	
	if hostNode.bindings[key] then
		removeBinding(hostNode, key)
	end
	
	hostNode.bindings[key] = binding:subscribe(changed)
	
	changed(binding:get())
end



local function applyProperty(hostNode, key, value, oldValue)
	if value == oldValue then
		return
	end
	
	if key == Children or key == Ref then
		return
	end
	
	if Types.of(key) == Types.Event then
		connectInstanceEvent(hostNode, key.name, value)
		
		return
	end
	
	if Types.of(value) == Types.Binding then
		applyBinding(hostNode, key, value)
		
		return
	elseif Types.of(oldValue) == Types.Binding then
		removeBinding(hostNode, key)
		
		return
	end
	
	applyInstanceProperty(hostNode.hostInstance, key, value)
end

local function applyProperties(hostNode, properties)
	for key, value in properties do
		applyProperty(hostNode, key, value)
	end
	
	if hostNode.bindings then
		for key, _ in hostNode.bindings do
			if Types.of(properties[key]) ~= Types.Binding then
				removeBinding(hostNode, key)
			end
		end
	end
end

local function updateProperties(hostNode, oldProperties, newProperties)
	for key, newValue in newProperties do
		local oldValue = oldProperties[key]
		
		applyProperty(hostNode, key, newValue, oldValue)
	end
	
	for key, oldValue in oldProperties do
		local newValue = newProperties[key]
		
		if newValue == nil then
			applyProperty(hostNode, key, nil, oldValue)
		end
	end
end


local function applyRef(ref, hostInstance)
	if not ref then
		return
	end
	
	if type(ref) == 'function' then
		ref(hostInstance)
	elseif Types.of(ref) == Types.Ref then
		ref:set(hostInstance)
	end
end

local function createVirtualNode(element, hostParent)
	local virtualNode = {
		[Types.Type] = Types.Node,
		
		currentElement = element,
		hostInstance = nil,
		hostParent = hostParent,
		
		children = {},
		
		bindings = {},
		connections = {}
	}
	
	return virtualNode
end




function renderer.updateNode(virtualNode, newElement)
	local currentElement = virtualNode.currentElement
	
	if currentElement == newElement then
		return virtualNode
	end
	
	if not newElement then
		renderer.unmountNode(virtualNode)
		
		return
	end
	
	if virtualNode.hostInstance then
		updateProperties(virtualNode, currentElement.props, newElement.props)
	end
end

function renderer.updateNodeChildren(virtualNode, hostParent, newChildren)
	for childKey, childElement in newChildren do
		local childNode = renderer.mount(childElement, hostParent, childKey)
		
		if childNode then
			virtualNode.children[childKey] = childNode
		end
	end
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

function renderer.renderNode(hostNode, hostParent, key)
	local hostElement = hostNode.currentElement
	
	local component = hostElement.component
	local props = hostElement.props
	
	assert(type(component) == 'string', 'Expected "component" field of passed element to be a string!')
	
	assert(props.Name == nil, 'Name can not be passed as a property!')
	assert(props.Parent == nil, 'Parent can not be passed as a property!')
	
	
	local hostInstance = Instance.new(component)
	hostNode.hostInstance = hostInstance
	
	applyProperties(hostNode, props)
	
	
	local children = props[Children]
	
	if children then
		renderer.updateNodeChildren(hostNode, hostInstance, children)
	end
	
	
	hostInstance.Name = tostring(key)
	hostInstance.Parent = hostParent
	
	
	applyRef(props[Ref], hostInstance)
end

function renderer.mount(element, hostParent, key)
	if key == nil then
		key = 'NodeTree'
	end
	
	local kind = Types.kind(element)
	
	local component = element.component
	local props = element.props
	
	local virtualNode = createVirtualNode(element, hostParent)
	
	if kind == Symbols.Host then
		renderer.renderNode(virtualNode, hostParent, key)
	elseif kind == Symbols.Function then
		local result = component(props, props[Children])
		
		renderer.updateNodeChildren(virtualNode, hostParent, {result})
	elseif kind == Symbols.Fragment then
		print('fragment')
		print(element)
		
		renderer.updateNodeChildren(virtualNode, hostParent, element.elements)
	else
		error(element, 2)
	end
	
	return virtualNode
end

return renderer