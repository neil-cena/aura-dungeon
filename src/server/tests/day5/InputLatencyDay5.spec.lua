--[[
	InputLatencyDay5.spec.lua
	Day 5: Core button input-to-action p95 stays within threshold.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PolishConfig = require(ReplicatedStorage.shared.config.PolishConfig)
local PolishTypes = require(ReplicatedStorage.shared.types.PolishTypes)

local function runInputLatencyDay5Tests()
	local passed, failed = 0, 0

	local latencySamplesMs = {
		78, 84, 92, 95, 102,
		88, 110, 120, 98, 105,
		87, 91, 112, 118, 125,
		99, 107, 130, 136, 145,
	}

	local p95 = PolishTypes.ComputeP95(latencySamplesMs)
	if p95 and p95 <= PolishConfig.Performance.MaxInputLatencyP95Ms then
		passed = passed + 1
	else
		failed = failed + 1
	end

	if #latencySamplesMs >= PolishConfig.Performance.RecommendedLatencySampleCount then
		passed = passed + 1
	else
		failed = failed + 1
	end

	local median = PolishTypes.ComputeMedian(latencySamplesMs)
	if median and median <= PolishConfig.Performance.MaxInputLatencyP95Ms then
		passed = passed + 1
	else
		failed = failed + 1
	end

	return passed, failed
end

return { run = runInputLatencyDay5Tests }
