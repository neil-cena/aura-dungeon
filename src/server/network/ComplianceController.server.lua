--[[
	ComplianceController.server.lua
	Day 7: Exposes read-only compliance state and monetization eligibility checks.
]]

local Remotes = require(script.Parent.Remotes)
local ComplianceService = require(script.Parent.Parent.domain.ComplianceService)

local function playerIdFromPlayer(player)
	return tostring(player.UserId)
end

Remotes.GetComplianceState.OnServerInvoke = function(player)
	local playerId = playerIdFromPlayer(player)
	local state, err = ComplianceService.GetComplianceState(playerId)
	if not state then
		return { success = false, err = err or "compliance_state_unavailable" }
	end
	return { success = true, state = state }
end

Remotes.CheckMonetizationEligibility.OnServerInvoke = function(player, payload)
	local itemType = payload and payload.item_type or nil
	local allowed, reason, state = ComplianceService.IsMonetizationAllowed(playerIdFromPlayer(player), itemType)
	return {
		success = true,
		allowed = allowed == true,
		reason = reason,
		state = state,
	}
end
