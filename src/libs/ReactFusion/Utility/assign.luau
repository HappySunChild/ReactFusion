local function assign(target, ...)
	for _, set in {...} do
		for key, value in set do
			target[key] = value
		end
	end
	
	return target
end

return assign