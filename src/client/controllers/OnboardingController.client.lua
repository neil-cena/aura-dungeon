--[[
	OnboardingController.client.lua
	Day 3: Orchestrates onboarding prompt flow using server state.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
if not player then
	return
end

local OnboardingRemotes = ReplicatedStorage:WaitForChild("OnboardingRemotes", 10)
local RollRemotes = ReplicatedStorage:WaitForChild("RollRemotes", 10)
if not OnboardingRemotes or not RollRemotes then
	return
end

local GetOnboardingState = OnboardingRemotes:FindFirstChild("GetOnboardingState")
local RequestFirstInteraction = OnboardingRemotes:FindFirstChild("RequestFirstInteraction")
local OnboardingResult = OnboardingRemotes:FindFirstChild("OnboardingResult")
local RequestRoll = RollRemotes:FindFirstChild("RequestRoll")
local RollResult = RollRemotes:FindFirstChild("RollResult")

if not GetOnboardingState or not RequestFirstInteraction or not RequestRoll or not RollResult then
	return
end

local OnboardingConfig = require(ReplicatedStorage.shared.config.OnboardingConfig)

local currentState = nil

local function fetchState()
	if GetOnboardingState and GetOnboardingState:IsA("RemoteFunction") then
		local result = GetOnboardingState:InvokeServer()
		if result and result.success and result.state then
			currentState = result.state
			return currentState
		end
	end
	return nil
end

local function fireFirstInteraction()
	if RequestFirstInteraction then
		RequestFirstInteraction:FireServer()
	end
end

local function fireRoll()
	if RequestRoll then
		RequestRoll:FireServer({ lane = "Aura" })
	end
end

-- Export for OnboardingOverlay
local OnboardingController = {}
OnboardingController.GetState = fetchState
OnboardingController.FireFirstInteraction = fireFirstInteraction
OnboardingController.FireRoll = fireRoll
OnboardingController.Step = OnboardingConfig.Step
OnboardingController.Prompts = OnboardingConfig.Prompts

-- Listen for rift result
if OnboardingResult then
	OnboardingResult.OnClientEvent:Connect(function(payload)
		if payload and payload.success then
			fetchState()
		end
	end)
end

-- Initial fetch
task.defer(function()
	fetchState()
end)

return OnboardingController
