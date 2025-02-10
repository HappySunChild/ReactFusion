local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local castToState = require(script.Parent.castToState)
local evaluate = require(package.Graph.evaluate)

local level = require(package.Logging.level)
local tagPrint = require(package.Logging.tagPrint)

local function peek<T>(target: Types.StateObject<T> | T): T
	level.increment(1)

	tagPrint('peek', target[Symbols.DebugId])

	if castToState(target) then
		evaluate(target)

		level.increment(-1)

		return target[Symbols.Internal] :: T
	end

	level.increment(-1)

	return target :: T
end

return peek
