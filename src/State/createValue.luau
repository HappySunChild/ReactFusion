local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)
local External = require(package.External)

local Tween = Symbols.named('Tween')
local Signal = Symbols.Signal
local Internal = Symbols.Internal

local getTweenDuration = require(package.Animation.getTweenDuration)
local getTweenAlpha = require(package.Animation.getTweenAlpha)
local lerp = require(package.Animation.lerp)

local createSignal = require(package.Graph.createSignal)
local createComputed = require(script.Parent.createComputed)
local isSimilar = require(package.Utility.isSimilar)
local peek = require(script.Parent.peek)

local ValueClass = {
	[Symbols.Kind] = Symbols.State,
	[Symbols.Type] = Types.Value,
}

local METATABLE = table.freeze({ __index = ValueClass })

local function createValue<V>(initialValue: V): Types.Value<V>
	local newValue = setmetatable({
		[Internal] = initialValue,
		[Signal] = createSignal(),
		[Tween] = nil,
	}, METATABLE)

	return newValue
end

function ValueClass:onChange(callback)
	return self[Signal]:connect(callback)
end

function ValueClass:set(newValue: any)
	local signal = self[Signal]
	local oldValue = self[Internal]

	self[Internal] = newValue

	if not isSimilar(newValue, oldValue) then
		signal:fire(newValue, oldValue)
	end

	return newValue
end

function ValueClass:update(predicate)
	local currentValue = self[Internal]

	return self:set(predicate(currentValue))
end

--- Tweens the value smoothly to the target value.
--- This function is useful for when you need to tween a value once.
---
--- Cancels any active tweens.
function ValueClass:tween(targetValue: Types.UsedAs<any>, info: Types.UsedAs<TweenInfo>, completedCallback: () -> nil)
	info = peek(info)
	targetValue = peek(targetValue)

	if self[Tween] then
		self[Tween]()
		self[Tween] = nil
	end

	local startValue = self[Internal]

	if targetValue == startValue then
		return
	end

	local duration = getTweenDuration(info)
	local startTime = os.clock()

	local cancel = External.bind(function(now, disconnect)
		local elapsed = now - startTime
		local alpha = getTweenAlpha(info, elapsed)

		local newValue = lerp(startValue, targetValue, alpha)

		self:set(newValue)

		if elapsed >= duration then
			self[Tween] = nil
			disconnect()

			if completedCallback then
				completedCallback()
			end
		end
	end)

	self[Tween] = cancel

	return cancel
end

function ValueClass:map(callback)
	return createComputed(function(use)
		return callback(use(self))
	end)
end

function ValueClass:bindToInstanceProperty(instance: Instance, property: string)
	local success = pcall(function()
		return instance[property]
	end)

	if not success then
		error(`'{property}' is not a valid property of instance '{instance}'`, 2)
	end

	self:set(instance[property])

	local connection = instance:GetPropertyChangedSignal(property):Connect(function()
		self:set(instance[property])
	end)

	return function()
		connection:Disconnect()
	end, connection
end

table.freeze(ValueClass)

return createValue
