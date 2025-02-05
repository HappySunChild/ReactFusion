local package = script.Parent.Parent

local Types = require(package.Types)
local Symbols = require(package.Symbols)
local peek = require(package.State.peek)

local Children = Symbols.Children
local Ref = Symbols.Ref
local Redirect = Symbols.Redirect

local cache = {}

local function getDefaultProperty(className: string, property: string)
	local classCache = cache[className]
	
	if not classCache then
		classCache = Instance.new(className)
		cache[className] = classCache
	end
	
	local success, value = pcall(function()
		return classCache[property]
	end)
	
	if success then
		return value
	end
end


local function applyInstanceProperty(instance: Instance, key: string, value: any)
	if value == nil then
		value = getDefaultProperty(instance.ClassName, key)
	end
	
	local success, err = pcall(function()
		instance[key] = value
	end)
	
	if not success then
		warn(err, key, value)
	end
end

local function connectInstanceEvent(hostNode, eventKey: string, callback)
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




local function bindProperty(hostNode, key: string, value: Types.StateObject<any>?)
	if hostNode.bindings[key] then
		local disconnect = hostNode.bindings[key]
		disconnect()
		
		hostNode.bindings[key] = nil
	end
	
	if not value then
		return
	end
	
	local function changed(newValue)
		applyInstanceProperty(hostNode.hostInstance, key, newValue)
	end
	
	hostNode.bindings[key] = value:onChange(changed)
	
	changed(peek(value))
end


local function applyProperty(hostNode, key: string, value: any?, oldValue: any?)
	if value == oldValue then
		return
	end
	
	if key == Children or key == Ref or key == Redirect then
		return
	end
	
	
	if Types.of(key) == Types.Event then
		connectInstanceEvent(hostNode, key.name, value)
		
		return
	end
	
	
	if Types.kindOf(value) == Symbols.State then
		bindProperty(hostNode, key, value)
		
		return
	elseif Types.kindOf(oldValue) == Symbols.State then
		bindProperty(hostNode, key)
		
		return
	end
	
	applyInstanceProperty(hostNode.hostInstance, key, value)
end

local function applyProperties(hostNode, props, oldProps)
	oldProps = oldProps or {}
	
	for key, value in props do
		local oldValue = oldProps[key]
		
		applyProperty(hostNode, key, value, oldValue)
	end
	
	for key, oldValue in oldProps do
		local newValue = props[key]
		
		if newValue == nil then
			applyProperty(hostNode, key, nil, oldValue)
		end
	end
end

return applyProperties