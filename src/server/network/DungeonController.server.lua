--[[
	DungeonController.server.lua
	Day 4: Handles dungeon run start/progress/complete with server authority.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Remotes = require(script.Parent.Remotes)
local RiftService = require(script.Parent.Parent.domain.RiftService)
local DungeonTypes = require(ReplicatedStorage.shared.types.DungeonTypes)
local DungeonArenaBuilder = require(script.Parent.Parent.world.DungeonArenaBuilder)
local HubBuilder = require(script.Parent.Parent.world.HubBuilder)
local EnemyService = require(script.Parent.Parent.domain.EnemyService)
local PartyService = require(script.Parent.Parent.domain.PartyService)
local DungeonConfig = require(ReplicatedStorage.shared.config.DungeonConfig)

local PHASE_COOLDOWN_SEC = 0.2
local lastPhaseEvent = {}
local deathResolveLockUntil = {}

local function teleportCharacter(player, targetCFrame)
	if not player or not targetCFrame then
		return
	end
	local character = player.Character
	if not character then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = targetCFrame
	end
end

local function getPlayersFromIds(memberIds)
	local out = {}
	for _, memberId in ipairs(memberIds or {}) do
		local player = Players:GetPlayerByUserId(tonumber(memberId))
		if player then
			table.insert(out, player)
		end
	end
	return out
end

local function completePartyRun(memberIds, instanceOwnerId, didWin)
	local resultsByMember = {}
	local fallbackResult = nil
	for _, memberId in ipairs(memberIds) do
		local result, err = RiftService.CompleteDungeonRun(memberId, didWin)
		if not result and err ~= "run already ended" then
			return nil, err or "complete_failed"
		end
		if result then
			resultsByMember[memberId] = result
			if not fallbackResult then
				fallbackResult = result
			end
		end
	end
	if not fallbackResult then
		fallbackResult = {
			status = didWin and DungeonConfig.Status.Won or DungeonConfig.Status.Lost,
			outcome = didWin and "win" or "loss",
		}
	end
	for _, memberPlayer in ipairs(getPlayersFromIds(memberIds)) do
		local memberId = tostring(memberPlayer.UserId)
		Remotes.DungeonUpdate:FireClient(memberPlayer, {
			success = true,
			action = "run_completed",
			result = resultsByMember[memberId] or fallbackResult,
			server_sent_at = os.clock(),
		})
	end
	task.delay(0.2, function()
		for _, memberPlayer in ipairs(getPlayersFromIds(memberIds)) do
			teleportCharacter(memberPlayer, HubBuilder.GetHubSpawnCFrame())
		end
	end)
	EnemyService.Reset(instanceOwnerId)
	return true, nil
end

local function handleCharacterDied(player)
	local playerId = tostring(player.UserId)
	local state = RiftService.GetDungeonState(playerId)
	if not state then
		return
	end
	local status = state.status
	if status ~= DungeonConfig.Status.Wave and status ~= DungeonConfig.Status.Boss then
		return
	end
	local lockKey = tostring(state.instance_owner_id or playerId)
	local now = os.clock()
	if deathResolveLockUntil[lockKey] and now < deathResolveLockUntil[lockKey] then
		return
	end
	deathResolveLockUntil[lockKey] = now + 0.6
	local memberIds = state.party_member_ids or { playerId }
	local instanceOwnerId = state.instance_owner_id or playerId
	local ok = completePartyRun(memberIds, instanceOwnerId, false)
	if not ok then
		for _, memberPlayer in ipairs(getPlayersFromIds(memberIds)) do
			Remotes.DungeonUpdate:FireClient(memberPlayer, { success = false, err = "death_resolution_failed" })
		end
	end
end

local function bindCharacter(player, character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		humanoid = character:WaitForChild("Humanoid", 5)
	end
	if humanoid then
		humanoid.Died:Connect(function()
			handleCharacterDied(player)
		end)
	end
end

Remotes.GetDungeonState.OnServerInvoke = function(player)
	local playerId = tostring(player.UserId)
	local state, err = RiftService.GetDungeonState(playerId)
	if not state then
		return { success = false, err = err or "state_not_found" }
	end
	return { success = true, state = state, server_sent_at = os.clock() }
end

Remotes.RequestStartDungeonRun.OnServerEvent:Connect(function(player, payload)
	local playerId = tostring(player.UserId)
	if payload ~= nil and not DungeonTypes.IsSafeDungeonRequest(payload) then
		Remotes.DungeonUpdate:FireClient(player, { success = false, err = "invalid_request" })
		return
	end
	local tierId = nil
	if type(payload) == "table" and type(payload.tier_id) == "string" then
		tierId = payload.tier_id
	end
	local party = PartyService.GetPartyContext(playerId)
	local memberIds = party and party.member_ids or { playerId }
	local instanceOwnerId = party and party.leader_id or playerId
	local isLeader = not party or party.is_leader
	if party and not isLeader then
		Remotes.DungeonUpdate:FireClient(player, { success = false, err = "only_leader_can_start_party_run" })
		return
	end
	local arena = DungeonArenaBuilder.EnsureArena(instanceOwnerId)
	if arena and arena.spawn_cframe then
		for _, memberPlayer in ipairs(getPlayersFromIds(memberIds)) do
			teleportCharacter(memberPlayer, arena.spawn_cframe)
		end
	end
	local startedStates = {}
	for _, memberId in ipairs(memberIds) do
		local state, err = RiftService.StartDungeonRun(memberId, tierId, instanceOwnerId, memberIds)
		if not state then
			Remotes.DungeonUpdate:FireClient(player, { success = false, err = err or "start_failed" })
			return
		end
		startedStates[memberId] = state
	end
	local leaderState = startedStates[instanceOwnerId] or startedStates[playerId]
	local enemyState = EnemyService.SpawnWave(instanceOwnerId, leaderState.wave_index or 1, leaderState.tier_id)
	for _, memberPlayer in ipairs(getPlayersFromIds(memberIds)) do
		local memberId = tostring(memberPlayer.UserId)
		local memberState = startedStates[memberId] or leaderState
		Remotes.DungeonUpdate:FireClient(memberPlayer, {
			success = true,
			action = "run_started",
			state = memberState,
			enemy_state = enemyState,
			server_sent_at = os.clock(),
		})
	end
end)

Remotes.RequestAdvanceDungeonPhase.OnServerEvent:Connect(function(player, payload)
	local playerId = tostring(player.UserId)
	if payload ~= nil and not DungeonTypes.IsSafeDungeonRequest(payload) then
		Remotes.DungeonUpdate:FireClient(player, { success = false, err = "invalid_request" })
		return
	end

	local now = os.clock()
	if lastPhaseEvent[playerId] and (now - lastPhaseEvent[playerId]) < PHASE_COOLDOWN_SEC then
		Remotes.DungeonUpdate:FireClient(player, { success = false, err = "rate_limited" })
		return
	end
	lastPhaseEvent[playerId] = now

	local preState = RiftService.GetDungeonState(playerId)
	if preState and preState.instance_owner_id and preState.instance_owner_id ~= playerId then
		Remotes.DungeonUpdate:FireClient(player, { success = false, err = "only_leader_can_advance_party_phase" })
		return
	end
	if preState and preState.status == DungeonConfig.Status.Boss then
		Remotes.DungeonUpdate:FireClient(player, { success = false, err = "boss_phase_auto_resolves_on_boss_defeat" })
		return
	end

	local state, err = RiftService.AdvanceDungeonPhase(playerId)
	if not state then
		Remotes.DungeonUpdate:FireClient(player, { success = false, err = err or "advance_failed" })
		return
	end
	local memberIds = state.party_member_ids or { playerId }
	local instanceOwnerId = state.instance_owner_id or playerId
	local enemyState = nil
	if state.status == DungeonConfig.Status.Wave then
		enemyState = EnemyService.SpawnWave(instanceOwnerId, state.wave_index or 1, state.tier_id)
	elseif state.status == DungeonConfig.Status.Boss then
		enemyState = EnemyService.SpawnBoss(instanceOwnerId, state.tier_id)
	end
	for _, memberPlayer in ipairs(getPlayersFromIds(memberIds)) do
		local memberId = tostring(memberPlayer.UserId)
		local memberState = memberId == playerId and state or RiftService.GetDungeonState(memberId)
		Remotes.DungeonUpdate:FireClient(memberPlayer, {
			success = true,
			action = "phase_advanced",
			state = memberState,
			enemy_state = enemyState,
			server_sent_at = os.clock(),
		})
	end
end)

Remotes.RequestCompleteDungeonRun.OnServerEvent:Connect(function(player, payload)
	local playerId = tostring(player.UserId)
	if payload ~= nil and type(payload) ~= "table" then
		Remotes.DungeonUpdate:FireClient(player, { success = false, err = "invalid_request" })
		return
	end

	local didWin = true
	if payload and payload.did_win ~= nil then
		didWin = payload.did_win == true
	end

	local state = RiftService.GetDungeonState(playerId)
	if not state then
		Remotes.DungeonUpdate:FireClient(player, { success = false, err = "state_not_found" })
		return
	end
	if state.instance_owner_id and state.instance_owner_id ~= playerId then
		Remotes.DungeonUpdate:FireClient(player, { success = false, err = "only_leader_can_complete_party_run" })
		return
	end
	local memberIds = state.party_member_ids or { playerId }
	local instanceOwnerId = state.instance_owner_id or playerId
	local ok, err = completePartyRun(memberIds, instanceOwnerId, didWin)
	if not ok then
		Remotes.DungeonUpdate:FireClient(player, { success = false, err = err or "complete_failed" })
	end
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		bindCharacter(player, character)
	end)
	if player.Character then
		bindCharacter(player, player.Character)
	end
end)

for _, player in ipairs(Players:GetPlayers()) do
	player.CharacterAdded:Connect(function(character)
		bindCharacter(player, character)
	end)
	if player.Character then
		bindCharacter(player, player.Character)
	end
end

