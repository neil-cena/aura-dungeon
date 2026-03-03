--[[
	RngEngine.lua
	Weighted roll only; no pity logic. Pure, side-effect free.
	Supports deterministic seed for tests.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RollConfig = require(ReplicatedStorage.shared.config.RollConfig)

local RngEngine = {}
local RARITIES = { "Common", "Rare", "Epic", "Legendary" }
local WEIGHTS = {
	RollConfig.Rates.Common,
	RollConfig.Rates.Rare,
	RollConfig.Rates.Epic,
	RollConfig.Rates.Legendary,
}

-- Cached cumulative table (built once)
local cumulative = {}
local total = 0
for i, w in ipairs(WEIGHTS) do
	total = total + w
	cumulative[i] = total
end

--[[
	Roll(seed: number?) -> rarity: string
	Weighted sample. If seed provided, use deterministic RNG for tests.
]]
function RngEngine.Roll(seed)
	local r
	if type(seed) == "number" then
		-- Simple LCG for deterministic tests
		local state = seed % 2147483647
		if state <= 0 then state = 1 end
		r = (state % 10000) / 10000
	else
		r = math.random()
	end

	for i, c in ipairs(cumulative) do
		if r < c / total then
			return RARITIES[i]
		end
	end
	return RARITIES[#RARITIES]
end

return RngEngine
