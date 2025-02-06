local Types = require(script.Parent.Types)
local Symbols = require(script.Parent.Symbols)

local RefClass = {
	[Symbols.Type] = Types.Ref
}

local METATABLE = table.freeze({__index = RefClass})

local function createRef(): Types.Ref
	local ref = setmetatable({
		[Symbols.Type] = Types.Ref,
		[Symbols.Internal] = nil
	}, METATABLE)

	return ref
end

function RefClass:set(instance)
	self[Symbols.Internal] = instance
end

function RefClass:get()
	return self[Symbols.Internal]
end

return createRef