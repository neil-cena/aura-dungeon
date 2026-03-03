--[[
	RiftReward.spec.lua
	Day 3: Reward non-zero and single-apply. Reject duplicate completion.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local server = ServerScriptService.server
local OnboardingService = require(server.domain.OnboardingService)
local RiftService = require(server.domain.RiftService)
local ProfileStore = require(server.persistence.ProfileStore)
local OnboardingConfig = require(ReplicatedStorage.shared.config.OnboardingConfig)

local function runRiftRewardTests()
	local passed = 0
	local failed = 0

	ProfileStore.ClearCache()
	local playerId = "test-rift-001"

	-- Setup: full onboarding path to firstCombat
	OnboardingService.GetState(playerId)
	OnboardingService.RecordFirstInteraction(playerId)
	OnboardingService.MarkFirstRollComplete(playerId)
	OnboardingService.StartBeginnerRift(playerId)
	OnboardingService.RecordFirstCombat(playerId)

	-- Test 1: CompleteBeginnerRift grants non-zero reward
	local profileBefore = ProfileStore.GetProfile(playerId)
	local coinsBefore = (profileBefore.currencies or {}).coins or 0
	local tokensBefore = (profileBefore.currencies or {}).tokens or 0

	local ok, err = RiftService.CompleteBeginnerRift(playerId)
	if not ok then
		failed = failed + 1
	else
		passed = passed + 1
	end

	local profileAfter = ProfileStore.GetProfile(playerId)
	local coinsAfter = (profileAfter.currencies or {}).coins or 0
	local tokensAfter = (profileAfter.currencies or {}).tokens or 0

	if (coinsAfter - coinsBefore) <= 0 and (tokensAfter - tokensBefore) <= 0 then
		failed = failed + 1
	else
		passed = passed + 1
	end

	-- Test 2: Duplicate CompleteBeginnerRift returns false
	local ok2, _ = RiftService.CompleteBeginnerRift(playerId)
	if ok2 then
		failed = failed + 1
	else
		passed = passed + 1
	end

	-- Test 3: Reward amount matches config
	local expectedCoins = OnboardingConfig.BeginnerRiftReward.coins or 0
	local expectedTokens = OnboardingConfig.BeginnerRiftReward.tokens or 0
	if (coinsAfter - coinsBefore) ~= expectedCoins or (tokensAfter - tokensBefore) ~= expectedTokens then
		failed = failed + 1
	else
		passed = passed + 1
	end

	return passed, failed
end

return { run = runRiftRewardTests }
