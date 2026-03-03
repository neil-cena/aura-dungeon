--[[
	BattlePassConfig.lua
	Phase 4: simple season track with free + premium rewards.
]]

local BattlePassConfig = {}

BattlePassConfig.SeasonId = "s1"
BattlePassConfig.PointsPerWin = 25
BattlePassConfig.PointsPerLoss = 10

BattlePassConfig.Tiers = {
	{
		id = 1,
		points_required = 0,
		free_reward = { coins = 100 },
		premium_reward = { tokens = 40 },
	},
	{
		id = 2,
		points_required = 80,
		free_reward = { tokens = 30 },
		premium_reward = { coins = 250 },
	},
	{
		id = 3,
		points_required = 180,
		free_reward = { coins = 220, tokens = 40 },
		premium_reward = { gems = 20 },
	},
	{
		id = 4,
		points_required = 300,
		free_reward = { gems = 12 },
		premium_reward = { gems = 30 },
	},
	{
		id = 5,
		points_required = 460,
		free_reward = { coins = 400 },
		premium_reward = { coins = 400, tokens = 120 },
	},
}

function BattlePassConfig.GetTier(tierId)
	local id = tonumber(tierId)
	if not id then
		return nil
	end
	for _, tier in ipairs(BattlePassConfig.Tiers) do
		if tier.id == id then
			return tier
		end
	end
	return nil
end

return BattlePassConfig
