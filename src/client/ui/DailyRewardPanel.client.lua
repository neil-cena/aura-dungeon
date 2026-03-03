--[[
	DailyRewardPanel.client.lua
	Phase 3: claim daily reward from top-right mini panel.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
if not player then
	return
end

local dailyRemotes = ReplicatedStorage:WaitForChild("DailyRewardRemotes")
local getDailyState = dailyRemotes:WaitForChild("GetDailyRewardState")
local claimDailyReward = dailyRemotes:WaitForChild("ClaimDailyReward")

local gui = Instance.new("ScreenGui")
gui.Name = "DailyRewardPanel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 230, 0, 76)
frame.Position = UDim2.new(1, -242, 0, 8)
frame.BackgroundColor3 = Color3.fromRGB(28, 37, 56)
frame.BackgroundTransparency = 0.18
frame.BorderSizePixel = 0
frame.Parent = gui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -10, 0, 34)
label.Position = UDim2.new(0, 5, 0, 4)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255, 240, 190)
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.Text = "Daily Reward"
label.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(1, -10, 0, 30)
button.Position = UDim2.new(0, 5, 0, 40)
button.BackgroundColor3 = Color3.fromRGB(80, 146, 90)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextScaled = true
button.Font = Enum.Font.GothamBold
button.Text = "Checking..."
button.Parent = frame

local function refresh()
	local resp = getDailyState:InvokeServer()
	if not (resp and resp.success and resp.state) then
		button.Text = "Unavailable"
		button.Active = false
		return
	end
	local state = resp.state
	local reward = state.reward or { coins = 0, tokens = 0 }
	if state.can_claim then
		button.Text = string.format("Claim +%dC +%dT", reward.coins or 0, reward.tokens or 0)
		button.Active = true
		button.BackgroundColor3 = Color3.fromRGB(80, 146, 90)
	else
		button.Text = "Claimed Today"
		button.Active = false
		button.BackgroundColor3 = Color3.fromRGB(96, 96, 96)
	end
end

button.MouseButton1Click:Connect(function()
	if not button.Active then
		return
	end
	local resp = claimDailyReward:InvokeServer()
	if resp and resp.success then
		button.Text = "Claimed!"
		button.Active = false
		button.BackgroundColor3 = Color3.fromRGB(96, 96, 96)
	else
		button.Text = "Try Again"
	end
	task.delay(0.6, refresh)
end)

task.defer(refresh)
