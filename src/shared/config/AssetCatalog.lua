--[[
	AssetCatalog.lua
	Centralized placeholder asset references so visual reskins only require config changes.
]]

local AssetCatalog = {}

AssetCatalog.Hub = {
	ThemeName = "toolbox_placeholder_v1",
	GroundMaterial = Enum.Material.Slate,
	RollStationColor = Color3.fromRGB(89, 150, 255),
	PortalColor = Color3.fromRGB(120, 85, 255),
	AccentColor = Color3.fromRGB(255, 216, 101),
}

AssetCatalog.AuraVfx = {
	Common = { Color = Color3.fromRGB(180, 180, 180), LightRange = 5, Rate = 6 },
	Rare = { Color = Color3.fromRGB(82, 165, 255), LightRange = 8, Rate = 12 },
	Epic = { Color = Color3.fromRGB(188, 108, 255), LightRange = 10, Rate = 18 },
	Legendary = { Color = Color3.fromRGB(255, 205, 92), LightRange = 14, Rate = 24 },
}

AssetCatalog.Sounds = {
	UiClick = "rbxasset://sounds/button.wav",
	RollAnticipation = "rbxasset://sounds/electronicpingshort.wav",
	RollRevealCommon = "rbxasset://sounds/uuhhh.mp3",
	RollRevealRare = "rbxasset://sounds/bass.wav",
	RollRevealEpic = "rbxasset://sounds/electronicpingshort.wav",
	RollRevealLegendary = "rbxasset://sounds/electronicpingshort.wav",
	CombatHit = "rbxasset://sounds/swordlunge.wav",
	BossTelegraph = "rbxasset://sounds/electronicpingshort.wav",
	BossDeath = "rbxasset://sounds/bass.wav",
	LevelUp = "rbxasset://sounds/electronicpingshort.wav",
	Reward = "rbxasset://sounds/coinsplash.wav",
}

return AssetCatalog
