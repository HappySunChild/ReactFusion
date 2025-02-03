local castToState = require(script.Parent.castToState)

local function evaluate(target, forceComputation)
	if not castToState(target) then
		return false
	end
	
	if forceComputation then
		if target._evaluating then
			error(`Evaluate target is already being evaluated, possible infinite loop!`, 2)
		end
		
		if target._evaluate then
			target._evaluating = true
			
			target:_evaluate()
			
			target._evaluating = nil
		end
	end
	
	return true
end

return evaluate