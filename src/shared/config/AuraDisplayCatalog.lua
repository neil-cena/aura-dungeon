--[[
	AuraDisplayCatalog.lua
	Display names and flavor for generated aura item IDs.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RarityPresentation = require(ReplicatedStorage.shared.config.RarityPresentation)

local AuraDisplayCatalog = {}

local namesByRarity = {
	Common = { "Spark Veil", "Mist Echo", "Static Halo", "Dawn Fragment" },
	Rare = { "Azure Pulse", "Neon Mirage", "Void Prism", "Aurora Arc" },
	Epic = { "Phantom Nova", "Cyber Seraph", "Chromatic Rift", "Eclipse Bloom" },
	Legendary = { "Celestial Overdrive", "Infinite Spectrum", "Astral Dominion", "Zero Point Crown" },
}

local function pickName(rarity, itemId)
	local pool = namesByRarity[rarity] or namesByRarity.Common
	local hash = 0
	for i = 1, #itemId do
		hash = (hash * 31 + string.byte(itemId, i)) % 2147483647
	end
	local idx = (hash % #pool) + 1
	return pool[idx]
end

function AuraDisplayCatalog.GetDisplay(itemId)
	local rarity = RarityPresentation.FromItemId(itemId)
	local rarityView = RarityPresentation.Get(rarity)
	return {
		name = pickName(rarity, tostring(itemId or "aura_common")),
		rarity = rarity,
		rarity_label = rarityView.label,
		color = rarityView.color,
	}
end

return AuraDisplayCatalog
