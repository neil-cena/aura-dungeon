--[[
	WeaponCatalog.lua
	Placeholder weapon stat templates resolved by rarity.
]]

local WeaponCatalog = {}

WeaponCatalog.ByRarity = {
	Common = { damage = 10, range = 18, attack_cooldown = 0.55 },
	Rare = { damage = 16, range = 20, attack_cooldown = 0.50 },
	Epic = { damage = 24, range = 22, attack_cooldown = 0.45 },
	Legendary = { damage = 34, range = 25, attack_cooldown = 0.40 },
}

function WeaponCatalog.ResolveByItemId(itemId)
	local id = string.lower(itemId or "")
	if id:find("_legendary_") then
		return WeaponCatalog.ByRarity.Legendary
	elseif id:find("_epic_") then
		return WeaponCatalog.ByRarity.Epic
	elseif id:find("_rare_") then
		return WeaponCatalog.ByRarity.Rare
	end
	return WeaponCatalog.ByRarity.Common
end

return WeaponCatalog
