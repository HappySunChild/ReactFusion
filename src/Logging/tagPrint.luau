local debugPrintingEnabled = false

local level = require(script.Parent.level)

local function tagPrint(tag: string, ...: any)
	if not debugPrintingEnabled then
		return
	end

	local amount = 0

	tag = tag:gsub('[%+%-]%d+$', function(match)
		amount = tonumber(match)

		return ''
	end)

	if amount > 0 then
		level.increment(amount)
	end

	local currentLevel = level.get()

	print(`{string.rep('\t', currentLevel - 1)}[{tag:upper()}]`, ...)

	if amount < 0 then
		level.increment(amount)
	end
end

return tagPrint
