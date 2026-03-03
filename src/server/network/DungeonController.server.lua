--[[
	DungeonController.server.lua
	Day 4: Handles dungeon run start/progress/complete with server authority.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(script.Parent.Remotes)
local RiftService = require(script.Parent.Parent.domain.RiftService)
local DungeonTypes = require(ReplicatedStorage.shared.types.DungeonTypes)

local PHASE_COOLDOWN_SEC = 0.2
local lastPhaseEvent = {}

Remotes.GetDungeonState.OnServerInvoke = function(player)
	local playerId = tostring(player.UserId)
	local state, err = RiftService.GetDungeonState(playerId)
	if not state then
		return { success = false, err = err or "state_not_found" }
	end
	return { success = true, state = state, server_sent_at = os.clock() }
end

Remotes.RequestStartDungeonRun.OnServerEvent:Connect(function(player)
	local playerId = tostring(player.UserId)
	local state, err = RiftService.StartDungeonRun(playerId)
	if not state then
		Remotes.DungeonUpdate:FireClient(player, { success = false, err = err or "start_failed" })
		return
	end
	Remotes.DungeonUpdate:FireClient(player, { success = true, action = "run_started", state = state, server_sent_at = os.clock() })
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

	local state, err = RiftService.AdvanceDungeonPhase(playerId)
	if not state then
		Remotes.DungeonUpdate:FireClient(player, { success = false, err = err or "advance_failed" })
		return
	end
	Remotes.DungeonUpdate:FireClient(player, { success = true, action = "phase_advanced", state = state, server_sent_at = os.clock() })
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

	local result, err = RiftService.CompleteDungeonRun(playerId, didWin)
	if not result then
		Remotes.DungeonUpdate:FireClient(player, { success = false, err = err or "complete_failed" })
		return
	end

	Remotes.DungeonUpdate:FireClient(player, {
		success = true,
		action = "run_completed",
		result = result,
		server_sent_at = os.clock(),
	})
end)

