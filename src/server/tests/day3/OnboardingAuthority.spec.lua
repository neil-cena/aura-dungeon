--[[
	OnboardingAuthority.spec.lua
	Day 3: Reject out-of-order or forged transitions. Server enforces valid state machine.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local server = ServerScriptService.server
local OnboardingService = require(server.domain.OnboardingService)
local ProfileStore = require(server.persistence.ProfileStore)
local OnboardingConfig = require(ReplicatedStorage.shared.config.OnboardingConfig)

local function runAuthorityTests()
	local passed = 0
	local failed = 0

	ProfileStore.ClearCache()
	local playerId = "test-auth-001"

	-- Initialize
	OnboardingService.GetState(playerId)

	-- Test 1: MarkFirstRollComplete when still Spawned -> no-op (idempotent), stays Spawned
	OnboardingService.MarkFirstRollComplete(playerId)
	local s1, _ = OnboardingService.GetState(playerId)
	if s1.current_step ~= OnboardingConfig.Step.Spawned then
		failed = failed + 1
	else
		passed = passed + 1
	end

	-- Test 2: StartBeginnerRift when Spawned -> rejected (must be FirstRoll)
	OnboardingService.StartBeginnerRift(playerId)
	local s2, _ = OnboardingService.GetState(playerId)
	if s2.current_step ~= OnboardingConfig.Step.Spawned then
		failed = failed + 1
	else
		passed = passed + 1
	end

	-- Test 3: Valid sequence - firstInteraction then firstRoll
	OnboardingService.RecordFirstInteraction(playerId)
	OnboardingService.MarkFirstRollComplete(playerId)
	local s3, _ = OnboardingService.GetState(playerId)
	if s3.current_step ~= OnboardingConfig.Step.FirstRoll then
		failed = failed + 1
	else
		passed = passed + 1
	end

	-- Test 4: OnboardingTypes rejects forbidden payload keys
	local OnboardingTypes = require(ReplicatedStorage.shared.types.OnboardingTypes)
	if OnboardingTypes.IsSafeOnboardingRequest({ step = "spawned" }) then
		failed = failed + 1
	else
		passed = passed + 1
	end

	return passed, failed
end

return { run = runAuthorityTests }
