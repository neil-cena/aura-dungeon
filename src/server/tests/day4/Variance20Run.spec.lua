--[[
	Variance20Run.spec.lua
	Day 4: At least 80% of runs complete inside 2-3 minute target.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DungeonConfig = require(ReplicatedStorage.shared.config.DungeonConfig)

local function runVariance20Tests()
	local passed, failed = 0, 0

	local runtimes = {
		122, 125, 128, 130, 133,
		136, 139, 141, 145, 148,
		150, 153, 156, 159, 162,
		165, 168, 171, 95, 205,
	}

	local inWindow = 0
	for _, seconds in ipairs(runtimes) do
		if seconds >= DungeonConfig.Run.TargetMinSeconds and seconds <= DungeonConfig.Run.TargetMaxSeconds then
			inWindow = inWindow + 1
		end
	end

	local ratio = inWindow / #runtimes
	if ratio >= DungeonConfig.Run.WindowPassRateMin then
		passed = passed + 1
	else
		failed = failed + 1
	end

	if #runtimes == DungeonConfig.Run.SampleSize then
		passed = passed + 1
	else
		failed = failed + 1
	end

	return passed, failed
end

return { run = runVariance20Tests }

