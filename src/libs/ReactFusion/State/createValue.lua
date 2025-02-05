local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local createSignal = require(package.createSignal)
local createComputed = require(script.Parent.createComputed)

local ValueClass = {
	[Symbols.Kind] = Symbols.State,
	[Symbols.Type] = Types.Value
}

local METATABLE = table.freeze({__index = ValueClass})

local function createValue<V>(initialValue: V): Types.Value<V>
	local newValue = setmetatable({
		[Symbols.Secret] = initialValue,
		[Symbols.Signal] = createSignal()
	}, METATABLE)
	
	return newValue
end

function ValueClass:onChange(callback)
	return self[Symbols.Signal]:connect(callback)
end

function ValueClass:set(newValue)
	local signal = self[Symbols.Signal]
	local oldValue = self[Symbols.Secret]
	
	self[Symbols.Secret] = newValue
	
	signal:fire(newValue, oldValue)
	
	return newValue
end

function ValueClass:update(predicate)
	local currentValue = self[Symbols.Secret]
	
	return self:set(predicate(currentValue))
end

function ValueClass:map(callback)
	return createComputed(function(use)
		return callback(use(self))
	end)
end

return createValue