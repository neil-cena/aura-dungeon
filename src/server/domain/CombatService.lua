--[[
	CombatService.lua
	Server-authoritative attack validation and damage application.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileStore = require(script.Parent.Parent.persistence.ProfileStore)
local EnemyService = require(script.Parent.EnemyService)
local DungeonService = require(script.Parent.DungeonService)
local WeaponCatalog = require(ReplicatedStorage.shared.config.WeaponCatalog)

local CombatService = {}

local function getEquippedWeapon(playerId)
	local profile, err = ProfileStore.GetProfile(playerId)
	if not profile then
		return nil, err
	end
	local equipped = profile.inventory and profile.inventory.equipped
	return equipped and equipped.weapon, nil
end

function CombatService.AttackPrimaryTarget(playerId)
	local player = Players:GetPlayerByUserId(tonumber(playerId))
	if not player or not player.Character then
		return nil, "character_missing"
	end
	local root = player.Character:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil, "root_missing"
	end

	local dungeonState = DungeonService.GetState(playerId)
	local instanceOwnerId = dungeonState and dungeonState.instance_owner_id or playerId
	local target = EnemyService.GetPrimaryTarget(instanceOwnerId)
	if not target then
		return nil, "no_target"
	end

	local weaponId = getEquippedWeapon(playerId)
	local weaponStats = WeaponCatalog.ResolveByItemId(weaponId)
	local range = weaponStats.range or 18
	local distance = (root.Position - target.Position).Magnitude
	if distance > range then
		return nil, "out_of_range"
	end

	local damage = weaponStats.damage or 10
	local hit, err = EnemyService.ApplyDamage(instanceOwnerId, target, damage)
	if not hit then
		return nil, err or "hit_failed"
	end
	hit.damage = damage
	hit.range = range
	hit.weapon_id = weaponId
	hit.target_position = target.Position
	hit.target_name = target.Name
	return hit, nil
end

return CombatService
