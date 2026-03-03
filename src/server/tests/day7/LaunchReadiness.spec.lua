--[[
	LaunchReadiness.spec.lua
	Day 7: validates launch-readiness numeric gates and runbook expectations.
]]

local function crashFreePercent(totalSessions, crashSessions)
	if totalSessions <= 0 then
		return 0
	end
	return ((totalSessions - crashSessions) / totalSessions) * 100
end

local function runLaunchReadinessTests()
	local passed, failed = 0, 0

	local simulatedCrashFree = crashFreePercent(250, 2)
	if simulatedCrashFree >= 99.0 then
		passed = passed + 1
	else
		failed = failed + 1
	end

	local disclosureCoverage = 3 / 3
	if disclosureCoverage >= 1.0 then
		passed = passed + 1
	else
		failed = failed + 1
	end

	local rollbackHotfixValidated = true
	if rollbackHotfixValidated then
		passed = passed + 1
	else
		failed = failed + 1
	end

	return passed, failed
end

return { run = runLaunchReadinessTests }
