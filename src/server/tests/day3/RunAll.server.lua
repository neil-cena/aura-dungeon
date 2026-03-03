--[[
	RunAll.server.lua
	Runs all Day 3 test groups and prints results.
	Execute in Roblox Studio via Play; runs under ServerScriptService.server.tests.day3.
]]

local day3 = script.Parent
if _G.AuraRunTests ~= true then
	return
end

local Tests = {
	OnboardingTiming = require(day3["OnboardingTiming.spec"]),
	OnboardingAuthority = require(day3["OnboardingAuthority.spec"]),
	RiftReward = require(day3["RiftReward.spec"]),
}

print("[Day3 Tests] Running...")
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
		print(string.format("[Day3] %s: passed=%d failed=%d", name, p, f or 0))
	else
		results[name] = { error = tostring(p) }
		print(string.format("[Day3] %s: ERROR %s", name, tostring(p)))
	end
end
print(string.format("[Day3 Tests] Total: passed=%d failed=%d", totalPassed, totalFailed))
print("[Day3 Tests] Copy the above output into day3-onboarding-test-checklist.md")
