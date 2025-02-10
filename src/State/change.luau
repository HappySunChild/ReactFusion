local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local castToState = require(script.Parent.castToState)
local evaluate = require(package.Graph.evaluate)

local level = require(package.Logging.level)
local tagPrint = require(package.Logging.tagPrint)

local function change(target)
	if not castToState(target) then
		return
	end

	tagPrint('change+1', target[Symbols.DebugId])

	target[Symbols.LastChange] = os.clock()

	local searchInNow = { target }
	local searchInNext = {}
	local userList = {}

	repeat
		local done = true

		for _, searchTarget in searchInNow do
			for user in searchTarget[Symbols.Users] do
				if user[Symbols.Validity] == 'valid' then
					done = false

					table.insert(userList, user)
					table.insert(searchInNext, user)
				end
			end
		end

		searchInNow, searchInNext = searchInNext, searchInNow

		table.clear(searchInNext)
	until done

	table.sort(userList, function(a, b)
		return a[Symbols.CreatedAt] > b[Symbols.CreatedAt]
	end)

	for _, user in userList do
		user[Symbols.Validity] = 'invalid'

		evaluate(user, false)
	end

	level.increment(-1)
end

return change
