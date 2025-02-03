local Symbols = require(script.Parent.Parent.Symbols)
local Types = require(script.Parent.Parent.Types)

local createSignal = require(script.Parent.Parent.createSignal)
local castToState = require(script.Parent.castToState)
local evaluate = require(script.Parent.evaluate)
local peek = require(script.Parent.peek)

local class = {
	[Symbols.Kind] = Symbols.State,
	[Symbols.Type] = Types.Computed,
}

local METATABLE = table.freeze({__index = class})

local function Computed(predicate)
	local newComputed = setmetatable({
		[Symbols.Signal] = createSignal(),
		[Symbols.HiddenValue] = nil,
		_using = {},
		_predicate = predicate
	}, METATABLE)
	
	evaluate(newComputed, true)
	
	return newComputed
end

function class:onChange(callback)
	return self[Symbols.Signal]:connect(callback)
end

function class:_evaluate()
	local function use(target)
		if castToState(target) and not self._using[target] then
			self._using[target] = target:onChange(function()
				evaluate(self, true)
			end)
		end
		
		return peek(target)
	end
	
	local newValue = self._predicate(use)
	local oldValue = self[Symbols.HiddenValue]
	
	self[Symbols.HiddenValue] = newValue
	
	if oldValue ~= newValue then
		self[Symbols.Signal]:fire(newValue, oldValue)
	end
end

return Computed