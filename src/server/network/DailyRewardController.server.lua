--[[
	DailyRewardController.server.lua
	Phase 3 daily reward API.
]]

local Remotes = require(script.Parent.Remotes)
local DailyRewardService = require(script.Parent.Parent.domain.DailyRewardService)

Remotes.GetDailyRewardState.OnServerInvoke = function(player)
	local playerId = tostring(player.UserId)
	local state, err = DailyRewardService.GetState(playerId)
	if not state then
		return { success = false, err = err or "daily_state_failed" }
	end
	return { success = true, state = state }
end

Remotes.ClaimDailyReward.OnServerInvoke = function(player)
	local playerId = tostring(player.UserId)
	local result, err = DailyRewardService.Claim(playerId)
	if not result then
		return { success = false, err = err or "daily_claim_failed" }
	end
	return { success = true, result = result }
end
