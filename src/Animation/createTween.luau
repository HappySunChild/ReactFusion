local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)
local External = require(package.External)

local getTweenAlpha = require(script.Parent.getTweenAlpha)
local getTweenDuration = require(script.Parent.getTweenDuration)
local lerp = require(script.Parent.lerp)

local castToState = require(package.State.castToState)
local peek = require(package.State.peek)

local createSignal = require(package.Graph.createSignal)

local Internal = Symbols.Internal
local Signal = Symbols.Signal
local Info = Symbols.named('Info')
local Target = Symbols.named('Target')
local ActiveLoop = Symbols.named('ActiveLoop')

local TweenClass = {
	[Symbols.Type] = Types.Tween,
	[Symbols.Kind] = Symbols.State,
}

local METATABLE = table.freeze({ __index = TweenClass })

local function createTween<V>(target: Types.UsedAs<V>, info: Types.UsedAs<TweenInfo>)
	local newTween = setmetatable({
		[Signal] = createSignal(),
		[Internal] = peek(target),
		[Target] = target,
		[Info] = info,
		[ActiveLoop] = nil,
	}, METATABLE)

	if castToState(target) then
		target:onChange(function(targetValue)
			if newTween[ActiveLoop] then
				newTween[ActiveLoop]()
				newTween[ActiveLoop] = nil
			end

			local startValue = newTween[Internal]

			if targetValue == startValue then
				return
			end

			local duration = getTweenDuration(info)
			local startTime = os.clock()

			newTween[ActiveLoop] = External.bind(function(now, disconnect)
				local elapsed = now - startTime
				local alpha = getTweenAlpha(info, elapsed)

				local newValue = lerp(startValue, targetValue, alpha)

				newTween[Internal] = newValue
				newTween[Signal]:fire(newValue)

				if elapsed >= duration then
					newTween[ActiveLoop] = nil
					disconnect()
				end
			end)
		end)
	end

	return newTween
end

function TweenClass:onChange(callback)
	return self[Signal]:connect(callback)
end

table.freeze(TweenClass)

return createTween
