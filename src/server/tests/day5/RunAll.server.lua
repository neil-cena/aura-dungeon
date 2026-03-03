--[[
	RunAll.server.lua
	Runs all Day 5 test groups and prints results.
]]

local day5 = script.Parent
local Tests = {
	ThumbReachability = require(day5["ThumbReachability.spec"]),
	MuteReadabilityDay5 = require(day5["MuteReadabilityDay5.spec"]),
	QualityTierDay5 = require(day5["QualityTierDay5.spec"]),
	ResponsivenessDay5 = require(day5["ResponsivenessDay5.spec"]),
	InputLatencyDay5 = require(day5["InputLatencyDay5.spec"]),
}

print("[Day5 Tests] Running...")
local totalPassed, totalFailed = 0, 0
for name, mod in Tests do
	local ok, p, f = pcall(function()
		return mod.run()
	end)
	if ok and type(p) == "number" then
		totalPassed = totalPassed + p
		totalFailed = totalFailed + (f or 0)
		print(string.format("[Day5] %s: passed=%d failed=%d", name, p, f or 0))
	else
		print(string.format("[Day5] %s: ERROR %s", name, tostring(p)))
	end
end
print(string.format("[Day5 Tests] Total: passed=%d failed=%d", totalPassed, totalFailed))
print("[Day5 Tests] Copy output into day5-ux-performance-test-checklist.md")
