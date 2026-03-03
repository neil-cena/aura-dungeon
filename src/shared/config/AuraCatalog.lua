--[[
	AuraCatalog.lua
	Visual definitions for aura rarity tiers.
]]

local AuraCatalog = {}

AuraCatalog.RarityVfx = {
	Common = {
		Color = Color3.fromRGB(180, 180, 180),
		LightRange = 5,
		Rate = 6,
		Texture = "rbxasset://textures/particles/sparkles_main.dds",
	},
	Rare = {
		Color = Color3.fromRGB(82, 165, 255),
		LightRange = 8,
		Rate = 12,
		Texture = "rbxasset://textures/particles/sparkles_main.dds",
	},
	Epic = {
		Color = Color3.fromRGB(188, 108, 255),
		LightRange = 10,
		Rate = 18,
		Texture = "rbxasset://textures/particles/fire_main.dds",
	},
	Legendary = {
		Color = Color3.fromRGB(255, 205, 92),
		LightRange = 14,
		Rate = 24,
		Texture = "rbxasset://textures/particles/fire_main.dds",
	},
}

return AuraCatalog
