--[[
	RunAll.server.lua
	Runs all Day 4 test groups and prints results.
]]

local day4 = script.Parent
local Tests = {
	RuntimeWindow = require(day4["RuntimeWindow.spec"]),
	BossPresence = require(day4["BossPresence.spec"]),
	LossRetention = require(day4["LossRetention.spec"]),
	MuteReadability = require(day4["MuteReadability.spec"]),
	Variance20Run = require(day4["Variance20Run.spec"]),
}

print("[Day4 Tests] Running...")
local totalPassed, totalFailed = 0, 0
for name, mod in Tests do
	local ok, p, f = pcall(function()
		return mod.run()
	end)
	if ok and type(p) == "number" then
		totalPassed = totalPassed + p
		totalFailed = totalFailed + (f or 0)
		print(string.format("[Day4] %s: passed=%d failed=%d", name, p, f or 0))
	else
		print(string.format("[Day4] %s: ERROR %s", name, tostring(p)))
	end
end
print(string.format("[Day4 Tests] Total: passed=%d failed=%d", totalPassed, totalFailed))
print("[Day4 Tests] Copy output into day4-dungeon-test-checklist.md")

