--[[
	PityEngine.lua
	Pure domain logic: pity eligibility, resolution, counter updates.
	No side effects, no I/O. Source: odds-and-pity-spec §3, §4.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RollConfig = require(ReplicatedStorage.shared.config.RollConfig)

local PityEngine = {}

local RARITY_ORDER = { "Common", "Rare", "Epic", "Legendary" }
local function rarityRank(r)
	for i, name in RARITY_ORDER do
		if name == r then return i end
	end
	return 0
end

--[[
	GetEligiblePity(counters) -> "Legendary" | "Epic" | "Rare" | nil
	Highest-tier eligible pity takes priority.
]]
function PityEngine.GetEligiblePity(counters)
	if not counters then return nil end
	local t = RollConfig.PityThresholds
	local sinceL = counters.since_legendary or 0
	local sinceE = counters.since_epic_plus or 0
	local sinceR = counters.since_rare_plus or 0

	if sinceL >= t.Legendary then
		return RollConfig.Rarity.Legendary
	end
	if sinceE >= t.EpicPlus then
		return RollConfig.Rarity.Epic
	end
	if sinceR >= t.RarePlus then
		return RollConfig.Rarity.Rare
	end
	return nil
end

--[[
	ResolveRarityWithPity(counters, rngRarity) -> (finalRarity, pityOverrideUsed)
	If pity eligible, return pity result; else return rng result.
]]
function PityEngine.ResolveRarityWithPity(counters, rngRarity)
	local pity = PityEngine.GetEligiblePity(counters)
	if pity then
		return pity, true
	end
	return rngRarity or RollConfig.Rarity.Common, false
end

--[[
	UpdateCountersAfterResult(counters, rarity) -> newCounters
	Reset rules: Rare resets since_rare_plus; Epic resets both; Legendary resets all.
]]
function PityEngine.UpdateCountersAfterResult(counters, rarity)
	local c = {
		roll_count_total = (counters.roll_count_total or 0) + 1,
		since_rare_plus = counters.since_rare_plus or 0,
		since_epic_plus = counters.since_epic_plus or 0,
		since_legendary = counters.since_legendary or 0,
	}

	if rarity == RollConfig.Rarity.Legendary then
		c.since_rare_plus = 0
		c.since_epic_plus = 0
		c.since_legendary = 0
	elseif rarity == RollConfig.Rarity.Epic then
		c.since_rare_plus = 0
		c.since_epic_plus = 0
		c.since_legendary = c.since_legendary + 1
	elseif rarity == RollConfig.Rarity.Rare then
		c.since_rare_plus = 0
		c.since_epic_plus = c.since_epic_plus + 1
		c.since_legendary = c.since_legendary + 1
	else
		c.since_rare_plus = c.since_rare_plus + 1
		c.since_epic_plus = c.since_epic_plus + 1
		c.since_legendary = c.since_legendary + 1
	end

	return c
end

return PityEngine