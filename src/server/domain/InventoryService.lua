--[[
	InventoryService.lua
	Read/equip helpers for aura and weapon inventory state.
]]

local ProfileStore = require(script.Parent.Parent.persistence.ProfileStore)

local InventoryService = {}

local VALID_SLOTS = {
	aura = true,
	weapon = true,
}

local function hasItem(items, itemId)
	for _, item in ipairs(items or {}) do
		if item.item_id == itemId then
			return true, item
		end
	end
	return false, nil
end

function InventoryService.GetInventory(playerId)
	local profile, err = ProfileStore.GetProfile(playerId)
	if not profile then
		return nil, err or "profile_not_found"
	end
	profile.inventory = profile.inventory or { auras = {}, weapons = {}, equipped = {} }
	profile.inventory.equipped = profile.inventory.equipped or {}
	return {
		auras = profile.inventory.auras,
		weapons = profile.inventory.weapons,
		equipped = profile.inventory.equipped,
		currencies = profile.currencies or {},
		progression = profile.progression or {},
		roll_state = profile.roll_state or {},
	}, nil
end

function InventoryService.EquipItem(playerId, slot, itemId)
	if not VALID_SLOTS[slot] then
		return nil, "invalid_slot"
	end
	if type(itemId) ~= "string" or itemId == "" then
		return nil, "invalid_item_id"
	end

	local ok, updateErr = ProfileStore.UpdateProfile(playerId, function(profile)
		profile.inventory = profile.inventory or { auras = {}, weapons = {}, equipped = {} }
		profile.inventory.equipped = profile.inventory.equipped or {}

		local list = slot == "aura" and profile.inventory.auras or profile.inventory.weapons
		local found = hasItem(list, itemId)
		if not found then
			return nil, "item_not_owned"
		end

		profile.inventory.equipped[slot] = itemId
		return profile, nil
	end)
	if not ok then
		return nil, updateErr or "equip_failed"
	end

	local inventory = InventoryService.GetInventory(playerId)
	return inventory, nil
end

return InventoryService
