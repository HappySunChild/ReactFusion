local function createType(typeName)
	local newSymbol = newproxy(true)
	
	local metatable = getmetatable(newSymbol)
	metatable.__tostring = function()
		return `<Type {typeName}>`
	end
	
	table.freeze(metatable)
	
	return newSymbol
end

local Types = {}
Types.Value = createType('Value')
Types.Observer = createType('Observer')
Types.Computed = createType('Computed')

return Types