local package = script.Parent.Parent

local Symbols = require(package.Symbols)

local function assign(target, ...)
	for _, set in { ... } do
		for key, value in set do
			target[key] = value == Symbols.None and nil or value
		end
	end

	return target
end

return assign
