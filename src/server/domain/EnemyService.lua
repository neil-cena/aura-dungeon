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
local AssetCatalog = require(ReplicatedStorage.shared.config.AssetCatalog)
local Remotes = require(script.Parent.Parent.network.Remotes)
local VisualFactory = require(script.Parent.Parent.world.VisualFactory)

local EnemyService = {}

local stateByPlayer = {}

local function getArenaFolder(playerId)
	local dungeons = Workspace:FindFirstChild("AuraDungeons")
	if not dungeons then
		return nil
	end
	return dungeons:FindFirstChild(string.format("DungeonArena_%s", playerId))
end

local function isPositionInsideArena(playerId, position)
	if typeof(position) ~= "Vector3" then
		return false
	end
	local arena = getArenaFolder(playerId)
	if not arena then
		return false
	end
	local floor = arena:FindFirstChild("Floor")
	if not floor or not floor:IsA("BasePart") then
		return false
	end
	local localPos = floor.CFrame:PointToObjectSpace(position)
	local halfX = (floor.Size.X * 0.5) + 6
	local halfZ = (floor.Size.Z * 0.5) + 6
	return math.abs(localPos.X) <= halfX and math.abs(localPos.Z) <= halfZ and localPos.Y >= -12 and localPos.Y <= 64
end

local function cleanupArenaActors(playerId)
	local arena = getArenaFolder(playerId)
	if not arena then
		return
	end
	for _, child in ipairs(arena:GetChildren()) do
		if child:IsA("BasePart") or child:IsA("Model") then
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
	p.Color = isBoss and Color3.fromRGB(255, 109, 184) or ((AssetCatalog.Dungeon and AssetCatalog.Dungeon.AccentColor) or Color3.fromRGB(106, 188, 255))
	p.CFrame = cframe
	p:SetAttribute("EnemyIsBoss", isBoss == true)
	p:SetAttribute("EnemyMaxHealth", maxHealth or 1)
	p:SetAttribute("EnemyCurrentHealth", maxHealth or 1)
	CollectionService:AddTag(p, "AuraEnemy")
	p.Parent = arena
	return p, p
end

local function modelPrimaryBasePart(actor)
	if not actor then
		return nil
	end
	if actor:IsA("BasePart") then
		return actor
	end
	if actor:IsA("Model") then
		if actor.PrimaryPart then
			return actor.PrimaryPart
		end
		for _, d in ipairs(actor:GetDescendants()) do
			if d:IsA("BasePart") then
				actor.PrimaryPart = d
				return d
			end
		end
	end
	return nil
end

local function spawnEnemyVisual(arena, enemyId, name, cframe, isBoss, maxHealth)
	local actor = VisualFactory.TrySpawnModel(VisualFactory.GetEnemyModelName(enemyId), arena, cframe, name, { static = false })
	local primary = modelPrimaryBasePart(actor)
	if not actor or not primary then
		return spawnPart(arena, name, cframe, isBoss, maxHealth)
	end
	primary.Anchored = true
	primary.CanCollide = true
	primary:SetAttribute("EnemyIsBoss", isBoss == true)
	primary:SetAttribute("EnemyMaxHealth", maxHealth or 1)
	primary:SetAttribute("EnemyCurrentHealth", maxHealth or 1)
	primary:SetAttribute("EnemyDisplayName", name)
	CollectionService:AddTag(actor, "AuraEnemy")
	return primary, actor
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

local function setActorCFrame(actor, cframe)
	if not actor or not cframe then
		return
	end
	if actor:IsA("Model") then
		actor:PivotTo(cframe)
	elseif actor:IsA("BasePart") then
		actor.CFrame = cframe
	end
end

local function stepEnemy(playerId, enemyPart, enemyState, root, humanoid)
	if not enemyPart or not enemyPart.Parent or not enemyState then
		return
	end
	local currentPos = enemyPart.Position
	local actor = enemyState.actor
	local speed = enemyState.speed or 8
	local playerInArena = root and isPositionInsideArena(playerId, root.Position)
	if not playerInArena then
		-- Keep enemies in their arena while player is in hub/outside.
		local homeCFrame = enemyState.home_cframe
		if homeCFrame then
			local deltaHome = homeCFrame.Position - currentPos
			local planarHome = Vector3.new(deltaHome.X, 0, deltaHome.Z)
			local distanceHome = planarHome.Magnitude
			if distanceHome > 1 then
				local step = math.min(distanceHome, speed * 0.2)
				local direction = planarHome.Unit
				local nextPos = currentPos + (direction * step)
				local nextCf = CFrame.lookAt(nextPos, Vector3.new(homeCFrame.Position.X, nextPos.Y, homeCFrame.Position.Z))
				setActorCFrame(actor, nextCf)
			end
		end
		return
	end
	local delta = root.Position - currentPos
	local planar = Vector3.new(delta.X, 0, delta.Z)
	local distance = planar.Magnitude
	if distance > 2 then
		local step = math.min(distance, speed * 0.2)
		local direction = planar.Unit
		local nextPos = currentPos + (direction * step)
		local nextCf = CFrame.lookAt(nextPos, Vector3.new(root.Position.X, nextPos.Y, root.Position.Z))
		setActorCFrame(actor, nextCf)
	end
	-- Server-authoritative melee damage when enemies are close.
	if humanoid and humanoid.Health > 0 and distance <= 4.5 then
		local now = os.clock()
		local lastHitAt = tonumber(enemyState.last_hit_at or 0)
		local cooldown = tonumber(enemyState.hit_cooldown or 1.0)
		if now - lastHitAt >= cooldown then
			humanoid:TakeDamage(math.max(1, math.floor(enemyState.damage or 4)))
			enemyState.last_hit_at = now
		end
	end
end

local function startEnemyMoveLoop(playerId, st)
	if not st or st.loop_running then
		return
	end
	st.loop_running = true
	local token = (st.loop_token or 0) + 1
	st.loop_token = token
	task.spawn(function()
		while stateByPlayer[playerId] == st and st.loop_token == token do
			local root, humanoid = getPlayerRoot(playerId)
			for enemyPart, enemyState in pairs(st.enemies or {}) do
				if not enemyPart or not enemyPart.Parent then
					st.enemies[enemyPart] = nil
				else
					stepEnemy(playerId, enemyPart, enemyState, root, humanoid)
				end
			end
			task.wait(0.2)
		end
		if stateByPlayer[playerId] == st and st.loop_token == token then
			st.loop_running = false
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
		local part, actor = spawnEnemyVisual(arena, entry.id, string.format("Enemy_%d_%s", waveIndex, entry.id), enemyCFrame, false, hp)
		part:SetAttribute("EnemyDisplayName", entry.display_name or "Enemy")
		st.enemies[part] = {
			id = entry.id,
			display_name = entry.display_name or "Enemy",
			health = hp,
			max_health = hp,
			speed = (entry.speed or 8) * math.min(1.2, tier.enemy_damage_mult or 1),
			damage = math.max(1, math.floor((entry.damage or 4) * (tier.enemy_damage_mult or 1))),
			hit_cooldown = 1.0,
			is_boss = false,
			actor = actor,
			home_cframe = enemyCFrame,
		}
	end
	startEnemyMoveLoop(playerId, st)

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
	local part, actor = spawnEnemyVisual(arena, bossCfg.id, "Boss", bossCFrame * CFrame.new(0, 3, 0), true, bossHealth)
	part:SetAttribute("EnemyDisplayName", bossCfg.display_name or "Boss")
	st.boss = part
	st.enemies[part] = {
		id = bossCfg.id,
		display_name = bossCfg.display_name or "Boss",
		health = bossHealth,
		max_health = bossHealth,
		speed = bossSpeed,
		damage = math.max(1, math.floor((bossCfg.damage or 12) * (tier.enemy_damage_mult or 1))),
		hit_cooldown = 1.2,
		is_boss = true,
		actor = actor,
		home_cframe = bossCFrame * CFrame.new(0, 3, 0),
	}
	startEnemyMoveLoop(playerId, st)
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
		local actor = enemyState.actor
		st.enemies[targetPart] = nil
		if actor then
			CollectionService:RemoveTag(actor, "AuraEnemy")
			if actor.Parent then
				actor:Destroy()
			end
		else
			CollectionService:RemoveTag(targetPart, "AuraEnemy")
			if targetPart and targetPart.Parent then
				targetPart:Destroy()
			end
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
		local enemyState = st.enemies[part]
		if enemyState and enemyState.actor and enemyState.actor.Parent then
			CollectionService:RemoveTag(enemyState.actor, "AuraEnemy")
			enemyState.actor:Destroy()
		elseif part and part.Parent then
			CollectionService:RemoveTag(part, "AuraEnemy")
			part:Destroy()
		end
	end
	st.boss_token = (st.boss_token or 0) + 1
	stateByPlayer[playerId] = nil
	cleanupArenaActors(playerId)
end

return EnemyService
