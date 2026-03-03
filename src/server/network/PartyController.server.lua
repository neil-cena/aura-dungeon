--[[
	PartyController.server.lua
	Phase 3 party API.
]]

local Remotes = require(script.Parent.Remotes)
local PartyService = require(script.Parent.Parent.domain.PartyService)

Remotes.GetPartyState.OnServerInvoke = function(player)
	local playerId = tostring(player.UserId)
	local state, err = PartyService.GetPartyState(playerId)
	if not state then
		return { success = false, err = err or "party_state_failed" }
	end
	return { success = true, state = state }
end

Remotes.CreateOrGetParty.OnServerInvoke = function(player)
	local playerId = tostring(player.UserId)
	local party, err = PartyService.CreateOrGetParty(playerId)
	if not party then
		return { success = false, err = err or "create_party_failed" }
	end
	return { success = true, party = party }
end

Remotes.InviteToParty.OnServerInvoke = function(player, payload)
	if type(payload) ~= "table" or type(payload.target_user_id) ~= "number" then
		return { success = false, err = "invalid_request" }
	end
	local leaderId = tostring(player.UserId)
	local targetId = tostring(payload.target_user_id)
	local party, err = PartyService.InvitePlayer(leaderId, targetId)
	if not party then
		return { success = false, err = err or "invite_failed" }
	end
	return { success = true, party = party }
end

Remotes.AcceptPartyInvite.OnServerInvoke = function(player)
	local playerId = tostring(player.UserId)
	local party, err = PartyService.AcceptInvite(playerId)
	if not party then
		return { success = false, err = err or "accept_failed" }
	end
	return { success = true, party = party }
end

Remotes.LeaveParty.OnServerInvoke = function(player)
	local playerId = tostring(player.UserId)
	local ok, err = PartyService.LeaveParty(playerId)
	if not ok then
		return { success = false, err = err or "leave_failed" }
	end
	return { success = true }
end
