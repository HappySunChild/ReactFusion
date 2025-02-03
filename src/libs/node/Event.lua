local Symbols = require(script.Parent.Symbols)
local Types = require(script.Parent.Types)

return setmetatable({}, {
	__index = function(self, name)
		local event = {
			[Symbols.Type] = Types.Event,
			name = name
		}
		
		self[name] = event
		
		return event
	end
})