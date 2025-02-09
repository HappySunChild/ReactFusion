local package = script.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local createElement = require(package.Graph.createElement)
local getElementKind = require(package.Utility.getElementKind)
local defaultProperties = require(package.Instance.defaultProperties)
local applyProperties = require(package.Instance.applyProperties)
local assign = require(package.Utility.assign)

local ComponentLifecyclePhase = require(package.Graph.ComponentLifecyclePhase)

local Internal = Symbols.Internal
local Children = Symbols.Children
local Redirect = Symbols.Redirect
local Ref = Symbols.Ref

local Renderer = {}

local function applyRef(ref, hostInstance: Instance?)
	if not ref then
		return
	end

	if type(ref) == 'function' then
		ref(hostInstance)
	elseif Types.of(ref) == Types.Ref then
		ref:set(hostInstance)
	end
end

local function createVirtualNode(element, hostParent: Instance?, hostKey: string?): Types.VirtualNode
	local virtualNode = {
		[Symbols.Type] = Types.VirtualNode,

		currentElement = element,
		hostInstance = nil,
		hostParent = hostParent,
		hostKey = hostKey,

		children = {},

		bindings = {},
		connections = {},

		wasUnmounted = false,
	}

	return virtualNode
end

local function getElementByKey(elementOrElements, key)
	if not elementOrElements then
		return nil
	end

	if Types.of(elementOrElements) == Types.Element then
		if key == Symbols.UseParentKey then
			return elementOrElements
		end

		return nil
	end

	return elementOrElements[key]
end

local function iterateElements(elementOrElements)
	if not elementOrElements then
		return function()
			return nil
		end
	end

	if Types.of(elementOrElements) == Types.Element then
		local debounce = false

		return function()
			if debounce then
				return nil
			end

			debounce = true

			return Symbols.UseParentKey, elementOrElements
		end
	end

	return next, elementOrElements
end

function Renderer.replaceNode(virtualNode: Types.VirtualNode, newElement: Types.Element)
	local hostParent = virtualNode.hostParent
	local hostKey = virtualNode.hostKey

	Renderer.unmount(virtualNode)

	return Renderer.mount(newElement, hostParent, hostKey)
end

function Renderer.updateNode(virtualNode: Types.VirtualNode, newElement: Types.Element | Types.Fragment)
	local currentElement = virtualNode.currentElement

	if not newElement then
		Renderer.unmount(virtualNode)

		return
	end

	if currentElement.component ~= newElement.component then
		return Renderer.replaceNode(virtualNode, newElement)
	end

	local kind = getElementKind(newElement)

	if kind == Symbols.Host or kind == Symbols.Hydration then
		local props = newElement.props

		if virtualNode.hostInstance then
			applyProperties(virtualNode, props, currentElement.props)
		end

		local children = props[Children]

		if children then
			Renderer.updateNodeChildren(virtualNode, virtualNode.hostInstance, children)
		end
	elseif kind == Symbols.Fragment then
		Renderer.updateNodeChildren(virtualNode, virtualNode.hostParent, newElement.elements)
	end

	virtualNode.currentElement = newElement

	return virtualNode
end

function Renderer.updateNodeChildren(
	virtualNode: Types.VirtualNode,
	hostParent: Instance?,
	newChildren: { Types.Element } | Types.Element
)
	local remove = {}

	for childKey, childNode in virtualNode.children do
		local newElement = getElementByKey(newChildren, childKey)
		local newNode = Renderer.updateNode(childNode, newElement)

		if newNode then
			virtualNode.children[childKey] = newNode
		else
			remove[childKey] = true
		end
	end

	for childKey in remove do
		virtualNode.children[childKey] = nil
	end

	for childKey, childElement in iterateElements(newChildren) do
		local useKey = childKey

		if childKey == Symbols.UseParentKey then
			useKey = virtualNode.hostKey
		end

		if virtualNode.children[childKey] then
			continue
		end

		local childNode = Renderer.mount(childElement, hostParent, useKey)

		if childNode then
			virtualNode.children[childKey] = childNode
		end
	end
end

local function mountHydrateNode(virtualNode: Types.VirtualNode)
	local element = virtualNode.currentElement
	local props = element.props

	assert(props.Name == nil, 'Name can not be passed as a property!')
	assert(props.Parent == nil, 'Parent can not be passed as a property!')

	local hostInstance = element.component

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
		Renderer.updateNodeChildren(virtualNode, hostInstance, children)
	end

	applyRef(props[Ref], hostInstance)
end

local function mountHostNode(virtualNode: Types.VirtualNode)
	local hostElement = virtualNode.currentElement

	local className = hostElement.component
	local props = hostElement.props

	assert(type(className) == 'string', 'Expected "component" field of passed element to be a string!')

	assert(props.Name == nil, 'Name can not be passed as a property!')
	assert(props.Parent == nil, 'Parent can not be passed as a property!')

	local hostInstance = Instance.new(className)
	virtualNode.hostInstance = hostInstance

	local default = defaultProperties[className]

	if default then
		for key, value in default do
			hostInstance[key] = value
		end
	end

	applyProperties(virtualNode, props)

	local children = props[Children]

	if children then
		Renderer.updateNodeChildren(virtualNode, hostInstance, children)
	end

	hostInstance.Name = tostring(virtualNode.hostKey)
	hostInstance.Parent = virtualNode.hostParent

	applyRef(props[Ref], hostInstance)
end

local function mountStatefulNode(virtualNode: Types.VirtualNode)
	local currentElement = virtualNode.currentElement

	local internal = {
		virtualNode = virtualNode,
		lifecyclePhase = ComponentLifecyclePhase.Init,
	}

	local instance = setmetatable({
		[Internal] = internal,

		props = assign({}, currentElement.props),
		state = {},
	}, currentElement.component)

	virtualNode.componentInstance = instance

	if instance.init then
		instance:init(instance.props)
	end

	internal.lifecyclePhase = ComponentLifecyclePhase.Render

	local renderResult = instance:render()
	Renderer.updateNodeChildren(virtualNode, virtualNode.hostParent, renderResult)

	if instance.didMount then
		internal.lifecyclePhase = ComponentLifecyclePhase.DidMount
		instance:didMount()
	end

	internal.lifecyclePhase = ComponentLifecyclePhase.Idle
end

function Renderer.mount(element: Types.Element, hostParent: Instance?, key: string?): Types.VirtualNode
	if key == nil then
		key = 'NodeTree'
	end

	local component = element.component
	local props = element.props
	local kind = getElementKind(element)

	if props and props[Redirect] then
		hostParent = props[Redirect]
	end

	local virtualNode = createVirtualNode(element, hostParent, key)

	if kind == Symbols.Host then
		mountHostNode(virtualNode)
	elseif kind == Symbols.Hydration then
		mountHydrateNode(virtualNode)
	elseif kind == Symbols.Function then
		local result = component(props, props[Children])

		Renderer.updateNodeChildren(virtualNode, hostParent, result)
	elseif kind == Symbols.Fragment then
		Renderer.updateNodeChildren(virtualNode, hostParent, element.elements)
	elseif kind == Symbols.Stateful then
		mountStatefulNode(virtualNode)
	else
		error(`Invalid element component, {typeof(component)} '{component}' Kind {kind}`, 2)
	end

	return virtualNode
end

function Renderer.unmount(virtualNode: Types.VirtualNode)
	if virtualNode.wasUnmounted then
		return
	end

	virtualNode.wasUnmounted = true

	local currentElement = virtualNode.currentElement
	local hostInstance = virtualNode.hostInstance
	local componentInstance = virtualNode.componentInstance

	if componentInstance and componentInstance.willUnmount then
		componentInstance[Internal].lifecyclePhase = ComponentLifecyclePhase.WillUnmount
		componentInstance:willUnmount()
	end

	for _, childNode in virtualNode.children do
		Renderer.unmount(childNode)
	end

	applyRef(currentElement.props[Ref], nil)

	if hostInstance then
		hostInstance:Destroy()
	end

	for _, disconnect in virtualNode.bindings do
		disconnect()
	end

	for _, connection in virtualNode.connections do
		connection:Disconnect()
	end
end

function Renderer.hydrate(target: Instance, props: Types.Properties, children: { Types.Element }?)
	local element = createElement(target, props, children)

	return Renderer.mount(element)
end

function Renderer.reconcile(virtualNode: Types.VirtualNode, newElement: Types.Element?)
	Renderer.updateNode(virtualNode, newElement or virtualNode.currentElement)
end

return Renderer
