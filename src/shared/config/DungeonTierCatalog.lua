--[[
	DungeonTierCatalog.lua
	Phase 3: tier rules for dungeon scaling, rewards, and access.
]]

local DungeonTierCatalog = {}

DungeonTierCatalog.DefaultTier = "beginner"

DungeonTierCatalog.Tiers = {
	beginner = {
		id = "beginner",
		display_name = "Beginner",
		min_level = 1,
		enemy_health_mult = 1.0,
		enemy_damage_mult = 1.0,
		reward_mult = 1.0,
		xp_win = 100,
		xp_loss = 40,
	},
	normal = {
		id = "normal",
		display_name = "Normal",
		min_level = 3,
		enemy_health_mult = 1.25,
		enemy_damage_mult = 1.15,
		reward_mult = 1.25,
		xp_win = 135,
		xp_loss = 55,
	},
	hard = {
		id = "hard",
		display_name = "Hard",
		min_level = 6,
		enemy_health_mult = 1.6,
		enemy_damage_mult = 1.35,
		reward_mult = 1.6,
		xp_win = 185,
		xp_loss = 75,
	},
	elite = {
		id = "elite",
		display_name = "Elite",
		min_level = 10,
		enemy_health_mult = 2.0,
		enemy_damage_mult = 1.6,
		reward_mult = 2.0,
		xp_win = 250,
		xp_loss = 100,
	},
}

function DungeonTierCatalog.GetTier(tierId)
	local id = type(tierId) == "string" and string.lower(tierId) or DungeonTierCatalog.DefaultTier
	return DungeonTierCatalog.Tiers[id]
end

function DungeonTierCatalog.GetOrderedTierIds()
	return { "beginner", "normal", "hard", "elite" }
end

return DungeonTierCatalog
