--[[
	OnboardingService.lua
	Day 3: Authoritative state machine for onboarding.
	Transitions: spawned -> firstInteraction -> firstRoll -> riftEntered -> firstCombat -> rewarded -> returnedHub.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OnboardingConfig = require(ReplicatedStorage.shared.config.OnboardingConfig)
local OnboardingTypes = require(ReplicatedStorage.shared.types.OnboardingTypes)
local ProfileStore = require(script.Parent.Parent.persistence.ProfileStore)

local OnboardingService = {}

local STEP_ORDER = {
	[OnboardingConfig.Step.Spawned] = 1,
	[OnboardingConfig.Step.FirstInteraction] = 2,
	[OnboardingConfig.Step.FirstRoll] = 3,
	[OnboardingConfig.Step.RiftEntered] = 4,
	[OnboardingConfig.Step.FirstCombat] = 5,
	[OnboardingConfig.Step.Rewarded] = 6,
	[OnboardingConfig.Step.ReturnedHub] = 7,
}

local function getNextStep(current)
	if current == OnboardingConfig.Step.Spawned then
		return OnboardingConfig.Step.FirstInteraction
	end
	if current == OnboardingConfig.Step.FirstInteraction then
		return OnboardingConfig.Step.FirstRoll
	end
	if current == OnboardingConfig.Step.FirstRoll then
		return OnboardingConfig.Step.RiftEntered
	end
	if current == OnboardingConfig.Step.RiftEntered then
		return OnboardingConfig.Step.FirstCombat
	end
	if current == OnboardingConfig.Step.FirstCombat then
		return OnboardingConfig.Step.Rewarded
	end
	if current == OnboardingConfig.Step.Rewarded then
		return OnboardingConfig.Step.ReturnedHub
	end
	return nil
end

local function ensureOnboardingState(profile)
	profile.progression = profile.progression or {}
	profile.progression.onboarding_state = profile.progression.onboarding_state or {}
	local obs = profile.progression.onboarding_state
	if not obs.current_step then
		obs.current_step = OnboardingConfig.Step.Spawned
		obs.ts_spawned = obs.ts_spawned or os.clock()
	end
	return obs
end

--[[
	GetState(playerId) -> (state, err)
	state: { current_step, ts_spawned, ts_first_interaction, ... }
]]
function OnboardingService.GetState(playerId)
	if type(playerId) ~= "string" or playerId == "" then
		return nil, "invalid player id"
	end
	local profile, err = ProfileStore.GetProfile(playerId)
	if not profile then
		return nil, err or "profile not found"
	end
	local obs = ensureOnboardingState(profile)
	return {
		current_step = obs.current_step,
		ts_spawned = obs.ts_spawned,
		ts_first_interaction = obs.ts_first_interaction,
		ts_first_roll = obs.ts_first_roll,
		ts_rift_entered = obs.ts_rift_entered,
		ts_first_combat = obs.ts_first_combat,
		ts_rewarded = obs.ts_rewarded,
		ts_returned_hub = obs.ts_returned_hub,
		in_rift = obs.in_rift,
	}, nil
end

function OnboardingService.RecordFirstInteraction(playerId)
	if type(playerId) ~= "string" or playerId == "" then
		return false, "invalid player id"
	end
	local ok, err = ProfileStore.UpdateProfile(playerId, function(p)
		local obs = ensureOnboardingState(p)
		if obs.current_step ~= OnboardingConfig.Step.Spawned then
			return p, nil
		end
		obs.current_step = OnboardingConfig.Step.FirstInteraction
		obs.ts_first_interaction = os.clock()
		return p, nil
	end)
	return ok, err
end

function OnboardingService.MarkFirstRollComplete(playerId)
	if type(playerId) ~= "string" or playerId == "" then
		return false, "invalid player id"
	end
	local ok, err = ProfileStore.UpdateProfile(playerId, function(p)
		local obs = ensureOnboardingState(p)
		if obs.current_step ~= OnboardingConfig.Step.FirstInteraction then
			return p, nil
		end
		obs.current_step = OnboardingConfig.Step.FirstRoll
		obs.ts_first_roll = os.clock()
		return p, nil
	end)
	return ok, err
end

function OnboardingService.StartBeginnerRift(playerId)
	if type(playerId) ~= "string" or playerId == "" then
		return false, "invalid player id"
	end
	local ok, err = ProfileStore.UpdateProfile(playerId, function(p)
		local obs = ensureOnboardingState(p)
		if obs.current_step ~= OnboardingConfig.Step.FirstRoll then
			return p, nil
		end
		obs.current_step = OnboardingConfig.Step.RiftEntered
		obs.ts_rift_entered = os.clock()
		obs.in_rift = true
		return p, nil
	end)
	return ok, err
end

function OnboardingService.RecordFirstCombat(playerId)
	if type(playerId) ~= "string" or playerId == "" then
		return false, "invalid player id"
	end
	local ok, err = ProfileStore.UpdateProfile(playerId, function(p)
		local obs = ensureOnboardingState(p)
		if obs.current_step ~= OnboardingConfig.Step.RiftEntered and obs.current_step ~= OnboardingConfig.Step.FirstCombat then
			return p, nil
		end
		if obs.ts_first_combat then
			return p, nil
		end
		obs.current_step = OnboardingConfig.Step.FirstCombat
		obs.ts_first_combat = os.clock()
		return p, nil
	end)
	return ok, err
end

function OnboardingService.MarkRewardedAndReturned(playerId)
	if type(playerId) ~= "string" or playerId == "" then
		return false, "invalid player id"
	end
	local ok, err = ProfileStore.UpdateProfile(playerId, function(p)
		local obs = ensureOnboardingState(p)
		obs.current_step = OnboardingConfig.Step.ReturnedHub
		obs.ts_rewarded = obs.ts_rewarded or os.clock()
		obs.ts_returned_hub = os.clock()
		obs.in_rift = false
		return p, nil
	end)
	return ok, err
end

--[[
	GetTimingSnapshot(playerId) -> (snapshot, err)
	snapshot: { first_interaction_s, first_combat_s, rewarded_s, loop_complete }
]]
function OnboardingService.GetTimingSnapshot(playerId)
	local state, err = OnboardingService.GetState(playerId)
	if not state then
		return nil, err
	end
	local ts = state.ts_spawned or 0
	local snapshot = {
		first_interaction_s = state.ts_first_interaction and (state.ts_first_interaction - ts) or nil,
		first_combat_s = state.ts_first_combat and (state.ts_first_combat - ts) or nil,
		rewarded_s = state.ts_rewarded and (state.ts_rewarded - ts) or nil,
	}
	snapshot.loop_complete = snapshot.rewarded_s and snapshot.rewarded_s <= OnboardingConfig.Timing.MeaningfulRewardMax
	return snapshot, nil
end

return OnboardingService
