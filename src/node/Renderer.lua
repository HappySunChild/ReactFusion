local Symbols = require(script.Parent.Symbols)
local Children = Symbols.Children

local renderer = {}

function renderer.applyProperty(host, key, value)
	if key == Children then
		return
	end
	
	local success, err = pcall(function()
		host[key] = value
	end)
	
	if not success then
		warn(`Unable to apply property '{key}' with value '{value}' to`, host, err)
	end
end

function renderer.applyProperties(host, properties)
	for key, value in properties do
		renderer.applyProperty(host, key, value)
	end
end

function renderer.render(element, parent, key)
	if key == nil then
		key = 'Element'
	end
	
	local hostInstance = Instance.new(element.component)
	
	local props = element.props
	renderer.applyProperties(hostInstance, props)
	
	if props[Children] then
		for childKey, childElement in props[Children] do
			renderer.render(childElement, hostInstance, childKey)
		end
	end
	
	
	hostInstance.Name = key
	hostInstance.Parent = parent
	
	return hostInstance
end

return renderer