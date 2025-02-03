-- basically fusion's reactive variable system

local reaction = {
	Value = require(script.State.Value),
	Computed = require(script.State.Computed),
	
	peek = require(script.State.peek)
}

return reaction