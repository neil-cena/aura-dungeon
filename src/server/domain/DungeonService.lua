--[[
	DungeonService.lua
	Day 4: Authoritative dungeon runtime + boss lifecycle + outcome rewards.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DungeonConfig = require(ReplicatedStorage.shared.config.DungeonConfig)
local ProfileStore = require(script.Parent.Parent.persistence.ProfileStore)

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
		telegraph_text = DungeonConfig.Telegraph.PromptText,
		boss_spawn_text = DungeonConfig.Telegraph.BossSpawnText,
		server_timestamp = nowSec(),
	}, nil
end

function DungeonService.StartRun(playerId)
	if type(playerId) ~= "string" or playerId == "" then
		return nil, "invalid player id"
	end
	runStateByPlayer[playerId] = {
		status = DungeonConfig.Status.Wave,
		wave_index = 1,
		boss_spawned = false,
		started_at = nowSec(),
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

local function grantOutcomeReward(playerId, outcome)
	local winCfg = DungeonConfig.Rewards.Win
	local lossCfg = DungeonConfig.Rewards.Loss

	local deltaCoins = 0
	local deltaTokens = 0
	if outcome == DungeonConfig.Status.Won then
		deltaCoins = winCfg.coins
		deltaTokens = winCfg.tokens
	else
		deltaCoins = math.max(math.floor(winCfg.coins * lossCfg.retentionPercent), lossCfg.minCoins)
		deltaTokens = math.max(math.floor(winCfg.tokens * lossCfg.retentionPercent), lossCfg.minTokens)
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

	local reward, err = grantOutcomeReward(playerId, outcome)
	if not reward then
		return nil, err
	end

	return {
		status = state.status,
		boss_spawned = state.boss_spawned,
		runtime_seconds = runtime,
		outcome = outcome,
		reward = reward,
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


