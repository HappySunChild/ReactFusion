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

local createSignal = require(package.createSignal)
local createComputed = require(script.Parent.createComputed)

local ValueClass = {
	[Symbols.Kind] = Symbols.State,
	[Symbols.Type] = Types.Value
}

local METATABLE = table.freeze({__index = ValueClass})

local function createValue<V>(initialValue: V): Types.Value<V>
	local newValue = setmetatable({
		[Internal] = initialValue,
		[Signal] = createSignal(),
		[Tween] = nil
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
	
	if oldValue ~= newValue then
	signal:fire(newValue, oldValue)
	end
	
	return newValue
end

function ValueClass:update(predicate)
	local currentValue = self[Internal]
	
	return self:set(predicate(currentValue))
end

function ValueClass:map(callback)
	return createComputed(function(use)
		return callback(use(self))
	end)
end


function ValueClass:tween(targetValue: any, info: TweenInfo, completedCallback: () -> nil)
	if self[Tween] then
		self[Tween]()
	end
	
	local duration = getTweenDuration(info)
	
	local startValue = self[Internal]
	local startTime = os.clock()
	
	local cancel = External.bind(function(now, disconnect)
		local elapsed = now - startTime
		local alpha = getTweenAlpha(info, elapsed)
		
		local newValue = lerp(startValue, targetValue, alpha)
		
		self:set(newValue)
		
		if elapsed >= duration then
			disconnect()
			
			if completedCallback then
				completedCallback()
			end
		end
	end)
	
	self[Tween] = cancel
	
	return cancel
end

return createValue