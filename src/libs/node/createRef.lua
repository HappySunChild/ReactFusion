local Types = require(script.Parent.Types)

local function createRef()
	local hostInstance = nil
	local ref = {
		[Types.Type] = Types.Ref
	}
	
	function ref:set(instance)
		hostInstance = instance
	end
	
	function ref:get()
		return hostInstance
	end
	
	return ref
end

return createRef