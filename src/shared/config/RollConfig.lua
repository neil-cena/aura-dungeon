--[[
	RollConfig.lua
	Single source of truth for roll probabilities, pity thresholds, lane definitions.
	Used by server domain and client disclosure UI to prevent config drift.
	Source: odds-and-pity-spec.md, economy-sheet.md
]]

local RollConfig = {}

-- Lane constants (must match odds-and-pity-spec)
RollConfig.Lane = {
	Aura = "Aura",
	Weapon = "Weapon",
}

-- Rarity tiers (ordered lowest to highest for precedence)
RollConfig.Rarity = {
	Common = "Common",
	Rare = "Rare",
	Epic = "Epic",
	Legendary = "Legendary",
}

-- Probability table (percent, sum = 100)
-- Source: odds-and-pity-spec §2
RollConfig.Rates = {
	Common = 60.0,
	Rare = 30.0,
	Epic = 9.1,
	Legendary = 0.9,
}

-- Hard pity thresholds (rolls without target tier; trigger when reached)
-- "10th grants Rare+" means after 9 failures we trigger -> threshold 9
-- Source: odds-and-pity-spec §3
RollConfig.PityThresholds = {
	RarePlus = 9,   -- 10th roll guaranteed
	EpicPlus = 49,  -- 50th roll guaranteed
	Legendary = 249, -- 250th roll guaranteed
}

-- Roll costs by lane (economy-sheet §2)
RollConfig.RollCost = {
	Aura = 100,   -- Coins
	Weapon = 50,  -- Tokens
}

-- Currency key per lane
RollConfig.CurrencyByLane = {
	Aura = "coins",
	Weapon = "tokens",
}

-- RNG table version for audit trail
RollConfig.RngTableVersion = "v1.0.0-day2"

-- Display thresholds (pull count at which guarantee triggers; internal threshold is -1)
function RollConfig.GetDisplayPityThresholds()
	return {
		RarePlus = RollConfig.PityThresholds.RarePlus + 1,
		EpicPlus = RollConfig.PityThresholds.EpicPlus + 1,
		Legendary = RollConfig.PityThresholds.Legendary + 1,
	}
end

-- Disclosure text builder (source: odds-and-pity-spec §5)
function RollConfig.GetDisclosureText()
	local d = RollConfig.GetDisplayPityThresholds()
	return string.format(
		"Drop Rates:\nCommon %.1f%%, Rare %.1f%%, Epic %.1f%%, Legendary %.1f%%.\n" ..
		"Guaranteed Rare+ at %d pulls without Rare+.\n" ..
		"Guaranteed Epic+ at %d pulls without Epic+.\n" ..
		"Guaranteed Legendary at %d pulls without Legendary.\n" ..
		"Pity counters are tracked separately for Aura and Weapon rolls.",
		RollConfig.Rates.Common,
		RollConfig.Rates.Rare,
		RollConfig.Rates.Epic,
		RollConfig.Rates.Legendary,
		d.RarePlus,
		d.EpicPlus,
		d.Legendary
	)
end

-- Checksum for disclosure parity tests
function RollConfig.GetDisclosureChecksum()
	local text = RollConfig.GetDisclosureText()
	local hash = 0
	for i = 1, #text do
		hash = (hash * 31 + string.byte(text, i)) % 2147483647
	end
	return tostring(hash)
end

return RollConfig
