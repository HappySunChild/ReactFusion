local package = script.Parent.Parent

local External = require(package.External)
local createValue = require(package.State.createValue)

local Clock = createValue(os.clock(), 'Clock')

External.bind(function(now)
	Clock:set(now)
end)

return Clock
