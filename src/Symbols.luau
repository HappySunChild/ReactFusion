local function named(name)
	local newSymbol = newproxy(true)

	getmetatable(newSymbol).__tostring = function()
		return `<Symbol '{name}'>`
	end

	return newSymbol
end

local Symbols = {
	named = named,
	DebugId = named('DebugId'),

	None = named('None'),

	Type = named('Type'),
	Kind = named('Kind'),
	Internal = named('Internal'),
	Children = named('Children'),
	Signal = named('Signal'),
	Ref = named('Ref'),
	Redirect = named('Redirect'),

	UseParentKey = named('UseParentKey'),

	Validity = named('Validity'),
	LastChange = named('LastChange'),
	CreatedAt = named('CreatedAt'),
	Users = named('Users'),
	Using = named('Using'),
}

return Symbols
