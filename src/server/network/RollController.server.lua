--[[
	RollController.server.lua
	Remote handler: accepts lane only, rejects client overrides, rate-limits.
	Calls RollService and fires read-only result to client.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(script.Parent.Remotes)
local RollService = require(script.Parent.Parent.domain.RollService)
local RollTypes = require(ReplicatedStorage.shared.types.RollTypes)
local OnboardingService = require(script.Parent.Parent.domain.OnboardingService)
local OnboardingConfig = require(ReplicatedStorage.shared.config.OnboardingConfig)

local ROLL_COOLDOWN_SEC = 0.5
local lastRollTime = {}

Remotes.RequestRoll.OnServerEvent:Connect(function(player, laneOrPayload)
	local playerId = tostring(player.UserId)

	local lane
	if type(laneOrPayload) == "string" then
		lane = laneOrPayload
	elseif type(laneOrPayload) == "table" and laneOrPayload and laneOrPayload.lane then
		if not RollTypes.IsSafeRollRequest(laneOrPayload) then
			Remotes.RollResult:FireClient(player, { success = false, err = "invalid_request" })
			return
		end
		lane = laneOrPayload.lane
	else
		Remotes.RollResult:FireClient(player, { success = false, err = "invalid_request" })
		return
	end

	if not RollTypes.IsValidLane(lane) then
		Remotes.RollResult:FireClient(player, { success = false, err = "invalid_lane" })
		return
	end

	-- Rate limit
	local now = os.clock()
	if lastRollTime[playerId] and (now - lastRollTime[playerId]) < ROLL_COOLDOWN_SEC then
		Remotes.RollResult:FireClient(player, { success = false, err = "rate_limited" })
		return
	end
	lastRollTime[playerId] = now

	local result, err = RollService.ExecuteRoll(playerId, lane)
	if not result then
		Remotes.RollResult:FireClient(player, { success = false, err = err or "roll_failed" })
		return
	end

	-- Day 3: Mark first roll complete if in onboarding firstInteraction step
	local state, _ = OnboardingService.GetState(playerId)
	if state and state.current_step == OnboardingConfig.Step.FirstInteraction then
		OnboardingService.MarkFirstRollComplete(playerId)
	end

	Remotes.RollResult:FireClient(player, { success = true, result = result })
end)
