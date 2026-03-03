--[[
	RiftService.lua
	Day 3/4: Beginner rift lifecycle + Day 4 dungeon run delegates.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OnboardingConfig = require(ReplicatedStorage.shared.config.OnboardingConfig)
local DungeonConfig = require(ReplicatedStorage.shared.config.DungeonConfig)
local ProfileStore = require(script.Parent.Parent.persistence.ProfileStore)
local OnboardingService = require(script.Parent.OnboardingService)
local DungeonService = require(script.Parent.DungeonService)

local RiftService = {}

--[[
	CompleteBeginnerRift(playerId) -> (success, err)
	Grants onboarding reward and marks onboarding returned. Rejects duplicate completion.
]]
function RiftService.CompleteBeginnerRift(playerId)
	if type(playerId) ~= "string" or playerId == "" then
		return false, "invalid player id"
	end

	local state, err = OnboardingService.GetState(playerId)
	if not state then
		return false, err or "state not found"
	end
	if not state.in_rift or state.current_step == OnboardingConfig.Step.ReturnedHub then
		return false, "not in rift or already completed"
	end
	if not state.ts_first_combat then
		return false, "first combat required before completion"
	end

	local reward = OnboardingConfig.BeginnerRiftReward
	local ok, updateErr = ProfileStore.UpdateProfile(playerId, function(p)
		p.currencies = p.currencies or {}
		p.currencies.coins = (p.currencies.coins or 0) + (reward.coins or 0)
		p.currencies.tokens = (p.currencies.tokens or 0) + (reward.tokens or 0)
		local obs = p.progression and p.progression.onboarding_state or {}
		obs.current_step = OnboardingConfig.Step.ReturnedHub
		obs.ts_rewarded = obs.ts_rewarded or os.clock()
		obs.ts_returned_hub = os.clock()
		obs.in_rift = false
		p.progression = p.progression or {}
		p.progression.onboarding_state = obs
		return p, nil
	end)

	if not ok then
		return false, updateErr or "profile update failed"
	end

	return true, nil
end

-- Day 4 delegates
function RiftService.StartDungeonRun(playerId)
	return DungeonService.StartRun(playerId)
end

function RiftService.AdvanceDungeonPhase(playerId)
	return DungeonService.AdvancePhase(playerId)
end

function RiftService.CompleteDungeonRun(playerId, didWin)
	local outcome = didWin and DungeonConfig.Status.Won or DungeonConfig.Status.Lost
	return DungeonService.CompleteRun(playerId, outcome)
end

function RiftService.GetDungeonState(playerId)
	return DungeonService.GetState(playerId)
end

return RiftService

