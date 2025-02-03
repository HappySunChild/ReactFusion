local Symbols = require(script.Parent.Symbols)
local Types = require(script.Parent.Types)

local createSignal = require(script.Parent.createSignal)


local Bindings = {}

local Binding = {
	[Symbols.Type] = Types.Binding
}
local Mapped = {
	[Symbols.Type] = Types.Binding
}

function Bindings.createMapped(predicate, binding)
	local newMapped = setmetatable({
		_predicate = predicate,
		_binding = binding,
		[Symbols.Signal] = binding[Symbols.Signal]
	}, {__index = Mapped})
	
	return newMapped
end

function Mapped:get()
	return self._predicate(self._binding:get())
end

function Mapped:subscribe(callback)
	return self[Symbols.Signal]:Connect(function(newValue)
		callback(self._predicate(newValue))
	end)
end




function Bindings.createBinding(initialValue)
	local newBinding = setmetatable({
		_value = initialValue,
		[Symbols.Signal] = createSignal()
	}, {__index = Binding})
	
	return newBinding
end

function Binding:get()
	return self._value
end

function Binding:set(newValue)
	self._value = newValue
	self[Symbols.Signal]:Fire(newValue)
end

function Binding:update(callback)
	self:set(callback(self._value))
end

function Binding:subscribe(callback)
	return self[Symbols.Signal]:Connect(callback)
end

function Binding:map(predicate)
	return Bindings.createMapped(predicate, self)
end

return Bindings