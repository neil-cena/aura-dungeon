--[[
	PolishTypes.lua
	Day 5: Shared validation and statistics helpers for polish evidence.
]]

local PolishConfig = require(script.Parent.Parent.config.PolishConfig)

local PolishTypes = {}

local VALID_TIERS = {
	[PolishConfig.QualityTier.Low] = true,
	[PolishConfig.QualityTier.Mid] = true,
	[PolishConfig.QualityTier.High] = true,
}

function PolishTypes.IsValidQualityTier(tier)
	return type(tier) == "string" and VALID_TIERS[tier] == true
end

function PolishTypes.SelectQualityTierByDeviceProfile(deviceProfile)
	if type(deviceProfile) ~= "string" then
		return PolishConfig.QualityTier.Mid
	end
	local normalized = string.lower(deviceProfile)
	if normalized == "low" or normalized == "low-end" then
		return PolishConfig.QualityTier.Low
	elseif normalized == "high" or normalized == "high-end" then
		return PolishConfig.QualityTier.High
	end
	return PolishConfig.QualityTier.Mid
end

function PolishTypes.GetVisualTierSettings(tier)
	if not PolishTypes.IsValidQualityTier(tier) then
		return PolishConfig.VisualDowngrade.mid
	end
	return PolishConfig.VisualDowngrade[tier]
end

function PolishTypes.FilterNumericSamples(samples)
	local out = {}
	if type(samples) ~= "table" then
		return out
	end
	for _, value in ipairs(samples) do
		if type(value) == "number" and value >= 0 then
			table.insert(out, value)
		end
	end
	table.sort(out)
	return out
end

function PolishTypes.ComputeMedian(samples)
	local sorted = PolishTypes.FilterNumericSamples(samples)
	local n = #sorted
	if n == 0 then
		return nil
	end
	local mid = math.floor((n + 1) / 2)
	if n % 2 == 1 then
		return sorted[mid]
	end
	return (sorted[mid] + sorted[mid + 1]) / 2
end

function PolishTypes.ComputeP95(samples)
	local sorted = PolishTypes.FilterNumericSamples(samples)
	local n = #sorted
	if n == 0 then
		return nil
	end
	local index = math.max(1, math.ceil(n * 0.95))
	return sorted[index]
end

local function centerPoint(xScale, yScale, widthScale, heightScale)
	return xScale + (widthScale * 0.5), yScale + (heightScale * 0.5)
end

function PolishTypes.IsThumbReachableLayout(layout)
	if type(layout) ~= "table" then
		return false
	end
	local zone = PolishConfig.ThumbLayout.ThumbReachZone
	for _, button in pairs(layout) do
		if type(button) ~= "table" then
			return false
		end
		local cx, cy = centerPoint(button.xScale or 0, button.yScale or 0, button.widthScale or 0, button.heightScale or 0)
		if cx < zone.MinX or cx > zone.MaxX or cy < zone.MinY or cy > zone.MaxY then
			return false
		end
	end
	return true
end

function PolishTypes.HasReadableCueText(text)
	return type(text) == "string" and #text >= PolishConfig.Readability.MinimumCueLength
end

return PolishTypes
