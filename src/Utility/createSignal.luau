local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local SignalClass = {
	[Symbols.Type] = Types.Signal,
}

local METATABLE = table.freeze({ __index = SignalClass })

local function createSignal()
	local signal = setmetatable({
		subscriptions = {},
	}, METATABLE)

	return signal
end

function SignalClass:fire(...)
	for callback in self.subscriptions do
		callback(...)
	end
end

function SignalClass:connect(callback)
	self.subscriptions[callback] = true

	return function()
		self.subscriptions[callback] = nil
	end
end

return createSignal
