--[[
	CombatController.server.lua
	Validates and executes combat attack requests.
]]

local Remotes = require(script.Parent.Remotes)
local CombatService = require(script.Parent.Parent.domain.CombatService)
local RiftService = require(script.Parent.Parent.domain.RiftService)
local EnemyService = require(script.Parent.Parent.domain.EnemyService)
local HubBuilder = require(script.Parent.Parent.world.HubBuilder)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DungeonConfig = require(ReplicatedStorage.shared.config.DungeonConfig)

local ATTACK_COOLDOWN_SEC = 0.2
local lastAttackAt = {}
local autoProgressLockUntil = {}

local function teleportToHub(player)
	if not player or not player.Character then
		return
	end
	local root = player.Character:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = HubBuilder.GetHubSpawnCFrame()
	end
end

local function handleAutoProgression(player, playerId, hit)
	if not hit or tonumber(hit.remaining_count or 0) > 0 then
		return
	end

	local state = RiftService.GetDungeonState(playerId)
	if not state or not state.status then
		return
	end
	local memberIds = state.party_member_ids or { playerId }
	local instanceOwnerId = state.instance_owner_id or playerId
	local lockKey = "instance_" .. tostring(instanceOwnerId)
	local now = os.clock()
	if autoProgressLockUntil[lockKey] and now < autoProgressLockUntil[lockKey] then
		return
	end
	autoProgressLockUntil[lockKey] = now + 0.25

	local function getMemberPlayers()
		local out = {}
		for _, memberId in ipairs(memberIds) do
			local plr = game:GetService("Players"):GetPlayerByUserId(tonumber(memberId))
			if plr then
				table.insert(out, plr)
			end
		end
		return out
	end

	local targetWasBoss = tostring(hit.target_name or "") == "Boss"

	if targetWasBoss or state.status == DungeonConfig.Status.Boss then
		local resultsByMember = {}
		local fallbackResult = nil
		for _, memberId in ipairs(memberIds) do
			local result, completeErr = RiftService.CompleteDungeonRun(memberId, true)
			if not result and completeErr ~= "run already ended" then
				Remotes.DungeonUpdate:FireClient(player, { success = false, err = completeErr or "auto_complete_failed" })
				return
			end
			if result then
				resultsByMember[memberId] = result
				if not fallbackResult then
					fallbackResult = result
				end
			end
		end
		if not fallbackResult then
			-- Idempotent safety: if another path already completed the run,
			-- still drive clients back to a non-combat status.
			fallbackResult = { status = DungeonConfig.Status.Won, outcome = "win" }
		end
		for _, memberPlayer in ipairs(getMemberPlayers()) do
			local memberId = tostring(memberPlayer.UserId)
			Remotes.DungeonUpdate:FireClient(memberPlayer, {
				success = true,
				action = "run_completed",
				result = resultsByMember[memberId] or resultsByMember[playerId] or fallbackResult,
				server_sent_at = os.clock(),
			})
		end
		EnemyService.Reset(instanceOwnerId)
		task.delay(0.2, function()
			for _, memberPlayer in ipairs(getMemberPlayers()) do
				teleportToHub(memberPlayer)
			end
		end)
		return
	end

	if state.status == DungeonConfig.Status.Wave then
		local statesByMember = {}
		for _, memberId in ipairs(memberIds) do
			local nextState, nextErr = RiftService.AdvanceDungeonPhase(memberId)
			if not nextState then
				Remotes.DungeonUpdate:FireClient(player, { success = false, err = nextErr or "auto_advance_failed" })
				return
			end
			statesByMember[memberId] = nextState
		end
		local nextState = statesByMember[playerId] or statesByMember[memberIds[1]]

		local enemyState = nil
		if nextState.status == DungeonConfig.Status.Wave then
			enemyState = EnemyService.SpawnWave(instanceOwnerId, nextState.wave_index or 1, nextState.tier_id)
		elseif nextState.status == DungeonConfig.Status.Boss then
			enemyState = EnemyService.SpawnBoss(instanceOwnerId, nextState.tier_id)
		end

		for _, memberPlayer in ipairs(getMemberPlayers()) do
			local memberId = tostring(memberPlayer.UserId)
			Remotes.DungeonUpdate:FireClient(memberPlayer, {
				success = true,
				action = "phase_auto_advanced",
				state = statesByMember[memberId] or nextState,
				enemy_state = enemyState,
				server_sent_at = os.clock(),
			})
		end
		return
	end

	-- Ignore any other status after a kill resolution edge-case.
end

Remotes.RequestAttack.OnServerEvent:Connect(function(player)
	local playerId = tostring(player.UserId)
	local now = os.clock()
	if lastAttackAt[playerId] and now - lastAttackAt[playerId] < ATTACK_COOLDOWN_SEC then
		Remotes.CombatUpdate:FireClient(player, { success = false, err = "attack_rate_limited" })
		return
	end
	lastAttackAt[playerId] = now

	local hit, err = CombatService.AttackPrimaryTarget(playerId)
	if not hit then
		Remotes.CombatUpdate:FireClient(player, { success = false, err = err or "attack_failed" })
		return
	end
	Remotes.CombatUpdate:FireClient(player, { success = true, hit = hit })
	handleAutoProgression(player, playerId, hit)
end)
