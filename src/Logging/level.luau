local level = 0

local function set(indentLevel)
	level = indentLevel
end

local function get()
	return level
end

local function increment(amount)
	set(get() + amount)
end

return {
	set = set,
	increment = increment,
	get = get,
}
