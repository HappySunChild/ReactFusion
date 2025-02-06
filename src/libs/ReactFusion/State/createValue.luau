local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

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

function ValueClass:set(newValue)
	local signal = self[Signal]
	local oldValue = self[Internal]
	
	self[Internal] = newValue
	
	signal:fire(newValue, oldValue)
	
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


function ValueClass:tween(targetValue: any, info: TweenInfo)
	if self[Tween] then
		self[Tween]()
	end
	
	local duration = getTweenDuration(info)
	local id = 'ReactFusionTween-' .. HttpService:GenerateGUID(false)
	
	local function cancel()
		pcall(function()
			RunService:UnbindFromRenderStep(id)
		end)
	end
	
	local startValue = self[Internal]
	local startTime = os.clock()
	
	RunService:BindToRenderStep(id, Enum.RenderPriority.First.Value, function()
		local elapsed = os.clock() - startTime
		local alpha = getTweenAlpha(info, elapsed)
		
		local newValue = lerp(startValue, targetValue, alpha)
		
		self:set(newValue)
		
		if elapsed > duration then
			cancel()
		end
	end)
	
	self[Tween] = cancel
	
	return cancel
end

return createValue