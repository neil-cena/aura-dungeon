--[[
	ComplianceService.lua
	Day 7: server-side compliance gating decisions for age/region restricted flows.
]]

local ProfileStore = require(script.Parent.Parent.persistence.ProfileStore)

local ComplianceService = {}

local RESTRICTED_REGIONS = {
	restricted_region = true,
	unknown = true,
}

local ALLOWED_TYPES = {
	Expression = true,
	Convenience = true,
}

local function normalizeCompliance(compliance)
	compliance = compliance or {}
	local ageGroup = tostring(compliance.age_group or "unknown"):lower()
	local regionCode = tostring(compliance.region_code or "unknown"):lower()
	local restrictedByPolicy = compliance.restricted_monetization == true
	local restrictedByAge = ageGroup == "child"
	local restrictedByRegion = RESTRICTED_REGIONS[regionCode] == true
	local restricted = restrictedByPolicy or restrictedByAge or restrictedByRegion

	return {
		age_group = ageGroup,
		region_code = regionCode,
		restricted_monetization = restricted,
		reason_code = restricted and (
			restrictedByPolicy and "restricted_by_policy"
			or (restrictedByAge and "restricted_by_age")
			or "restricted_by_region"
		) or "allowed",
	}
end

function ComplianceService.GetComplianceState(playerId)
	if type(playerId) ~= "string" or playerId == "" then
		return nil, "invalid player id"
	end
	local profile, err = ProfileStore.GetProfile(playerId)
	if not profile then
		return nil, err or "profile_not_found"
	end
	return normalizeCompliance(profile.compliance), nil
end

function ComplianceService.IsMonetizationAllowed(playerId, itemType)
	if type(itemType) ~= "string" then
		return false, "invalid_item_type", nil
	end
	if not ALLOWED_TYPES[itemType] then
		return false, "unsupported_or_blocked_item_type", nil
	end

	local state, err = ComplianceService.GetComplianceState(playerId)
	if not state then
		return false, err or "compliance_state_unavailable", nil
	end
	if state.restricted_monetization then
		return false, state.reason_code, state
	end
	return true, "allowed", state
end

return ComplianceService
