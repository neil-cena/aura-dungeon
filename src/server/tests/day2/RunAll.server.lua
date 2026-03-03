--[[
	RunAll.server.lua
	Runs all Day 2 test groups and prints results.
	Execute in Roblox Studio with RunAll as a Script under ServerScriptService.
]]

local day2 = script.Parent
if _G.AuraRunTests ~= true then
	return
end

local Tests = {
	AuthorityBoundary = require(day2["AuthorityBoundary.spec"]),
	PityDeterminism = require(day2["PityDeterminism.spec"]),
	AuditLogging = require(day2["AuditLogging.spec"]),
	DisclosureParity = require(day2["DisclosureParity.spec"]),
	Resilience = require(day2["Resilience.spec"]),
}

print("[Day2 Tests] Running...")
local totalPassed, totalFailed = 0, 0
local results = {}
for name, mod in Tests do
	local ok, p, f = pcall(function()
		return mod.run()
	end)
	if ok and type(p) == "number" then
		totalPassed = totalPassed + p
		totalFailed = totalFailed + (f or 0)
		results[name] = { passed = p, failed = f or 0 }
		print(string.format("[Day2] %s: passed=%d failed=%d", name, p, f or 0))
	else
		results[name] = { error = tostring(p) }
		print(string.format("[Day2] %s: ERROR %s", name, tostring(p)))
	end
end
print(string.format("[Day2 Tests] Total: passed=%d failed=%d", totalPassed, totalFailed))
print("[Day2 Tests] Copy the above output into day2-roll-system-test-checklist.md Evidence Summary")
