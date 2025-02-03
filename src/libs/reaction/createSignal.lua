local class = {}
local METATABLE = table.freeze({__index = class})

local function createSignal()
	local newSignal = setmetatable({
		_connections = {}
	}, METATABLE)
	
	return newSignal
end

function class:connect(callback)
	self._connections[callback] = true
	
	return function ()
		self._connections[callback] = nil
	end
end

function class:fire(...)
	for callback in self._connections do
		callback(...)
	end
end

return createSignal