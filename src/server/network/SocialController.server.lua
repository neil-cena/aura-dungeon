--[[
	SocialController.server.lua
	Phase 3 social API (leaderboard snapshots).
]]

local Remotes = require(script.Parent.Remotes)
local LeaderboardService = require(script.Parent.Parent.domain.LeaderboardService)

Remotes.GetLeaderboard.OnServerInvoke = function(_player, payload)
	local limit = 10
	if type(payload) == "table" and type(payload.limit) == "number" then
		limit = payload.limit
	end
	return {
		success = true,
		rows = LeaderboardService.GetTop(limit),
	}
end
