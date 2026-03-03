--[[
	RollTypes.lua
	Common shape validators and helpers for lane names, rarity enums.
	Used by server to reject malformed client input.
]]

local RollConfig = require(script.Parent.Parent.config.RollConfig)

local RollTypes = {}

-- Validate lane is one of allowed values
function RollTypes.IsValidLane(lane)
	if type(lane) ~= "string" then
		return false
	end
	return lane == RollConfig.Lane.Aura or lane == RollConfig.Lane.Weapon
end

-- Validate rarity is one of allowed values
function RollTypes.IsValidRarity(rarity)
	if type(rarity) ~= "string" then
		return false
	end
	for _, r in pairs(RollConfig.Rarity) do
		if r == rarity then
			return true
		end
	end
	return false
end

-- Reject payloads with forbidden client fields (Authority Boundary)
local FORBIDDEN_KEYS = {
	rarity = true,
	result_rarity = true,
	pity_override_used = true,
	pre_counters = true,
	post_counters = true,
	since_rare_plus = true,
	since_epic_plus = true,
	since_legendary = true,
	roll_count_total = true,
	item_id = true,
	result_item_id = true,
	event_id = true,
	rng_table_version = true,
	probabilities = true,
	rates = true,
}

function RollTypes.IsSafeRollRequest(payload)
	if type(payload) ~= "table" then
		return false
	end
	for k, _ in payload do
		if FORBIDDEN_KEYS[k] then
			return false
		end
	end
	return true
end

-- Pity counter shape
function RollTypes.CreateEmptyCounters()
	return {
		roll_count_total = 0,
		since_rare_plus = 0,
		since_epic_plus = 0,
		since_legendary = 0,
	}
end

return RollTypes
