--[[
	BattlePassService.lua
	Phase 4: season progression and tier reward claiming.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattlePassConfig = require(ReplicatedStorage.shared.config.BattlePassConfig)
local ProfileStore = require(script.Parent.Parent.persistence.ProfileStore)

local BattlePassService = {}

local function ensureState(profile)
	profile.progression = profile.progression or {}
	profile.progression.battle_pass = profile.progression.battle_pass or {}
	local bp = profile.progression.battle_pass
	bp.season_id = bp.season_id or BattlePassConfig.SeasonId
	bp.points = tonumber(bp.points or 0)
	bp.premium_unlocked = bp.premium_unlocked == true
	bp.claimed_free = bp.claimed_free or {}
	bp.claimed_premium = bp.claimed_premium or {}
	return bp
end

local function highestUnlockedTier(points)
	local unlocked = 1
	for _, tier in ipairs(BattlePassConfig.Tiers) do
		if points >= (tier.points_required or 0) then
			unlocked = math.max(unlocked, tier.id)
		end
	end
	return unlocked
end

local function grantReward(profile, reward)
	if type(reward) ~= "table" then
		return
	end
	profile.currencies = profile.currencies or {}
	if reward.coins then
		profile.currencies.coins = (profile.currencies.coins or 0) + tonumber(reward.coins or 0)
	end
	if reward.tokens then
		profile.currencies.tokens = (profile.currencies.tokens or 0) + tonumber(reward.tokens or 0)
	end
	if reward.gems then
		profile.currencies.gems = (profile.currencies.gems or 0) + tonumber(reward.gems or 0)
	end
end

function BattlePassService.GetState(playerId)
	local profile, err = ProfileStore.GetProfile(playerId)
	if not profile then
		return nil, err or "profile_not_found"
	end
	local bp = ensureState(profile)
	local unlockedTier = highestUnlockedTier(bp.points)
	local tiers = {}
	for _, tier in ipairs(BattlePassConfig.Tiers) do
		local key = tostring(tier.id)
		table.insert(tiers, {
			id = tier.id,
			points_required = tier.points_required,
			claimed_free = bp.claimed_free[key] == true,
			claimed_premium = bp.claimed_premium[key] == true,
			free_reward = tier.free_reward,
			premium_reward = tier.premium_reward,
		})
	end
	return {
		season_id = bp.season_id,
		points = bp.points,
		unlocked_tier = unlockedTier,
		premium_unlocked = bp.premium_unlocked == true,
		tiers = tiers,
	}, nil
end

function BattlePassService.AddPoints(playerId, points)
	local add = math.max(0, math.floor(tonumber(points or 0)))
	if add <= 0 then
		local state = BattlePassService.GetState(playerId)
		return state
	end
	local outState = nil
	local ok, err = ProfileStore.UpdateProfile(playerId, function(profile)
		local bp = ensureState(profile)
		bp.points = (bp.points or 0) + add
		outState = {
			points = bp.points,
			unlocked_tier = highestUnlockedTier(bp.points),
		}
		return profile, nil
	end)
	if not ok then
		return nil, err or "battle_pass_points_failed"
	end
	return outState, nil
end

function BattlePassService.RecordDungeonOutcome(playerId, didWin)
	local points = didWin and BattlePassConfig.PointsPerWin or BattlePassConfig.PointsPerLoss
	return BattlePassService.AddPoints(playerId, points)
end

function BattlePassService.ClaimTier(playerId, tierId, track)
	local tier = BattlePassConfig.GetTier(tierId)
	if not tier then
		return nil, "unknown_tier"
	end
	local isPremiumTrack = track == "premium"
	local result = nil
	local ok, err = ProfileStore.UpdateProfile(playerId, function(profile)
		local bp = ensureState(profile)
		if bp.points < (tier.points_required or 0) then
			return nil, "tier_locked"
		end
		local key = tostring(tier.id)
		if isPremiumTrack then
			if bp.premium_unlocked ~= true then
				return nil, "premium_locked"
			end
			if bp.claimed_premium[key] == true then
				return nil, "already_claimed"
			end
			bp.claimed_premium[key] = true
			grantReward(profile, tier.premium_reward)
		else
			if bp.claimed_free[key] == true then
				return nil, "already_claimed"
			end
			bp.claimed_free[key] = true
			grantReward(profile, tier.free_reward)
		end
		result = {
			tier_id = tier.id,
			track = isPremiumTrack and "premium" or "free",
			reward = isPremiumTrack and tier.premium_reward or tier.free_reward,
			points = bp.points,
		}
		return profile, nil
	end)
	if not ok then
		return nil, err or "battle_pass_claim_failed"
	end
	return result, nil
end

return BattlePassService
