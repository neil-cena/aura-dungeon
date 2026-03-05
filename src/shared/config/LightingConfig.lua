--[[
	LightingConfig.lua
	Hub lighting profile that can be swapped without touching scripts.
]]

local LightingConfig = {}

LightingConfig.Hub = {
	Ambient = Color3.fromRGB(66, 52, 104),
	OutdoorAmbient = Color3.fromRGB(84, 68, 132),
	Brightness = 2.25,
	ClockTime = 20.2,
	FogColor = Color3.fromRGB(94, 79, 148),
	FogStart = 120,
	FogEnd = 720,
}

LightingConfig.Dungeon = {
	Ambient = Color3.fromRGB(38, 35, 62),
	OutdoorAmbient = Color3.fromRGB(48, 42, 84),
	Brightness = 1.8,
	ClockTime = 1.0,
	FogColor = Color3.fromRGB(70, 56, 110),
	FogStart = 80,
	FogEnd = 360,
}

return LightingConfig
