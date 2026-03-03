--[[
	RewardOverlay.client.lua
	Shows a focused reward popup when a dungeon run completes.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
if not player then
	return
end

local dungeonRemotes = ReplicatedStorage:WaitForChild("DungeonRemotes")
local dungeonUpdate = dungeonRemotes:WaitForChild("DungeonUpdate")

local gui = Instance.new("ScreenGui")
gui.Name = "RewardOverlayGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local dim = Instance.new("Frame")
dim.Name = "Dim"
dim.Size = UDim2.new(1, 0, 1, 0)
dim.BackgroundColor3 = Color3.fromRGB(5, 8, 14)
dim.BackgroundTransparency = 0.35
dim.Visible = false
dim.Parent = gui

local card = Instance.new("Frame")
card.Name = "Card"
card.Size = UDim2.new(0.36, 0, 0.28, 0)
card.Position = UDim2.new(0.32, 0, 0.34, 0)
card.BackgroundColor3 = Color3.fromRGB(24, 34, 52)
card.BorderSizePixel = 0
card.Parent = dim

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 38)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 1
title.Text = "Run Complete"
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255, 247, 196)
title.Font = Enum.Font.GothamBold
title.Parent = card

local body = Instance.new("TextLabel")
body.Size = UDim2.new(1, -20, 0, 88)
body.Position = UDim2.new(0, 10, 0, 56)
body.BackgroundTransparency = 1
body.TextWrapped = true
body.Text = "Reward: +0 Coins, +0 Tokens"
body.TextScaled = true
body.TextColor3 = Color3.fromRGB(222, 234, 255)
body.Font = Enum.Font.Gotham
body.Parent = card

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0.7, 0, 0, 38)
closeButton.Position = UDim2.new(0.15, 0, 1, -50)
closeButton.BackgroundColor3 = Color3.fromRGB(68, 130, 236)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Text = "Continue"
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = card

local function showReward(outcome, reward)
	local coins = reward and reward.coins or 0
	local tokens = reward and reward.tokens or 0
	body.Text = string.format(
		"Outcome: %s\nReward: +%d Coins, +%d Tokens",
		tostring(outcome or "won"),
		coins,
		tokens
	)
	dim.Visible = true
end

closeButton.MouseButton1Click:Connect(function()
	dim.Visible = false
end)

dungeonUpdate.OnClientEvent:Connect(function(payload)
	if not payload or not payload.success then
		return
	end
	if payload.action ~= "run_completed" then
		return
	end
	local result = payload.result or {}
	if not result.reward then
		return
	end
	showReward(result.outcome, result.reward)
end)
