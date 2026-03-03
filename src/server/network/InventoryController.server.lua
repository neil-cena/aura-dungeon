--[[
	InventoryController.server.lua
	Exposes inventory read/equip remotes and aura equip broadcast.
]]

local Players = game:GetService("Players")
local Remotes = require(script.Parent.Remotes)
local InventoryService = require(script.Parent.Parent.domain.InventoryService)

local function applyEquippedAuraAttribute(player, character)
	local playerId = tostring(player.UserId)
	local inventory = InventoryService.GetInventory(playerId)
	if inventory and inventory.equipped and inventory.equipped.aura then
		character:SetAttribute("EquippedAuraId", inventory.equipped.aura)
	end
end

Remotes.GetInventory.OnServerInvoke = function(player)
	local playerId = tostring(player.UserId)
	local inventory, err = InventoryService.GetInventory(playerId)
	if not inventory then
		return { success = false, err = err or "inventory_unavailable" }
	end
	return { success = true, inventory = inventory }
end

Remotes.RequestEquipItem.OnServerEvent:Connect(function(player, payload)
	if type(payload) ~= "table" then
		Remotes.InventoryUpdate:FireClient(player, { success = false, err = "invalid_request" })
		return
	end
	local slot = payload.slot
	local itemId = payload.item_id
	local playerId = tostring(player.UserId)
	local inventory, err = InventoryService.EquipItem(playerId, slot, itemId)
	if not inventory then
		Remotes.InventoryUpdate:FireClient(player, { success = false, err = err or "equip_failed" })
		return
	end

	Remotes.InventoryUpdate:FireClient(player, { success = true, inventory = inventory })

	if slot == "aura" then
		if player.Character then
			player.Character:SetAttribute("EquippedAuraId", itemId)
		end
		Remotes.AuraEquipped:FireAllClients({
			player_user_id = player.UserId,
			item_id = itemId,
		})
	end
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		applyEquippedAuraAttribute(player, character)
	end)
	if player.Character then
		applyEquippedAuraAttribute(player, player.Character)
	end
end)

for _, player in ipairs(Players:GetPlayers()) do
	player.CharacterAdded:Connect(function(character)
		applyEquippedAuraAttribute(player, character)
	end)
	if player.Character then
		applyEquippedAuraAttribute(player, player.Character)
	end
end
