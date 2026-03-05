--[[
	WeaponDisplayCatalog.lua
	Display names and flavor for generated weapon item IDs.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RarityPresentation = require(ReplicatedStorage.shared.config.RarityPresentation)

local WeaponDisplayCatalog = {}

local namesByRarity = {
	Common = { "Pulse Blade", "Signal Pike", "Echo Dagger", "Ion Staff" },
	Rare = { "Arc Katana", "Hyper Spear", "Flux Saber", "Static Reaver" },
	Epic = { "Nebula Fang", "Vortex Claymore", "Quantum Scythe", "Voidlance" },
	Legendary = { "Photon Exarch", "Starlight Ruin", "Omni Breaker", "Prism Tyrant" },
}

local function pickName(rarity, itemId)
	local pool = namesByRarity[rarity] or namesByRarity.Common
	local hash = 7
	for i = 1, #itemId do
		hash = (hash * 29 + string.byte(itemId, i)) % 2147483647
	end
	local idx = (hash % #pool) + 1
	return pool[idx]
end

function WeaponDisplayCatalog.GetDisplay(itemId)
	local rarity = RarityPresentation.FromItemId(itemId)
	local rarityView = RarityPresentation.Get(rarity)
	return {
		name = pickName(rarity, tostring(itemId or "weapon_common")),
		rarity = rarity,
		rarity_label = rarityView.label,
		color = rarityView.color,
	}
end

return WeaponDisplayCatalog
