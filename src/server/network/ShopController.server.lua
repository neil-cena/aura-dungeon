--[[
	ShopController.server.lua
	Phase 4 shop API.
]]

local Remotes = require(script.Parent.Remotes)
local ShopService = require(script.Parent.Parent.domain.ShopService)

local PURCHASE_COOLDOWN_SEC = 0.25
local lastPurchaseAt = {}

Remotes.GetShopState.OnServerInvoke = function(player)
	local state, err = ShopService.GetState(tostring(player.UserId))
	if not state then
		return { success = false, err = err or "shop_state_failed" }
	end
	return { success = true, state = state }
end

Remotes.PurchaseShopItem.OnServerInvoke = function(player, payload)
	local itemId = payload and payload.item_id
	if type(itemId) ~= "string" then
		return { success = false, err = "invalid_request" }
	end
	local playerId = tostring(player.UserId)
	local now = os.clock()
	if lastPurchaseAt[playerId] and (now - lastPurchaseAt[playerId]) < PURCHASE_COOLDOWN_SEC then
		return { success = false, err = "purchase_rate_limited" }
	end
	lastPurchaseAt[playerId] = now
	local result, err = ShopService.Purchase(playerId, itemId)
	if not result then
		return { success = false, err = err or "purchase_failed" }
	end
	return { success = true, result = result }
end
