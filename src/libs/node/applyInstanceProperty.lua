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

return applyInstanceProperty