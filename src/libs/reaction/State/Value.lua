local Symbols = require(script.Parent.Parent.Symbols)
local Types = require(script.Parent.Parent.Types)

local createSignal = require(script.Parent.Parent.createSignal)

local ValueClass = {
	[Symbols.Kind] = Symbols.State,
	[Symbols.Type] = Types.Value
}

local METATABLE = table.freeze({__index = ValueClass})

local function Value(initialValue)
	local newValue = setmetatable({
		[Symbols.HiddenValue] = initialValue,
		[Symbols.Signal] = createSignal()
	}, METATABLE)
	
	return newValue
end


function ValueClass:set(newValue)
	local signal = self[Symbols.Signal]
	local oldValue = self[Symbols.HiddenValue]
	
	self[Symbols.HiddenValue] = newValue
	
	signal:fire(newValue, oldValue)
	
	return newValue
end

function ValueClass:update(predicate)
	local currentValue = self[Symbols.HiddenValue]
	
	return self:set(predicate(currentValue))
end

function ValueClass:onChange(callback)
	return self[Symbols.Signal]:connect(callback)
end

return Value