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
local shared = ReplicatedStorage:WaitForChild("shared")
local UITheme = require(shared.config.UITheme)

local dailyRemotes = ReplicatedStorage:WaitForChild("DailyRewardRemotes")
local getDailyState = dailyRemotes:WaitForChild("GetDailyRewardState")
local claimDailyReward = dailyRemotes:WaitForChild("ClaimDailyReward")

local gui = Instance.new("ScreenGui")
gui.Name = "DailyRewardPanel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.3, 0, 0, 76)
frame.Position = UDim2.new(1, -242, 0, 8)
UITheme.ApplyPanel(frame, false)
frame.Parent = gui

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(190, 72)
sizeConstraint.MaxSize = Vector2.new(340, 92)
sizeConstraint.Parent = frame

local function applySafeArea()
	local fn = _G.AuraApplySafeArea
	if fn then
		fn(frame, { top = true, right = true })
	end
end

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -10, 0, 34)
label.Position = UDim2.new(0, 5, 0, 4)
label.BackgroundTransparency = 1
label.TextColor3 = UITheme.Colors.AccentGold
label.Font = Enum.Font.GothamBold
label.Text = "Daily Reward"
label.Parent = frame
UITheme.ApplyResponsiveText(label, "small", true)

local button = Instance.new("TextButton")
button.Size = UDim2.new(1, -10, 0, 30)
button.Position = UDim2.new(0, 5, 0, 40)
button.BackgroundColor3 = UITheme.Colors.Success
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.Text = "Checking..."
button.Parent = frame
UITheme.ApplyResponsiveText(button, "small", false)

local function refresh()
	local resp = getDailyState:InvokeServer()
	if not (resp and resp.success and resp.state) then
		frame.Visible = true
		button.Text = "Unavailable"
		button.Active = false
		return
	end
	local state = resp.state
	local reward = state.reward or { coins = 0, tokens = 0 }
	if state.can_claim then
		frame.Visible = true
		button.Text = string.format("Claim +%dC +%dT", reward.coins or 0, reward.tokens or 0)
		button.Active = true
		button.BackgroundColor3 = UITheme.Colors.Success
	else
		-- Hide daily panel for the rest of the day once already claimed.
		frame.Visible = false
	end
end

button.MouseButton1Click:Connect(function()
	if not button.Active then
		return
	end
	local resp = claimDailyReward:InvokeServer()
	if resp and resp.success then
		frame.Visible = false
	else
		frame.Visible = true
		button.Text = "Try Again"
	end
	task.delay(0.6, refresh)
end)

task.defer(refresh)
task.defer(applySafeArea)
