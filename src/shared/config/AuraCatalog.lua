--[[
	AuraCatalog.lua
	Visual definitions for aura rarity tiers.
]]

local AuraCatalog = {}

AuraCatalog.RarityVfx = {
	Common = {
		Color = Color3.fromRGB(196, 200, 225),
		LightRange = 7,
		Rate = 8,
		Texture = "rbxasset://textures/particles/sparkles_main.dds",
	},
	Rare = {
		Color = Color3.fromRGB(120, 195, 255),
		LightRange = 11,
		Rate = 14,
		Texture = "rbxasset://textures/particles/sparkles_main.dds",
	},
	Epic = {
		Color = Color3.fromRGB(221, 121, 255),
		LightRange = 13,
		Rate = 20,
		Texture = "rbxasset://textures/particles/fire_main.dds",
	},
	Legendary = {
		Color = Color3.fromRGB(255, 225, 128),
		LightRange = 16,
		Rate = 26,
		Texture = "rbxasset://textures/particles/fire_main.dds",
	},
}

return AuraCatalog
