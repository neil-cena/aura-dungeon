--[[
	PartyService.lua
	Phase 3: lightweight in-memory party management.
]]

local Players = game:GetService("Players")

local PartyService = {}
local MAX_PARTY_SIZE = 4

local partiesByLeader = {}
local playerToLeader = {}
local pendingInviteByTarget = {}

local function ensurePartyForLeader(leaderId)
	local party = partiesByLeader[leaderId]
	if party then
		return party
	end
	party = {
		leader_id = leaderId,
		members = { [leaderId] = true },
		created_at = os.clock(),
	}
	partiesByLeader[leaderId] = party
	playerToLeader[leaderId] = leaderId
	return party
end

local function getLeaderId(playerId)
	return playerToLeader[playerId]
end

local function toMemberList(memberMap)
	local out = {}
	for memberId in pairs(memberMap or {}) do
		table.insert(out, memberId)
	end
	table.sort(out)
	return out
end

local function isFriendPair(aId, bId)
	local a = Players:GetPlayerByUserId(tonumber(aId))
	local b = Players:GetPlayerByUserId(tonumber(bId))
	if not a or not b then
		return false
	end
	local ok, isFriend = pcall(function()
		return a:IsFriendsWith(b.UserId)
	end)
	return ok and isFriend == true
end

function PartyService.GetPartyContext(playerId)
	local leaderId = getLeaderId(playerId)
	if not leaderId then
		return nil
	end
	local party = partiesByLeader[leaderId]
	if not party then
		return nil
	end
	return {
		leader_id = leaderId,
		member_ids = toMemberList(party.members),
		is_leader = leaderId == playerId,
	}
end

function PartyService.GetPartyState(playerId)
	local context = PartyService.GetPartyContext(playerId)
	local pending = pendingInviteByTarget[playerId]
	return {
		party = context,
		pending_invite = pending and { from_leader_id = pending.from_leader_id, from_player_name = pending.from_player_name } or nil,
	}, nil
end

function PartyService.CreateOrGetParty(playerId)
	local context = PartyService.GetPartyContext(playerId)
	if context then
		return context, nil
	end
	local p = ensurePartyForLeader(playerId)
	return {
		leader_id = p.leader_id,
		member_ids = toMemberList(p.members),
		is_leader = true,
	}, nil
end

function PartyService.InvitePlayer(leaderId, targetId)
	if leaderId == targetId then
		return nil, "cannot_invite_self"
	end
	local leaderParty = ensurePartyForLeader(leaderId)
	if not leaderParty.members[leaderId] then
		return nil, "leader_not_in_party"
	end
	if leaderParty.leader_id ~= leaderId then
		return nil, "only_leader_can_invite"
	end
	if leaderParty.members[targetId] then
		return nil, "already_in_party"
	end
	local memberCount = 0
	for _ in pairs(leaderParty.members) do
		memberCount = memberCount + 1
	end
	if memberCount >= MAX_PARTY_SIZE then
		return nil, "party_full"
	end
	local targetPlayer = Players:GetPlayerByUserId(tonumber(targetId))
	if not targetPlayer then
		return nil, "target_not_online"
	end
	if playerToLeader[targetId] ~= nil then
		return nil, "target_already_in_party"
	end
	local leaderPlayer = Players:GetPlayerByUserId(tonumber(leaderId))
	pendingInviteByTarget[targetId] = {
		from_leader_id = leaderId,
		from_player_name = leaderPlayer and leaderPlayer.Name or leaderId,
	}
	return PartyService.GetPartyContext(leaderId), nil
end

function PartyService.AcceptInvite(playerId)
	local invite = pendingInviteByTarget[playerId]
	if not invite then
		return nil, "no_pending_invite"
	end
	local leaderId = invite.from_leader_id
	local party = partiesByLeader[leaderId]
	if not party then
		pendingInviteByTarget[playerId] = nil
		return nil, "party_not_found"
	end
	if playerToLeader[playerId] ~= nil then
		return nil, "already_in_party"
	end
	party.members[playerId] = true
	playerToLeader[playerId] = leaderId
	pendingInviteByTarget[playerId] = nil
	return PartyService.GetPartyContext(playerId), nil
end

function PartyService.LeaveParty(playerId)
	local leaderId = getLeaderId(playerId)
	if not leaderId then
		return true, nil
	end
	local party = partiesByLeader[leaderId]
	if not party then
		playerToLeader[playerId] = nil
		return true, nil
	end

	if leaderId == playerId then
		-- Disband entire party when leader leaves.
		for memberId in pairs(party.members) do
			playerToLeader[memberId] = nil
		end
		partiesByLeader[leaderId] = nil
		return true, nil
	end

	party.members[playerId] = nil
	playerToLeader[playerId] = nil
	return true, nil
end

function PartyService.GetMemberIds(playerId)
	local context = PartyService.GetPartyContext(playerId)
	if not context then
		return { playerId }
	end
	return context.member_ids
end

function PartyService.GetLeaderIdForPlayer(playerId)
	local context = PartyService.GetPartyContext(playerId)
	if not context then
		return playerId
	end
	return context.leader_id
end

function PartyService.GetFriendCountInParty(playerId)
	local context = PartyService.GetPartyContext(playerId)
	if not context then
		return 0
	end
	local count = 0
	for _, otherId in ipairs(context.member_ids) do
		if otherId ~= playerId and isFriendPair(playerId, otherId) then
			count = count + 1
		end
	end
	return count
end

Players.PlayerRemoving:Connect(function(player)
	local playerId = tostring(player.UserId)
	PartyService.LeaveParty(playerId)
	pendingInviteByTarget[playerId] = nil
end)

return PartyService
