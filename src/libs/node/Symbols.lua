local function symbol(name)
	local newSymbol = newproxy(true)
	
	getmetatable(newSymbol).__tostring = function()
		return `<Symbol '{name}'>`
	end
	
	return newSymbol
end

local Symbols = {
	Children = symbol('Children'),
	Signal = symbol('Signal'),
	Type = symbol('Type'),
	Ref = symbol('Ref'),
	
	Host = symbol('Host'),
	Function = symbol('Function'),
	Fragment = symbol('Fragment')
}

return Symbols