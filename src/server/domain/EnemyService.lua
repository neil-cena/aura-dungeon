--[[
	EnemyService.lua
	Spawns simple enemy placeholders in dungeon arenas and tracks health.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local EnemyCatalog = require(ReplicatedStorage.shared.config.EnemyCatalog)
local DungeonConfig = require(ReplicatedStorage.shared.config.DungeonConfig)
local DungeonTierCatalog = require(ReplicatedStorage.shared.config.DungeonTierCatalog)
local Remotes = require(script.Parent.Parent.network.Remotes)

local EnemyService = {}

local stateByPlayer = {}

local function getArenaFolder(playerId)
	local dungeons = Workspace:FindFirstChild("AuraDungeons")
	if not dungeons then
		return nil
	end
	return dungeons:FindFirstChild(string.format("DungeonArena_%s", playerId))
end

local function cleanupArenaActors(playerId)
	local arena = getArenaFolder(playerId)
	if not arena then
		return
	end
	for _, child in ipairs(arena:GetChildren()) do
		if child:IsA("BasePart") then
			if CollectionService:HasTag(child, "AuraEnemy") or child.Name == "Boss" or string.sub(child.Name, 1, 6) == "Enemy_" then
				CollectionService:RemoveTag(child, "AuraEnemy")
				child:Destroy()
			end
		end
	end
end

local function getMarkerCFrame(arena, markerName, fallback)
	local marker = arena and arena:FindFirstChild(markerName)
	if marker and marker:IsA("BasePart") then
		return marker.CFrame
	end
	return fallback
end

local function spawnPart(arena, name, cframe, isBoss, maxHealth)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = isBoss and Vector3.new(8, 8, 8) or Vector3.new(4, 6, 4)
	p.Anchored = true
	p.CanCollide = true
	p.Material = Enum.Material.Neon
	p.Color = isBoss and Color3.fromRGB(255, 99, 99) or Color3.fromRGB(255, 168, 90)
	p.CFrame = cframe
	p:SetAttribute("EnemyIsBoss", isBoss == true)
	p:SetAttribute("EnemyMaxHealth", maxHealth or 1)
	p:SetAttribute("EnemyCurrentHealth", maxHealth or 1)
	CollectionService:AddTag(p, "AuraEnemy")
	p.Parent = arena
	return p
end

local function getPlayerRoot(playerId)
	local player = Players:GetPlayerByUserId(tonumber(playerId))
	if not player or not player.Character then
		return nil, nil
	end
	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	local root = player.Character:FindFirstChild("HumanoidRootPart")
	return root, humanoid
end

local function startEnemyMoveLoop(playerId, st, enemyPart, speed)
	task.spawn(function()
		while st and st.enemies and st.enemies[enemyPart] and enemyPart and enemyPart.Parent do
			local root = getPlayerRoot(playerId)
			if root then
				local currentPos = enemyPart.Position
				local delta = root.Position - currentPos
				local planar = Vector3.new(delta.X, 0, delta.Z)
				local distance = planar.Magnitude
				if distance > 2 then
					local step = math.min(distance, (speed or 8) * 0.2)
					local direction = planar.Unit
					local nextPos = currentPos + (direction * step)
					enemyPart.CFrame = CFrame.lookAt(nextPos, Vector3.new(root.Position.X, nextPos.Y, root.Position.Z))
				end
			end
			task.wait(0.2)
		end
	end)
end

local function runBossTelegraphLoop(playerId, st, bossPart, tierId)
	local tier = DungeonTierCatalog.GetTier(tierId) or DungeonTierCatalog.GetTier(DungeonTierCatalog.DefaultTier)
	local token = (st.boss_token or 0) + 1
	st.boss_token = token
	task.spawn(function()
		local preHit = DungeonConfig.Telegraph.PreHitSeconds or 1.2
		local radius = 11
		local damage = math.max(1, math.floor(18 * (tier.enemy_damage_mult or 1)))
		while st and st.boss_token == token and st.enemies and st.enemies[bossPart] and bossPart and bossPart.Parent do
			task.wait(3.5)
			if not (st and st.boss_token == token and st.enemies[bossPart] and bossPart and bossPart.Parent) then
				break
			end
			local player = Players:GetPlayerByUserId(tonumber(playerId))
			if player then
				pcall(function()
					Remotes.CombatUpdate:FireClient(player, {
						success = true,
						boss_telegraph = true,
						position = bossPart.Position,
						radius = radius,
						pre_hit_seconds = preHit,
						prompt_text = DungeonConfig.Telegraph.PromptText,
					})
				end)
				task.wait(preHit)
				local root, humanoid = getPlayerRoot(playerId)
				local didHit = false
				if root and humanoid and humanoid.Health > 0 then
					local dist = (Vector3.new(root.Position.X, 0, root.Position.Z) - Vector3.new(bossPart.Position.X, 0, bossPart.Position.Z)).Magnitude
					if dist <= radius then
						humanoid:TakeDamage(damage)
						didHit = true
					end
				end
				pcall(function()
					Remotes.CombatUpdate:FireClient(player, {
						success = true,
						boss_impact = true,
						did_hit = didHit,
						damage = didHit and damage or 0,
						position = bossPart.Position,
						radius = radius,
					})
				end)
			end
		end
	end)
end

function EnemyService.SpawnWave(playerId, waveIndex, tierId)
	local arena = getArenaFolder(playerId)
	if not arena then
		return nil, "arena_not_found"
	end
	cleanupArenaActors(playerId)
	local tier = DungeonTierCatalog.GetTier(tierId) or DungeonTierCatalog.GetTier(DungeonTierCatalog.DefaultTier)

	stateByPlayer[playerId] = stateByPlayer[playerId] or { enemies = {}, boss = nil }
	local st = stateByPlayer[playerId]
	st.enemies = {}
	st.boss = nil
	local spawnOrigin = getMarkerCFrame(arena, "Spawn", CFrame.new(0, 4, 0))

	for i, entry in ipairs(EnemyCatalog.Wave) do
		local offsetX = (i - 2) * 10
		local enemyCFrame = spawnOrigin * CFrame.new(offsetX, 3, -34)
		local hp = math.max(1, math.floor((entry.health + ((waveIndex - 1) * 5)) * (tier.enemy_health_mult or 1)))
		local part = spawnPart(arena, string.format("Enemy_%d_%s", waveIndex, entry.id), enemyCFrame, false, hp)
		st.enemies[part] = {
			id = entry.id,
			health = hp,
			max_health = hp,
			speed = (entry.speed or 8) * math.min(1.2, tier.enemy_damage_mult or 1),
			is_boss = false,
		}
		startEnemyMoveLoop(playerId, st, part, st.enemies[part].speed)
	end

	return EnemyService.GetEnemySnapshot(playerId), nil
end

function EnemyService.SpawnBoss(playerId, tierId)
	local arena = getArenaFolder(playerId)
	if not arena then
		return nil, "arena_not_found"
	end
	cleanupArenaActors(playerId)
	local tier = DungeonTierCatalog.GetTier(tierId) or DungeonTierCatalog.GetTier(DungeonTierCatalog.DefaultTier)
	stateByPlayer[playerId] = stateByPlayer[playerId] or { enemies = {}, boss = nil }
	local st = stateByPlayer[playerId]
	for enemyPart in pairs(st.enemies) do
		if enemyPart and enemyPart.Parent then
			enemyPart:Destroy()
		end
	end
	st.enemies = {}

	local bossCfg = EnemyCatalog.Boss
	local bossCFrame = getMarkerCFrame(arena, "BossSpawn", CFrame.new(0, 8, -30))
	local bossHealth = math.max(1, math.floor((bossCfg.health or 180) * (tier.enemy_health_mult or 1)))
	local bossSpeed = (bossCfg.speed or 6) * math.min(1.2, tier.enemy_damage_mult or 1)
	local part = spawnPart(arena, "Boss", bossCFrame * CFrame.new(0, 3, 0), true, bossHealth)
	st.boss = part
	st.enemies[part] = { id = bossCfg.id, health = bossHealth, max_health = bossHealth, speed = bossSpeed, is_boss = true }
	startEnemyMoveLoop(playerId, st, part, bossSpeed)
	runBossTelegraphLoop(playerId, st, part, tier.id)
	return EnemyService.GetEnemySnapshot(playerId), nil
end

function EnemyService.ApplyDamage(playerId, targetPart, damage)
	local st = stateByPlayer[playerId]
	if not st then
		return nil, "enemy_state_missing"
	end
	local enemyState = st.enemies[targetPart]
	if not enemyState then
		return nil, "target_not_found"
	end
	enemyState.health = math.max(0, (enemyState.health or 0) - math.max(1, math.floor(damage or 1)))
	targetPart:SetAttribute("EnemyCurrentHealth", enemyState.health)
	local defeated = enemyState.health <= 0
	if defeated then
		st.enemies[targetPart] = nil
		CollectionService:RemoveTag(targetPart, "AuraEnemy")
		if targetPart and targetPart.Parent then
			targetPart:Destroy()
		end
	end
	return {
		defeated = defeated,
		remaining_health = enemyState.health,
		max_health = enemyState.max_health or enemyState.health,
		remaining_count = EnemyService.GetEnemyCount(playerId),
	}, nil
end

function EnemyService.GetPrimaryTarget(playerId)
	local st = stateByPlayer[playerId]
	if not st then
		return nil
	end
	for part in pairs(st.enemies) do
		if part and part.Parent then
			return part
		end
	end
	return nil
end

function EnemyService.GetEnemyCount(playerId)
	local st = stateByPlayer[playerId]
	if not st then
		return 0
	end
	local n = 0
	for part in pairs(st.enemies) do
		if part and part.Parent then
			n = n + 1
		end
	end
	return n
end

function EnemyService.GetEnemySnapshot(playerId)
	local st = stateByPlayer[playerId]
	if not st then
		return { count = 0, has_boss = false }
	end
	return {
		count = EnemyService.GetEnemyCount(playerId),
		has_boss = st.boss ~= nil and st.boss.Parent ~= nil,
	}
end

function EnemyService.Reset(playerId)
	local st = stateByPlayer[playerId]
	if not st then
		return
	end
	for part in pairs(st.enemies) do
		if part and part.Parent then
			CollectionService:RemoveTag(part, "AuraEnemy")
			part:Destroy()
		end
	end
	st.boss_token = (st.boss_token or 0) + 1
	stateByPlayer[playerId] = nil
	cleanupArenaActors(playerId)
end

return EnemyService
