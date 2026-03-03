--[[
	LeaderboardService.lua
	Phase 3: in-session leaderboard from in-memory profiles.
]]

local ProfileStore = require(script.Parent.Parent.persistence.ProfileStore)

local LeaderboardService = {}

local function sortDesc(items, key)
	table.sort(items, function(a, b)
		if a[key] == b[key] then
			return a.player_id < b.player_id
		end
		return a[key] > b[key]
	end)
end

function LeaderboardService.GetTop(limit)
	local maxItems = math.max(1, math.floor(tonumber(limit) or 10))
	local profiles = ProfileStore.GetAllProfilesSnapshot and ProfileStore.GetAllProfilesSnapshot() or {}
	local rows = {}
	for _, p in ipairs(profiles) do
		local prog = p.progression or {}
		local value = {
			player_id = tostring(p.player_id or "0"),
			level = tonumber(prog.level) or 1,
			dungeons_completed = tonumber(prog.dungeons_completed) or 0,
			boss_kills = tonumber(prog.boss_kills) or 0,
			legendary_rolls = tonumber(prog.legendary_rolls) or 0,
		}
		table.insert(rows, value)
	end
	sortDesc(rows, "dungeons_completed")
	local out = {}
	for i = 1, math.min(maxItems, #rows) do
		table.insert(out, rows[i])
	end
	return out
end

return LeaderboardService
