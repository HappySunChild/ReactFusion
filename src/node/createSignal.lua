local function createSignal()
	local signal = {}
	signal.subscriptions = {}
	
	function signal:Fire(...)
		for callback in self.subscriptions do
			callback(...)
		end
	end
	
	function signal:Connect(callback)
		self.subscriptions[callback] = true
		
		return function ()
			self.subscriptions[callback] = nil
		end
	end
	
	return signal
end

return createSignal 