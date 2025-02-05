local package = script.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

return function (element)
	local compType = typeof(element.component)
	
	if compType == 'string' then
		return Symbols.Host
	elseif compType == 'function' then
		return Symbols.Function
	elseif compType == 'Instance' then
		return Symbols.Hydration
	elseif Types.of(element) == Types.Fragment then
		return Symbols.Fragment
	end
end