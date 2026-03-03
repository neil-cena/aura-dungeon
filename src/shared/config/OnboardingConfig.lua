--[[
	OnboardingConfig.lua
	Day 3: Timing thresholds, reward config, beginner rift identifiers.
	Single source for server and client. Source: milestone-acceptance-matrix Day 3, pillars-v2 §1.2
]]

local OnboardingConfig = {}

-- Onboarding step names (authoritative state machine)
OnboardingConfig.Step = {
	Spawned = "spawned",
	FirstInteraction = "firstInteraction",
	FirstRoll = "firstRoll",
	RiftEntered = "riftEntered",
	FirstCombat = "firstCombat",
	Rewarded = "rewarded",
	ReturnedHub = "returnedHub",
}

-- Timing thresholds (seconds) - Must Pass alignment
OnboardingConfig.Timing = {
	FirstInteractionMax = 5,
	FirstCombatMin = 30,
	FirstCombatMax = 50,
	MeaningfulRewardMax = 60,
}

-- Beginner rift identifier (Day 3 minimal dungeon)
OnboardingConfig.BeginnerRiftId = "beginner_rift_v1"

-- Reward granted on beginner rift completion (meaningful = non-zero economy gain)
OnboardingConfig.BeginnerRiftReward = {
	coins = 50,
	tokens = 10,
}

-- Minimal prompts (no wall text; max 1-2 lines per step)
OnboardingConfig.Prompts = {
	FirstRoll = "Roll to get your first aura.",
	RiftEnter = "Enter the rift.",
	CombatHint = "Defeat the enemy.",
	ReturnHub = "Return to hub.",
}

return OnboardingConfig
