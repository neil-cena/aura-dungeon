--[[
	OnboardingOverlay.client.lua
	Day 3: Minimal prompts, no wall text. Single button per step.
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

local OnboardingConfig = require(ReplicatedStorage.shared.config.OnboardingConfig)
local GetOnboardingState = OnboardingRemotes:FindFirstChild("GetOnboardingState")
local RequestFirstInteraction = OnboardingRemotes:FindFirstChild("RequestFirstInteraction")
local RequestStartBeginnerRift = OnboardingRemotes:FindFirstChild("RequestStartBeginnerRift")
local ReportCombatAction = OnboardingRemotes:FindFirstChild("ReportCombatAction")
local RequestCompleteBeginnerRift = OnboardingRemotes:FindFirstChild("RequestCompleteBeginnerRift")
local RequestRoll = RollRemotes:FindFirstChild("RequestRoll")
local RollResult = RollRemotes:FindFirstChild("RollResult")

if not GetOnboardingState or not RequestFirstInteraction or not RequestRoll then
	return
end

local gui = Instance.new("ScreenGui")
gui.Name = "OnboardingOverlay"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.4, 0, 0.15, 0)
frame.Position = UDim2.new(0.3, 0, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
frame.BorderSizePixel = 0
frame.Parent = gui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -20, 0.4, 0)
label.Position = UDim2.new(0, 10, 0, 5)
label.BackgroundTransparency = 1
label.Text = ""
label.TextColor3 = Color3.new(1, 1, 1)
label.TextSize = 14
label.TextWrapped = true
label.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(0.9, 0, 0.45, 0)
button.Position = UDim2.new(0.05, 0, 0.5, 0)
button.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
button.Text = ""
button.TextColor3 = Color3.new(1, 1, 1)
button.TextSize = 16
button.Parent = frame

local lastRewardText = ""
local tutorialDismissed = false

local function getState()
	if GetOnboardingState:IsA("RemoteFunction") then
		local r = GetOnboardingState:InvokeServer()
		if r and r.success and r.state then
			return r.state
		end
	end
	return nil
end

local function updateUI()
	local state = getState()
	if not state then
		frame.Visible = false
		return
	end

	local step = state.current_step or OnboardingConfig.Step.Spawned
	if step == OnboardingConfig.Step.Rewarded or step == OnboardingConfig.Step.ReturnedHub then
		tutorialDismissed = true
		frame.Visible = false
		return
	end
	if tutorialDismissed then
		frame.Visible = false
		return
	end

	if step == OnboardingConfig.Step.Spawned then
		frame.Visible = true
		label.Text = OnboardingConfig.Prompts.FirstRoll
		button.Text = "Start"
	elseif step == OnboardingConfig.Step.FirstInteraction then
		frame.Visible = true
		label.Text = OnboardingConfig.Prompts.FirstRoll
		button.Text = "Roll"
	elseif step == OnboardingConfig.Step.FirstRoll then
		frame.Visible = true
		label.Text = OnboardingConfig.Prompts.RiftEnter
		button.Text = "Enter Rift"
	elseif step == OnboardingConfig.Step.RiftEntered or step == OnboardingConfig.Step.FirstCombat then
		frame.Visible = true
		label.Text = OnboardingConfig.Prompts.CombatHint
		button.Text = state.ts_first_combat and "Complete" or "Attack"
	elseif step == OnboardingConfig.Step.Rewarded or step == OnboardingConfig.Step.ReturnedHub then
		frame.Visible = true
		if lastRewardText ~= "" then
			label.Text = lastRewardText
		else
			label.Text = OnboardingConfig.Prompts.ReturnHub
		end
		button.Text = "Done"
	else
		tutorialDismissed = true
		frame.Visible = false
	end
end

button.MouseButton1Click:Connect(function()
	local state = getState()
	if not state then
		RequestFirstInteraction:FireServer()
		task.delay(0.25, updateUI)
		return
	end

	local step = state.current_step or OnboardingConfig.Step.Spawned
	if step == OnboardingConfig.Step.Spawned then
		RequestFirstInteraction:FireServer()
	elseif step == OnboardingConfig.Step.FirstInteraction then
		RequestRoll:FireServer({ lane = "Aura" })
	elseif step == OnboardingConfig.Step.FirstRoll and RequestStartBeginnerRift then
		RequestStartBeginnerRift:FireServer()
	elseif (step == OnboardingConfig.Step.RiftEntered or step == OnboardingConfig.Step.FirstCombat) and not state.ts_first_combat and ReportCombatAction then
		ReportCombatAction:FireServer({})
	elseif (step == OnboardingConfig.Step.RiftEntered or step == OnboardingConfig.Step.FirstCombat) and state.ts_first_combat and RequestCompleteBeginnerRift then
		RequestCompleteBeginnerRift:FireServer()
	elseif step == OnboardingConfig.Step.Rewarded or step == OnboardingConfig.Step.ReturnedHub then
		tutorialDismissed = true
		frame.Visible = false
		return
	end

	task.delay(0.25, updateUI)
end)

RollResult.OnClientEvent:Connect(function()
	task.delay(0.2, updateUI)
end)

local OnboardingResult = OnboardingRemotes:WaitForChild("OnboardingResult", 5)
if OnboardingResult then
	OnboardingResult.OnClientEvent:Connect(function(payload)
		if payload and payload.success and payload.action == "rift_completed" and payload.reward then
			local coins = payload.reward.coins or 0
			local tokens = payload.reward.tokens or 0
			lastRewardText = string.format("Reward received: +%d Coins, +%d Tokens", coins, tokens)
		end
		task.delay(0.15, updateUI)
	end)
end

task.defer(updateUI)
