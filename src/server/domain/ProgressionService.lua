--[[
	ProgressionService.lua
	Phase 3: authoritative XP/level progression helpers.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProgressionConfig = require(ReplicatedStorage.shared.config.ProgressionConfig)
local ProfileStore = require(script.Parent.Parent.persistence.ProfileStore)

local ProgressionService = {}

local function normalizeProgression(profile)
	profile.progression = profile.progression or {}
	local p = profile.progression
	p.xp_total = tonumber(p.xp_total) or 0
	p.level = tonumber(p.level) or ProgressionConfig.GetLevelFromXp(p.xp_total)
	p.dungeons_completed = tonumber(p.dungeons_completed) or 0
	p.boss_kills = tonumber(p.boss_kills) or 0
	p.legendary_rolls = tonumber(p.legendary_rolls) or 0
	return p
end

function ProgressionService.GetProgression(playerId)
	local profile, err = ProfileStore.GetProfile(playerId)
	if not profile then
		return nil, err or "profile_not_found"
	end
	local p = normalizeProgression(profile)
	local xpInLevel, xpCap = ProgressionConfig.GetXpIntoLevel(p.xp_total)
	return {
		level = p.level,
		xp_total = p.xp_total,
		xp_in_level = xpInLevel,
		xp_in_level_cap = xpCap,
		dungeons_completed = p.dungeons_completed,
		boss_kills = p.boss_kills,
		legendary_rolls = p.legendary_rolls,
	}, nil
end

function ProgressionService.AddXp(playerId, xpDelta)
	local delta = math.max(0, math.floor(tonumber(xpDelta) or 0))
	if delta <= 0 then
		return ProgressionService.GetProgression(playerId)
	end

	local ok, err = ProfileStore.UpdateProfile(playerId, function(profile)
		local p = normalizeProgression(profile)
		p.xp_total = p.xp_total + delta
		p.level = ProgressionConfig.GetLevelFromXp(p.xp_total)
		profile.progression = p
		return profile, nil
	end)
	if not ok then
		return nil, err or "xp_update_failed"
	end
	return ProgressionService.GetProgression(playerId)
end

function ProgressionService.RecordLegendaryRoll(playerId)
	local ok, err = ProfileStore.UpdateProfile(playerId, function(profile)
		local p = normalizeProgression(profile)
		p.legendary_rolls = (p.legendary_rolls or 0) + 1
		profile.progression = p
		return profile, nil
	end)
	if not ok then
		return false, err or "legendary_record_failed"
	end
	return true, nil
end

return ProgressionService
