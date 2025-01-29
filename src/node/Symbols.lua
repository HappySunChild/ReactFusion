local function createSymbol(name)
	local newSymbol = newproxy(true)
	
	getmetatable(newSymbol).__tostring = function()
		return `<Symbol {name}>`
	end
	
	return newSymbol
end

local symbols = {}
symbols.Children = createSymbol('Children')

return symbols