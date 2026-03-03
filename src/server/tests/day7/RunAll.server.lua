--[[
	RunAll.server.lua
	Runs all Day 7 test groups and prints results.
]]

local day7 = script.Parent
if _G.AuraRunTests ~= true then
	return
end

local Tests = {
	ComplianceGating = require(day7["ComplianceGating.spec"]),
	DisclosureCoverage = require(day7["DisclosureCoverage.spec"]),
	MonetizationPolicy = require(day7["MonetizationPolicy.spec"]),
	LaunchReadiness = require(day7["LaunchReadiness.spec"]),
}

print("[Day7 Tests] Running...")
local totalPassed, totalFailed = 0, 0
for name, mod in Tests do
	local ok, p, f = pcall(function()
		return mod.run()
	end)
	if ok and type(p) == "number" then
		totalPassed = totalPassed + p
		totalFailed = totalFailed + (f or 0)
		print(string.format("[Day7] %s: passed=%d failed=%d", name, p, f or 0))
	else
		print(string.format("[Day7] %s: ERROR %s", name, tostring(p)))
	end
end
print(string.format("[Day7 Tests] Total: passed=%d failed=%d", totalPassed, totalFailed))
print("[Day7 Tests] Copy output into day7-release-readiness-checklist.md")
