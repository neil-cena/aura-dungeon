--[[
	ProgressionConfig.lua
	Phase 3: level/xp economy + daily reward values.
]]

local ProgressionConfig = {}

ProgressionConfig.Level = {
	BaseXpPerLevel = 250,
	MaxLevel = 50,
}

ProgressionConfig.DailyReward = {
	coins = 150,
	tokens = 25,
}

function ProgressionConfig.GetLevelFromXp(xpTotal)
	local xp = math.max(0, tonumber(xpTotal) or 0)
	local base = ProgressionConfig.Level.BaseXpPerLevel
	local rawLevel = math.floor(xp / base) + 1
	return math.min(ProgressionConfig.Level.MaxLevel, rawLevel)
end

function ProgressionConfig.GetXpIntoLevel(xpTotal)
	local xp = math.max(0, tonumber(xpTotal) or 0)
	local base = ProgressionConfig.Level.BaseXpPerLevel
	return xp % base, base
end

return ProgressionConfig
