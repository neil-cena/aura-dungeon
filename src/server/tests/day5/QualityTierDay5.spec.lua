--[[
	QualityTierDay5.spec.lua
	Day 5: Visual downgrade path is defined and graceful.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PolishConfig = require(ReplicatedStorage.shared.config.PolishConfig)
local PolishTypes = require(ReplicatedStorage.shared.types.PolishTypes)

local function runQualityTierDay5Tests()
	local passed, failed = 0, 0

	if PolishTypes.IsValidQualityTier("low") and PolishTypes.IsValidQualityTier("mid") and PolishTypes.IsValidQualityTier("high") then
		passed = passed + 1
	else
		failed = failed + 1
	end

	if PolishTypes.SelectQualityTierByDeviceProfile("low-end") == PolishConfig.QualityTier.Low then
		passed = passed + 1
	else
		failed = failed + 1
	end

	if PolishTypes.SelectQualityTierByDeviceProfile("mid") == PolishConfig.QualityTier.Mid then
		passed = passed + 1
	else
		failed = failed + 1
	end

	if PolishTypes.SelectQualityTierByDeviceProfile("high-end") == PolishConfig.QualityTier.High then
		passed = passed + 1
	else
		failed = failed + 1
	end

	local low = PolishTypes.GetVisualTierSettings("low")
	local mid = PolishTypes.GetVisualTierSettings("mid")
	local high = PolishTypes.GetVisualTierSettings("high")
	if low and mid and high and low.telegraphTextSize <= mid.telegraphTextSize and mid.telegraphTextSize <= high.telegraphTextSize then
		passed = passed + 1
	else
		failed = failed + 1
	end

	if low and high and low.showShadows == false and high.showShadows == true then
		passed = passed + 1
	else
		failed = failed + 1
	end

	return passed, failed
end

return { run = runQualityTierDay5Tests }
