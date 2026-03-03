--[[
	MonetizationPolicy.spec.lua
	Day 7: validates allowed monetization classes and blocked enhancement path.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local server = ServerScriptService.server

local ProfileStore = require(server.persistence.ProfileStore)
local ComplianceService = require(server.domain.ComplianceService)

local function runMonetizationPolicyTests()
	local passed, failed = 0, 0
	ProfileStore.ClearCache()

	local player = "day7-monetization-policy"
	ProfileStore.GetProfile(player)
	ProfileStore.UpdateProfile(player, function(profile)
		profile.compliance = { age_group = "teen", region_code = "us", restricted_monetization = false }
		return profile, nil
	end)

	local allowExpression = ComplianceService.IsMonetizationAllowed(player, "Expression")
	if allowExpression == true then
		passed = passed + 1
	else
		failed = failed + 1
	end

	local allowConvenience = ComplianceService.IsMonetizationAllowed(player, "Convenience")
	if allowConvenience == true then
		passed = passed + 1
	else
		failed = failed + 1
	end

	local blockEnhancement, enhancementReason = ComplianceService.IsMonetizationAllowed(player, "Enhancement")
	if blockEnhancement == false and tostring(enhancementReason) == "unsupported_or_blocked_item_type" then
		passed = passed + 1
	else
		failed = failed + 1
	end

	local blockUnknown = ComplianceService.IsMonetizationAllowed(player, "UnknownType")
	if blockUnknown == false then
		passed = passed + 1
	else
		failed = failed + 1
	end

	return passed, failed
end

return { run = runMonetizationPolicyTests }
