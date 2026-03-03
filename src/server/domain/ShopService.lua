--[[
	ShopService.lua
	Phase 4: compliant shop purchases with profile-backed ownership.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ShopCatalog = require(ReplicatedStorage.shared.config.ShopCatalog)
local ProfileStore = require(script.Parent.Parent.persistence.ProfileStore)
local ComplianceService = require(script.Parent.ComplianceService)

local ShopService = {}

local function ensureCollections(profile)
	profile.shop = profile.shop or {}
	profile.shop.owned = profile.shop.owned or {}
	profile.shop.perks = profile.shop.perks or {}
	profile.shop.cosmetics = profile.shop.cosmetics or {}
	profile.progression = profile.progression or {}
	profile.progression.battle_pass = profile.progression.battle_pass or {}
	profile.progression.battle_pass.premium_unlocked = profile.progression.battle_pass.premium_unlocked == true
end

local function isOwned(profile, itemId)
	ensureCollections(profile)
	return profile.shop.owned[itemId] == true
end

function ShopService.GetState(playerId)
	local profile, err = ProfileStore.GetProfile(playerId)
	if not profile then
		return nil, err or "profile_not_found"
	end
	ensureCollections(profile)
	local items = {}
	for _, itemId in ipairs(ShopCatalog.GetOrderedItemIds()) do
		local item = ShopCatalog.GetItem(itemId)
		if item then
			table.insert(items, {
				id = item.id,
				display_name = item.display_name,
				item_type = item.item_type,
				currency = item.currency,
				price = item.price,
				one_time = item.one_time == true,
				owned = isOwned(profile, item.id),
			})
		end
	end
	return {
		items = items,
		balances = profile.currencies or {},
		premium_unlocked = profile.progression.battle_pass.premium_unlocked == true,
	}, nil
end

function ShopService.Purchase(playerId, itemId)
	local item = ShopCatalog.GetItem(itemId)
	if not item then
		return nil, "unknown_item"
	end

	local allowed, reason = ComplianceService.IsMonetizationAllowed(playerId, item.item_type)
	if not allowed then
		return nil, reason or "purchase_blocked"
	end

	local resultPayload = nil
	local ok, err = ProfileStore.UpdateProfile(playerId, function(profile)
		ensureCollections(profile)
		profile.currencies = profile.currencies or {}
		if item.one_time and isOwned(profile, item.id) then
			return nil, "already_owned"
		end
		local currency = tostring(item.currency or "coins")
		local balance = tonumber(profile.currencies[currency] or 0)
		local price = tonumber(item.price or 0)
		if balance < price then
			return nil, "insufficient_currency"
		end
		profile.currencies[currency] = balance - price
		profile.shop.owned[item.id] = true

		local grant = item.grant or {}
		if grant.coins then
			profile.currencies.coins = (profile.currencies.coins or 0) + tonumber(grant.coins or 0)
		end
		if grant.tokens then
			profile.currencies.tokens = (profile.currencies.tokens or 0) + tonumber(grant.tokens or 0)
		end
		if grant.gems then
			profile.currencies.gems = (profile.currencies.gems or 0) + tonumber(grant.gems or 0)
		end
		if grant.perk_id then
			profile.shop.perks[grant.perk_id] = true
		end
		if grant.cosmetic_id then
			profile.shop.cosmetics[grant.cosmetic_id] = true
		end
		if grant.battle_pass_premium == true then
			profile.progression.battle_pass.premium_unlocked = true
		end
		resultPayload = {
			item_id = item.id,
			currency = currency,
			price = price,
			balances = profile.currencies,
			premium_unlocked = profile.progression.battle_pass.premium_unlocked == true,
		}
		return profile, nil
	end)
	if not ok then
		return nil, err or "purchase_failed"
	end
	return resultPayload, nil
end

return ShopService
