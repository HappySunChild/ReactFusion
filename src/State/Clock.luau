local package = script.Parent.Parent

local createValue = require(script.Parent.createValue)
local External = require(package.External)

local Clock = createValue(os.clock())

External.bind(function(now)
	Clock:set(now)
end)

return Clock
