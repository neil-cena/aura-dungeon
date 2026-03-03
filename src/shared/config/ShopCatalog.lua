--[[
	ShopCatalog.lua
	Phase 4: centralized shop definitions for economy + monetization-safe flows.
]]

local ShopCatalog = {}

ShopCatalog.Items = {
	cosmetic_emote_wave = {
		id = "cosmetic_emote_wave",
		display_name = "Wave Emote",
		item_type = "Expression",
		currency = "coins",
		price = 300,
		one_time = true,
		grant = { cosmetic_id = "emote_wave" },
	},
	qol_rift_recall = {
		id = "qol_rift_recall",
		display_name = "Rift Recall",
		item_type = "Convenience",
		currency = "tokens",
		price = 120,
		one_time = true,
		grant = { perk_id = "rift_recall" },
	},
	starter_pack = {
		id = "starter_pack",
		display_name = "Starter Pack",
		item_type = "Convenience",
		currency = "gems",
		price = 40,
		one_time = true,
		grant = { coins = 600, tokens = 160 },
	},
	battle_pass_premium = {
		id = "battle_pass_premium",
		display_name = "Battle Pass Premium",
		item_type = "Convenience",
		currency = "gems",
		price = 120,
		one_time = true,
		grant = { battle_pass_premium = true },
	},
}

function ShopCatalog.GetOrderedItemIds()
	return {
		"cosmetic_emote_wave",
		"qol_rift_recall",
		"starter_pack",
		"battle_pass_premium",
	}
end

function ShopCatalog.GetItem(itemId)
	if type(itemId) ~= "string" then
		return nil
	end
	return ShopCatalog.Items[itemId]
end

return ShopCatalog
