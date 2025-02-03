local Symbols = require(script.Parent.Symbols)

local function createType(name)
	local newType = newproxy(true)
	
	getmetatable(newType).__tostring = function()
		return `<Type '{name}'>`
	end
	
	return newType
end

local Types = {}
Types.Type = Symbols.Type

Types.Binding = createType('Binding')
Types.Event = createType('Event')
Types.Ref = createType('Ref')
Types.Fragment = createType('Fragment')
Types.Element = createType('Element')
Types.Node = createType('Node')

function Types.of(value)
	local vType = type(value)
	
	if vType == 'table' then
		if value[Symbols.Type] then
			return value[Symbols.Type]
		end
	end
	
	return vType
end

function Types.kind(element)
	local compType = type(element.component)
	
	if compType == 'string' then
		return Symbols.Host
	elseif compType == 'function' then
		return Symbols.Function
	elseif Types.of(element) == Types.Fragment then
		return Symbols.Fragment
	end
end

return Types