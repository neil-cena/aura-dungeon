--[[
	ComplianceGating.spec.lua
	Day 7: verifies age/region/policy gates for monetization eligibility.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local server = ServerScriptService.server

local ProfileStore = require(server.persistence.ProfileStore)
local ComplianceService = require(server.domain.ComplianceService)

local function runComplianceGatingTests()
	local passed, failed = 0, 0
	ProfileStore.ClearCache()

	local playerTeen = "day7-cmp-teen"
	ProfileStore.GetProfile(playerTeen)
	ProfileStore.UpdateProfile(playerTeen, function(profile)
		profile.compliance = { age_group = "teen", region_code = "us", restricted_monetization = false }
		return profile, nil
	end)
	local allowedTeen = ComplianceService.IsMonetizationAllowed(playerTeen, "Expression")
	if allowedTeen == true then
		passed = passed + 1
	else
		failed = failed + 1
	end

	local playerChild = "day7-cmp-child"
	ProfileStore.GetProfile(playerChild)
	ProfileStore.UpdateProfile(playerChild, function(profile)
		profile.compliance = { age_group = "child", region_code = "us", restricted_monetization = false }
		return profile, nil
	end)
	local allowedChild, reasonChild = ComplianceService.IsMonetizationAllowed(playerChild, "Convenience")
	if allowedChild == false and tostring(reasonChild) == "restricted_by_age" then
		passed = passed + 1
	else
		failed = failed + 1
	end

	local playerRegion = "day7-cmp-region"
	ProfileStore.GetProfile(playerRegion)
	ProfileStore.UpdateProfile(playerRegion, function(profile)
		profile.compliance = { age_group = "teen", region_code = "restricted_region", restricted_monetization = false }
		return profile, nil
	end)
	local allowedRegion, reasonRegion = ComplianceService.IsMonetizationAllowed(playerRegion, "Expression")
	if allowedRegion == false and tostring(reasonRegion) == "restricted_by_region" then
		passed = passed + 1
	else
		failed = failed + 1
	end

	local blockedEnhancement = ComplianceService.IsMonetizationAllowed(playerTeen, "Enhancement")
	if blockedEnhancement == false then
		passed = passed + 1
	else
		failed = failed + 1
	end

	return passed, failed
end

return { run = runComplianceGatingTests }
