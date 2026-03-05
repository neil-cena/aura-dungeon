--[[
	RarityPresentation.lua
	Single source of truth for rarity colors and labels.
]]

local RarityPresentation = {}

RarityPresentation.ByRarity = {
	Common = {
		label = "Common",
		color = Color3.fromRGB(193, 196, 220),
		accent = Color3.fromRGB(136, 141, 169),
	},
	Rare = {
		label = "Rare",
		color = Color3.fromRGB(116, 182, 255),
		accent = Color3.fromRGB(82, 137, 255),
	},
	Epic = {
		label = "Epic",
		color = Color3.fromRGB(209, 127, 255),
		accent = Color3.fromRGB(255, 108, 230),
	},
	Legendary = {
		label = "Legendary",
		color = Color3.fromRGB(255, 224, 128),
		accent = Color3.fromRGB(255, 166, 79),
	},
}

function RarityPresentation.FromItemId(itemId)
	local id = string.lower(itemId or "")
	if id:find("_legendary_") then
		return "Legendary"
	elseif id:find("_epic_") then
		return "Epic"
	elseif id:find("_rare_") then
		return "Rare"
	end
	return "Common"
end

function RarityPresentation.Get(itemIdOrRarity)
	local key = itemIdOrRarity
	if type(key) ~= "string" then
		key = "Common"
	end
	if not RarityPresentation.ByRarity[key] then
		key = RarityPresentation.FromItemId(key)
	end
	return RarityPresentation.ByRarity[key] or RarityPresentation.ByRarity.Common
end

return RarityPresentation
