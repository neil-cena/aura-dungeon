--[[
	OnboardingTypes.lua
	Validators and helpers for onboarding/rift requests.
	Used by server to reject malformed or forged client input.
]]

local OnboardingConfig = require(script.Parent.Parent.config.OnboardingConfig)

local OnboardingTypes = {}

-- Valid step names
local VALID_STEPS = {}
for _, s in pairs(OnboardingConfig.Step) do
	VALID_STEPS[s] = true
end

function OnboardingTypes.IsValidStep(step)
	return type(step) == "string" and VALID_STEPS[step] == true
end

-- Reject payloads with forbidden client fields (Authority Boundary)
local FORBIDDEN_KEYS = {
	step = true,
	current_step = true,
	timestamp = true,
	ts_first_interaction = true,
	ts_first_roll = true,
	ts_rift_entered = true,
	ts_first_combat = true,
	ts_rewarded = true,
	ts_returned_hub = true,
	reward_coins = true,
	reward_tokens = true,
	completed = true,
}

function OnboardingTypes.IsSafeOnboardingRequest(payload)
	if type(payload) ~= "table" then
		return false
	end
	for k, _ in pairs(payload) do
		if FORBIDDEN_KEYS[k] then
			return false
		end
	end
	return true
end

-- Safe combat action request (client reports action; server validates)
function OnboardingTypes.IsSafeCombatAction(payload)
	if type(payload) ~= "table" then
		return false
	end
	-- Allow action_type for future extensibility; no outcome/result from client
	if payload.action_type ~= nil and type(payload.action_type) ~= "string" then
		return false
	end
	return true
end

return OnboardingTypes
