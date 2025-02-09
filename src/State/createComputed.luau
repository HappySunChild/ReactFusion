local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local isSimilar = require(package.Utility.isSimilar)
local createSignal = require(package.Graph.createSignal)
local castToState = require(script.Parent.castToState)
local evaluate = require(script.Parent.evaluate)
local peek = require(script.Parent.peek)

local ComputedClass = {
	[Symbols.Kind] = Symbols.State,
	[Symbols.Type] = Types.Computed,
}

local METATABLE = table.freeze({__index = ComputedClass})

local function createComputed<V, T>(processor: Types.ComputedProcessor<T>): Types.Computed<V, T>
	local newComputed = setmetatable({
		[Symbols.Signal] = createSignal(),
		[Symbols.Internal] = nil,
		_using = {},
		_processor = processor
	}, METATABLE)
	
	evaluate(newComputed, true)
	
	return newComputed
end

function ComputedClass:onChange(callback)
	return self[Symbols.Signal]:connect(callback)
end

function ComputedClass:_evaluate()
	local function use(target)
		if castToState(target) and not self._using[target] then
			self._using[target] = target:onChange(function()
				evaluate(self, true)
			end)
		end
		
		return peek(target)
	end
	
	local newValue = self._processor(use)
	local oldValue = self[Symbols.Internal]
	
	self[Symbols.Internal] = newValue
	
	if not isSimilar(newValue, oldValue) then
		self[Symbols.Signal]:fire(newValue, oldValue)
	end
end

table.freeze(ComputedClass)

return createComputed