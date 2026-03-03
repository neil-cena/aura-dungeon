--[[
	MacroService.lua
	Aggregates high-level gameplay/economy/progression snapshot for macro UI.
]]

local ProfileStore = require(script.Parent.Parent.persistence.ProfileStore)
local AuditLogger = require(script.Parent.AuditLogger)
local OnboardingService = require(script.Parent.OnboardingService)
local DungeonService = require(script.Parent.DungeonService)

local MacroService = {}

local function computeLevelAndXp(progression)
	local p = progression or {}
	local xp = tonumber(p.xp_total)
	if xp == nil then
		local dc = tonumber(p.dungeons_completed) or 0
		local bk = tonumber(p.boss_kills) or 0
		xp = (dc * 100) + (bk * 60)
	end
	local level = tonumber(p.level) or math.max(1, math.floor(xp / 250) + 1)
	local nextLevelXp = level * 250
	local currentLevelBase = (level - 1) * 250
	local inLevelXp = xp - currentLevelBase
	local inLevelCap = nextLevelXp - currentLevelBase
	return level, xp, inLevelXp, inLevelCap
end

local function summarizeObjective(onboardingState, dungeonState)
	if onboardingState and onboardingState.current_step then
		local step = onboardingState.current_step
		if step ~= "returnedHub" and step ~= "rewarded" then
			return string.format("Finish onboarding (%s)", step)
		end
	end

	if dungeonState and dungeonState.status then
		local status = dungeonState.status
		if status == "wave" or status == "boss" then
			return string.format("Complete dungeon run (%s)", status)
		end
	end
	return "Roll -> Equip -> Enter Rift"
end

local function takeRecentEconomy(playerId, maxCount)
	local txs = AuditLogger.GetEconomyTransactionsForPlayer(playerId)
	local out = {}
	local startIndex = math.max(1, #txs - (maxCount - 1))
	for i = #txs, startIndex, -1 do
		table.insert(out, txs[i])
	end
	return out
end

function MacroService.GetSnapshot(playerId)
	local profile, err = ProfileStore.GetProfile(playerId)
	if not profile then
		return nil, err or "profile_not_found"
	end

	local currencies = profile.currencies or {}
	local progression = profile.progression or {}
	local inventory = profile.inventory or {}
	local equipped = inventory.equipped or {}
	local rollState = profile.roll_state or {}
	local onboardingState = OnboardingService.GetState(playerId)
	local dungeonState = DungeonService.GetState(playerId)

	local level, totalXp, inLevelXp, inLevelCap = computeLevelAndXp(progression)

	return {
		currencies = {
			coins = currencies.coins or 0,
			tokens = currencies.tokens or 0,
			gems = currencies.gems or 0,
		},
		equipped = {
			aura = equipped.aura,
			weapon = equipped.weapon,
		},
		progression = {
			level = level,
			xp_total = totalXp,
			xp_in_level = inLevelXp,
			xp_in_level_cap = inLevelCap,
			dungeons_completed = progression.dungeons_completed or 0,
			boss_kills = progression.boss_kills or 0,
			battle_pass_points = (((progression.battle_pass or {}).points) or 0),
			battle_pass_premium_unlocked = (((progression.battle_pass or {}).premium_unlocked) == true),
		},
		pity = {
			aura_lane = rollState.aura_lane or {},
			weapon_lane = rollState.weapon_lane or {},
		},
		objective = summarizeObjective(onboardingState, dungeonState),
		run_status = dungeonState and dungeonState.status or "idle",
		economy_recent = takeRecentEconomy(playerId, 8),
		server_timestamp = os.clock(),
	}, nil
end

return MacroService
