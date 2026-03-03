--[[
	DungeonService.lua
	Day 4: Authoritative dungeon runtime + boss lifecycle + outcome rewards.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DungeonConfig = require(ReplicatedStorage.shared.config.DungeonConfig)
local DungeonTierCatalog = require(ReplicatedStorage.shared.config.DungeonTierCatalog)
local RollConfig = require(ReplicatedStorage.shared.config.RollConfig)
local ProfileStore = require(script.Parent.Parent.persistence.ProfileStore)
local AuditLogger = require(script.Parent.AuditLogger)
local ProgressionService = require(script.Parent.ProgressionService)
local BattlePassService = require(script.Parent.BattlePassService)

local DungeonService = {}

local runStateByPlayer = {}

local function nowSec()
	return os.clock()
end

function DungeonService.GetState(playerId)
	if type(playerId) ~= "string" or playerId == "" then
		return nil, "invalid player id"
	end
	local state = runStateByPlayer[playerId]
	if not state then
		return {
			status = DungeonConfig.Status.Idle,
			wave_index = 0,
			boss_spawned = false,
			runtime_seconds = 0,
			tier_id = DungeonTierCatalog.DefaultTier,
			instance_owner_id = playerId,
			party_member_ids = { playerId },
		}, nil
	end
	local runtime = state.started_at and (nowSec() - state.started_at) or 0
	return {
		status = state.status,
		wave_index = state.wave_index,
		boss_spawned = state.boss_spawned,
		runtime_seconds = runtime,
		started_at = state.started_at,
		ended_at = state.ended_at,
		outcome = state.outcome,
		tier_id = state.tier_id or DungeonTierCatalog.DefaultTier,
		instance_owner_id = state.instance_owner_id or playerId,
		party_member_ids = state.party_member_ids or { playerId },
		telegraph_text = DungeonConfig.Telegraph.PromptText,
		boss_spawn_text = DungeonConfig.Telegraph.BossSpawnText,
		server_timestamp = nowSec(),
	}, nil
end

function DungeonService.StartRun(playerId, tierId, instanceOwnerId, partyMemberIds)
	if type(playerId) ~= "string" or playerId == "" then
		return nil, "invalid player id"
	end
	local tier = DungeonTierCatalog.GetTier(tierId) or DungeonTierCatalog.GetTier(DungeonTierCatalog.DefaultTier)
	local progression = ProgressionService.GetProgression(playerId)
	local level = progression and progression.level or 1
	if level < (tier.min_level or 1) then
		return nil, string.format("tier_locked_requires_level_%d", tier.min_level or 1)
	end
	runStateByPlayer[playerId] = {
		status = DungeonConfig.Status.Wave,
		wave_index = 1,
		boss_spawned = false,
		started_at = nowSec(),
		tier_id = tier.id,
		instance_owner_id = instanceOwnerId or playerId,
		party_member_ids = partyMemberIds or { playerId },
	}
	return DungeonService.GetState(playerId)
end

function DungeonService.AdvancePhase(playerId)
	local state = runStateByPlayer[playerId]
	if not state then
		return nil, "run not started"
	end
	if state.status == DungeonConfig.Status.Won or state.status == DungeonConfig.Status.Lost then
		return nil, "run already ended"
	end

	if not state.boss_spawned then
		if state.wave_index < DungeonConfig.Phases.WaveCount then
			state.wave_index = state.wave_index + 1
			state.status = DungeonConfig.Status.Wave
		else
			state.boss_spawned = true
			state.status = DungeonConfig.Status.Boss
		end
	end

	return DungeonService.GetState(playerId)
end

local function grantOutcomeReward(playerId, outcome, tierId)
	local lossCfg = DungeonConfig.Rewards.Loss
	local tier = DungeonTierCatalog.GetTier(tierId) or DungeonTierCatalog.GetTier(DungeonTierCatalog.DefaultTier)
	local rewardMult = tier.reward_mult or 1.0

	local deltaCoins = 0
	local deltaTokens = 0
	local auraRollCost = (RollConfig.RollCost and RollConfig.RollCost.Aura) or 100
	local weaponRollCost = (RollConfig.RollCost and RollConfig.RollCost.Weapon) or 50
	if outcome == DungeonConfig.Status.Won then
		-- Balance target: one win funds ~2 Aura rolls or ~4 Weapon rolls.
		deltaCoins = math.max(1, math.floor((auraRollCost * 2.0) * rewardMult))
		deltaTokens = math.max(1, math.floor((weaponRollCost * 4.0) * rewardMult))
	else
		-- Balance target: one loss funds ~0.25 roll in each lane.
		deltaCoins = math.max(math.floor((auraRollCost * 0.25) * rewardMult), lossCfg.minCoins)
		deltaTokens = math.max(math.floor((weaponRollCost * 0.25) * rewardMult), lossCfg.minTokens)
	end

	local ok, err = ProfileStore.UpdateProfile(playerId, function(p)
		p.currencies = p.currencies or {}
		p.currencies.coins = (p.currencies.coins or 0) + deltaCoins
		p.currencies.tokens = (p.currencies.tokens or 0) + deltaTokens
		p.progression = p.progression or {}
		p.progression.dungeons_completed = (p.progression.dungeons_completed or 0) + (outcome == DungeonConfig.Status.Won and 1 or 0)
		p.progression.boss_kills = (p.progression.boss_kills or 0) + (outcome == DungeonConfig.Status.Won and 1 or 0)
		return p, nil
	end)

	if not ok then
		return nil, err or "reward write failed"
	end

	local now = os.date("!%Y-%m-%dT%H:%M:%SZ")
	local reasonPrefix = outcome == DungeonConfig.Status.Won and "DUNGEON_WIN" or "DUNGEON_LOSS"
	AuditLogger.LogEconomyTransaction({
		timestamp = now,
		player_id = playerId,
		currency = "coins",
		delta = deltaCoins,
		balance_before = 0,
		balance_after = 0,
		reason_code = reasonPrefix .. "_REWARD_COINS",
		source_context = "dungeon_reward",
	})
	AuditLogger.LogEconomyTransaction({
		timestamp = now,
		player_id = playerId,
		currency = "tokens",
		delta = deltaTokens,
		balance_before = 0,
		balance_after = 0,
		reason_code = reasonPrefix .. "_REWARD_TOKENS",
		source_context = "dungeon_reward",
	})

	local xpDelta = outcome == DungeonConfig.Status.Won and (tier.xp_win or 100) or (tier.xp_loss or 40)
	ProgressionService.AddXp(playerId, xpDelta)
	BattlePassService.RecordDungeonOutcome(playerId, outcome == DungeonConfig.Status.Won)

	return { coins = deltaCoins, tokens = deltaTokens }, nil
end

function DungeonService.CompleteRun(playerId, outcome, runtimeOverrideSeconds)
	if type(playerId) ~= "string" or playerId == "" then
		return nil, "invalid player id"
	end
	if outcome ~= DungeonConfig.Status.Won and outcome ~= DungeonConfig.Status.Lost then
		return nil, "invalid outcome"
	end

	local state = runStateByPlayer[playerId]
	if not state then
		return nil, "run not started"
	end
	if state.status == DungeonConfig.Status.Won or state.status == DungeonConfig.Status.Lost then
		return nil, "run already ended"
	end

	state.status = outcome
	state.outcome = outcome
	state.ended_at = nowSec()
	local runtime = runtimeOverrideSeconds or (state.ended_at - state.started_at)

	local reward, err = grantOutcomeReward(playerId, outcome, state.tier_id)
	if not reward then
		return nil, err
	end

	return {
		status = state.status,
		boss_spawned = state.boss_spawned,
		runtime_seconds = runtime,
		outcome = outcome,
		reward = reward,
		tier_id = state.tier_id or DungeonTierCatalog.DefaultTier,
		loss_retention_applied = outcome == DungeonConfig.Status.Lost,
		server_completed_at = nowSec(),
	}, nil
end

function DungeonService.ResetRun(playerId)
	runStateByPlayer[playerId] = nil
end

function DungeonService.GetRunTableForTests()
	return runStateByPlayer
end

return DungeonService


