--[[
	DailyRewardService.lua
	Phase 3: simple once-per-UTC-day login reward.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProgressionConfig = require(ReplicatedStorage.shared.config.ProgressionConfig)
local ProfileStore = require(script.Parent.Parent.persistence.ProfileStore)

local DailyRewardService = {}

local function todayUtcKey()
	return os.date("!%Y-%m-%d")
end

local function getDailyState(profile)
	profile.progression = profile.progression or {}
	profile.progression.daily_reward = profile.progression.daily_reward or {}
	local dr = profile.progression.daily_reward
	dr.last_claim_utc = dr.last_claim_utc or ""
	return dr
end

function DailyRewardService.GetState(playerId)
	local profile, err = ProfileStore.GetProfile(playerId)
	if not profile then
		return nil, err or "profile_not_found"
	end
	local dr = getDailyState(profile)
	local today = todayUtcKey()
	local canClaim = dr.last_claim_utc ~= today
	return {
		can_claim = canClaim,
		last_claim_utc = dr.last_claim_utc,
		reward = ProgressionConfig.DailyReward,
	}, nil
end

function DailyRewardService.Claim(playerId)
	local today = todayUtcKey()
	local reward = ProgressionConfig.DailyReward
	local ok, err = ProfileStore.UpdateProfile(playerId, function(profile)
		local dr = getDailyState(profile)
		if dr.last_claim_utc == today then
			return nil, "already_claimed_today"
		end
		profile.currencies = profile.currencies or {}
		profile.currencies.coins = (profile.currencies.coins or 0) + (reward.coins or 0)
		profile.currencies.tokens = (profile.currencies.tokens or 0) + (reward.tokens or 0)
		dr.last_claim_utc = today
		return profile, nil
	end)
	if not ok then
		return nil, err or "claim_failed"
	end
	return {
		claimed = true,
		reward = reward,
		last_claim_utc = today,
	}, nil
end

return DailyRewardService
