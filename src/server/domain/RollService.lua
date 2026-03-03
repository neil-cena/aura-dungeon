--[[
	RollService.lua
	Orchestrator: validate -> spend -> resolve pity/rng -> grant -> log -> return.
	Server-authoritative only. Source: odds-and-pity-spec, data-schema-v1.
]]

local HttpService = game:GetService("HttpService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RollConfig = require(ReplicatedStorage.shared.config.RollConfig)
local RollTypes = require(ReplicatedStorage.shared.types.RollTypes)
local PityEngine = require(script.Parent.PityEngine)
local RngEngine = require(script.Parent.RngEngine)
local AuditLogger = require(script.Parent.AuditLogger)
local ProfileStore = require(script.Parent.Parent.persistence.ProfileStore)
local PartyService = require(script.Parent.PartyService)

local RollService = {}

--[[
	ExecuteRoll(playerId: string, lane: string) -> (result, err)
	result: { lane, rarity, item_id, pity_override_used, post_counters }
]]
function RollService.ExecuteRoll(playerId, lane)
	if not RollTypes.IsValidLane(lane) then
		return nil, "invalid lane"
	end

	local profile, err = ProfileStore.GetProfile(playerId)
	if not profile then
		return nil, err or "profile not found"
	end

	local cost = RollConfig.RollCost[lane]
	local currencyKey = RollConfig.CurrencyByLane[lane]
	local balance = (profile.currencies or {})[currencyKey] or 0

	if balance < cost then
		return nil, "insufficient balance"
	end

	local laneKey = lane:lower() .. "_lane"
	local rollState = profile.roll_state or {}
	local counters = rollState[laneKey]
	if not counters then
		counters = RollTypes.CreateEmptyCounters()
		if not rollState[laneKey] then
			rollState[laneKey] = counters
		end
	end

	local preCounters = {
		roll_count_total = counters.roll_count_total or 0,
		since_rare_plus = counters.since_rare_plus or 0,
		since_epic_plus = counters.since_epic_plus or 0,
		since_legendary = counters.since_legendary or 0,
	}

	local rngRarity = RngEngine.Roll()
	local friendCount = PartyService.GetFriendCountInParty(playerId)
	local partyLuckBonus = math.min(0.30, friendCount * 0.10)
	local rngRoll = math.random()
	if partyLuckBonus > 0 and rngRoll <= partyLuckBonus then
		local upgradeMap = {
			Common = RollConfig.Rarity.Rare,
			Rare = RollConfig.Rarity.Epic,
			Epic = RollConfig.Rarity.Legendary,
			Legendary = RollConfig.Rarity.Legendary,
		}
		rngRarity = upgradeMap[rngRarity] or rngRarity
	end
	local rarity, pityOverride = PityEngine.ResolveRarityWithPity(preCounters, rngRarity)
	local itemId = RollService.GenerateItemId(lane, rarity)

	local postCounters = PityEngine.UpdateCountersAfterResult(preCounters, rarity)
	local autoEquippedSlot = nil

	-- Atomic update: spend, grant, update counters, log
	local success, updateErr = ProfileStore.UpdateProfile(playerId, function(p)
		local np = HttpService:JSONDecode(HttpService:JSONEncode(p))
		np.currencies = np.currencies or {}
		np.currencies[currencyKey] = (np.currencies[currencyKey] or 0) - cost
		np.roll_state = np.roll_state or {}
		np.roll_state[laneKey] = postCounters
		np.inventory = np.inventory or { auras = {}, weapons = {} }
		local invKey = lane == RollConfig.Lane.Aura and "auras" or "weapons"
		table.insert(np.inventory[invKey], { item_id = itemId, rarity = rarity, count = 1 })
		np.inventory.equipped = np.inventory.equipped or {}
		if lane == RollConfig.Lane.Aura and not np.inventory.equipped.aura then
			np.inventory.equipped.aura = itemId
			autoEquippedSlot = "aura"
		elseif lane == RollConfig.Lane.Weapon and not np.inventory.equipped.weapon then
			np.inventory.equipped.weapon = itemId
			autoEquippedSlot = "weapon"
		end
		return np, nil
	end)

	if not success then
		return nil, updateErr or "profile update failed"
	end

	local now = os.date("!%Y-%m-%dT%H:%M:%SZ")
	local eventId = HttpService:GenerateGUID(false)
	local txIdSpend = HttpService:GenerateGUID(false)

	AuditLogger.LogRollEvent({
		event_id = eventId,
		timestamp = now,
		player_id = playerId,
		lane = lane,
		pre_counters = preCounters,
		result_rarity = rarity,
		result_item_id = itemId,
		pity_override_used = pityOverride,
		post_counters = postCounters,
		rng_table_version = RollConfig.RngTableVersion,
	})

	local balanceBefore = balance
	local balanceAfter = balance - cost
	AuditLogger.LogEconomyTransaction({
		tx_id = txIdSpend,
		timestamp = now,
		player_id = playerId,
		currency = currencyKey,
		delta = -cost,
		balance_before = balanceBefore,
		balance_after = balanceAfter,
		reason_code = lane == RollConfig.Lane.Aura and "AURA_ROLL_COST" or "WEAPON_ROLL_COST",
		source_context = eventId,
	})

	return {
		lane = lane,
		rarity = rarity,
		item_id = itemId,
		pity_override_used = pityOverride,
		post_counters = postCounters,
		auto_equipped_slot = autoEquippedSlot,
		party_friend_count = friendCount,
		party_luck_bonus = partyLuckBonus,
	}, nil
end

function RollService.GenerateItemId(lane, rarity)
	return string.format("%s_%s_%s", lane:lower(), rarity:lower(), HttpService:GenerateGUID(false):sub(1, 8))
end

return RollService
