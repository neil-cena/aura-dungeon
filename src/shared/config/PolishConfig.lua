--[[
	PolishConfig.lua
	Day 5: UX/VFX/audio and performance-readability contracts.
]]

local PolishConfig = {}

PolishConfig.QualityTier = {
	Low = "low",
	Mid = "mid",
	High = "high",
}

PolishConfig.Performance = {
	TargetMedianFps = {
		low = 30,
		mid = 45,
	},
	MaxInputLatencyP95Ms = 150,
	RecommendedLatencySampleCount = 20,
	RecommendedFpsSampleCount = 30,
}

PolishConfig.Readability = {
	MuteReadable = true,
	MinimumCueLength = 8,
	HighContrastCueTextColor = Color3.fromRGB(255, 220, 138),
	HighContrastCueStrokeColor = Color3.fromRGB(34, 18, 63),
}

PolishConfig.ThumbLayout = {
	LandscapeOnly = true,
	-- Normalized screen-space guide rails for right-thumb action controls.
	ActionPanel = {
		AnchorPoint = Vector2.new(1, 1),
		PositionScale = Vector2.new(0.98, 0.98),
		SizeScale = Vector2.new(0.34, 0.32),
	},
	CoreButtons = {
		Main = {
			PositionScale = Vector2.new(0.04, 0.56),
			SizeScale = Vector2.new(0.92, 0.16),
		},
		Win = {
			PositionScale = Vector2.new(0.04, 0.76),
			SizeScale = Vector2.new(0.44, 0.14),
		},
		Loss = {
			PositionScale = Vector2.new(0.52, 0.76),
			SizeScale = Vector2.new(0.44, 0.14),
		},
	},
	ThumbReachZone = {
		MinX = 0.62,
		MaxX = 1.00,
		MinY = 0.45,
		MaxY = 1.00,
	},
}

PolishConfig.VisualDowngrade = {
	low = {
		showShadows = false,
		showGradient = false,
		telegraphTextSize = 12,
		panelOpacity = 0.24,
	},
	mid = {
		showShadows = false,
		showGradient = true,
		telegraphTextSize = 13,
		panelOpacity = 0.2,
	},
	high = {
		showShadows = true,
		showGradient = true,
		telegraphTextSize = 14,
		panelOpacity = 0.16,
	},
}

return PolishConfig
