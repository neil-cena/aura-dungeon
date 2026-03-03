--[[
	LightingConfig.lua
	Hub lighting profile that can be swapped without touching scripts.
]]

local LightingConfig = {}

LightingConfig.Hub = {
	Ambient = Color3.fromRGB(75, 75, 90),
	OutdoorAmbient = Color3.fromRGB(105, 105, 120),
	Brightness = 2.1,
	ClockTime = 14.5,
	FogColor = Color3.fromRGB(145, 155, 180),
	FogStart = 200,
	FogEnd = 900,
}

return LightingConfig
