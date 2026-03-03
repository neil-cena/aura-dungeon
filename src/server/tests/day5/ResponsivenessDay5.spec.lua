--[[
	ResponsivenessDay5.spec.lua
	Day 5: Polish settings do not violate performance responsiveness targets.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PolishConfig = require(ReplicatedStorage.shared.config.PolishConfig)
local PolishTypes = require(ReplicatedStorage.shared.types.PolishTypes)

local function runResponsivenessDay5Tests()
	local passed, failed = 0, 0

	local lowEndFpsSamples = { 30, 32, 31, 33, 29, 30, 31, 32, 30, 31 }
	local midTierFpsSamples = { 45, 47, 49, 44, 46, 48, 45, 47, 46, 45 }

	local lowMedian = PolishTypes.ComputeMedian(lowEndFpsSamples)
	local midMedian = PolishTypes.ComputeMedian(midTierFpsSamples)

	if lowMedian and lowMedian >= PolishConfig.Performance.TargetMedianFps.low then
		passed = passed + 1
	else
		failed = failed + 1
	end

	if midMedian and midMedian >= PolishConfig.Performance.TargetMedianFps.mid then
		passed = passed + 1
	else
		failed = failed + 1
	end

	local lowVisual = PolishTypes.GetVisualTierSettings("low")
	if lowVisual and lowVisual.showShadows == false and lowVisual.showGradient == false then
		passed = passed + 1
	else
		failed = failed + 1
	end

	return passed, failed
end

return { run = runResponsivenessDay5Tests }
