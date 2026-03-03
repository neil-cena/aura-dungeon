--[[
	RiftController.server.lua
	Day 3: Handles rift start, combat action, complete.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(script.Parent.Remotes)
local OnboardingService = require(script.Parent.Parent.domain.OnboardingService)
local RiftService = require(script.Parent.Parent.domain.RiftService)
local OnboardingTypes = require(ReplicatedStorage.shared.types.OnboardingTypes)
local OnboardingConfig = require(ReplicatedStorage.shared.config.OnboardingConfig)

-- RequestStartBeginnerRift
Remotes.RequestStartBeginnerRift.OnServerEvent:Connect(function(player)
	local playerId = tostring(player.UserId)
	local ok, err = OnboardingService.StartBeginnerRift(playerId)
	if not ok then
		Remotes.OnboardingResult:FireClient(player, { success = false, err = err or "rift_start_failed" })
		return
	end
	Remotes.OnboardingResult:FireClient(player, { success = true, action = "rift_started" })
end)

-- ReportCombatAction
Remotes.ReportCombatAction.OnServerEvent:Connect(function(player, payload)
	local playerId = tostring(player.UserId)
	if payload ~= nil and not OnboardingTypes.IsSafeCombatAction(payload) then
		return
	end
	OnboardingService.RecordFirstCombat(playerId)
end)

-- RequestCompleteBeginnerRift
Remotes.RequestCompleteBeginnerRift.OnServerEvent:Connect(function(player)
	local playerId = tostring(player.UserId)
	local ok, err = RiftService.CompleteBeginnerRift(playerId)
	if not ok then
		Remotes.OnboardingResult:FireClient(player, { success = false, err = err or "rift_complete_failed" })
		return
	end
	local state, _ = OnboardingService.GetState(playerId)
	Remotes.OnboardingResult:FireClient(player, {
		success = true,
		action = "rift_completed",
		reward = OnboardingConfig.BeginnerRiftReward,
		state = state,
	})
end)
