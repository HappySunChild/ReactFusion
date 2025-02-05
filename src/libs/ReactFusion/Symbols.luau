local function named(name)
	local newSymbol = newproxy(true)
	
	getmetatable(newSymbol).__tostring = function()
		return `<Symbol '{name}'>`
	end
	
	return newSymbol
end

local Symbols = {
	named = named,
	
	Type = named('Type'),
	Kind = named('Kind'),
	
	Secret = named('Secret'),
	Children = named('Children'),
	Signal = named('Signal'),
	Ref = named('Ref'),
	Redirect = named('Redirect'),
	
	UseParentKey = named('UseParentKey'),
	
	-- kinds
	Host = named('Host'),
	Function = named('Function'),
	Fragment = named('Fragment'),
	Hydration = named('Hydration'),
	Stateful = named('Stateful'),
	
	State = named('State')
}

return Symbols