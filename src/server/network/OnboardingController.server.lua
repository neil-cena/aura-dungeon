--[[
	OnboardingController.server.lua
	Day 3: Handles GetOnboardingState and RequestFirstInteraction.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(script.Parent.Remotes)
local OnboardingService = require(script.Parent.Parent.domain.OnboardingService)
local OnboardingTypes = require(ReplicatedStorage.shared.types.OnboardingTypes)

Remotes.GetOnboardingState.OnServerInvoke = function(player)
	local playerId = tostring(player.UserId)
	local state, err = OnboardingService.GetState(playerId)
	if not state then
		return { success = false, err = err or "state_not_found" }
	end
	return { success = true, state = state }
end

Remotes.RequestFirstInteraction.OnServerEvent:Connect(function(player)
	local playerId = tostring(player.UserId)
	OnboardingService.RecordFirstInteraction(playerId)
end)
