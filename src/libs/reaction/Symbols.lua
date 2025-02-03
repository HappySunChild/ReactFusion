local function createSymbol(symbolName)
	local newSymbol = newproxy(true)
	
	local metatable = getmetatable(newSymbol)
	metatable.__tostring = function()
		return `<Symbol {symbolName}>`
	end
	
	table.freeze(metatable)
	
	return newSymbol
end

local Symbols = {}
Symbols.Type = createSymbol('Type')
Symbols.Kind = createSymbol('Kind')
Symbols.State = createSymbol('State')

Symbols.Signal = createSymbol('Signal')
Symbols.HiddenValue = createSymbol('HiddenValue')

return Symbols