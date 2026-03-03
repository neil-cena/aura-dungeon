--[[
	BattlePassController.server.lua
	Phase 4 battle pass API.
]]

local Remotes = require(script.Parent.Remotes)
local BattlePassService = require(script.Parent.Parent.domain.BattlePassService)

local CLAIM_COOLDOWN_SEC = 0.2
local lastClaimAt = {}

Remotes.GetBattlePassState.OnServerInvoke = function(player)
	local state, err = BattlePassService.GetState(tostring(player.UserId))
	if not state then
		return { success = false, err = err or "battle_pass_state_failed" }
	end
	return { success = true, state = state }
end

Remotes.ClaimBattlePassTier.OnServerInvoke = function(player, payload)
	local tierId = payload and payload.tier_id
	local track = payload and payload.track or "free"
	if type(tierId) ~= "number" then
		return { success = false, err = "invalid_request" }
	end
	local playerId = tostring(player.UserId)
	local now = os.clock()
	if lastClaimAt[playerId] and (now - lastClaimAt[playerId]) < CLAIM_COOLDOWN_SEC then
		return { success = false, err = "claim_rate_limited" }
	end
	lastClaimAt[playerId] = now
	local result, err = BattlePassService.ClaimTier(playerId, tierId, track)
	if not result then
		return { success = false, err = err or "claim_failed" }
	end
	return { success = true, result = result }
end
