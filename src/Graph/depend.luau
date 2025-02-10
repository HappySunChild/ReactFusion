local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local evaluate = require(script.Parent.evaluate)

local level = require(package.Logging.level)
local tagPrint = require(package.Logging.tagPrint)

local function depend(user, dependency)
	level.increment(1)

	tagPrint('depend', `{user[Symbols.DebugId]} -> {dependency[Symbols.DebugId]}`)

	evaluate(dependency)

	user[Symbols.Using][dependency] = true
	dependency[Symbols.Users][user] = true

	level.increment(-1)
end

return depend
