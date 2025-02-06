local function lerp(from, to, alpha)
	local dataType = typeof(from)
	
	if typeof(to) == dataType then
		if dataType == 'number' then
			return from + (to - from) * alpha
		elseif dataType == 'Color3' then
			return from:Lerp(to, alpha)
		end
	end
	
	if alpha < 0.5 then
		return from
	else
		return to
	end
end

return lerp