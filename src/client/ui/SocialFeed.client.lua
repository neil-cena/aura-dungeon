--[[
	SocialFeed.client.lua
	Phase 3: global celebration banner + quick leaderboard panel.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
if not player then
	return
end

local socialRemotes = ReplicatedStorage:WaitForChild("SocialRemotes")
local globalCelebration = socialRemotes:WaitForChild("GlobalCelebration")
local getLeaderboard = socialRemotes:WaitForChild("GetLeaderboard")

local gui = Instance.new("ScreenGui")
gui.Name = "SocialFeedUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local banner = Instance.new("TextLabel")
banner.Size = UDim2.new(0.62, 0, 0, 42)
banner.Position = UDim2.new(0.19, 0, 0.11, 0)
banner.BackgroundColor3 = Color3.fromRGB(255, 194, 99)
banner.BackgroundTransparency = 0.12
banner.TextColor3 = Color3.fromRGB(34, 23, 6)
banner.TextScaled = true
banner.Font = Enum.Font.GothamBold
banner.Text = ""
banner.Visible = false
banner.Parent = gui

local board = Instance.new("Frame")
board.Size = UDim2.new(0, 300, 0, 230)
board.Position = UDim2.new(0, 8, 0.22, 0)
board.BackgroundColor3 = Color3.fromRGB(24, 33, 49)
board.BackgroundTransparency = 0.1
board.BorderSizePixel = 0
board.Visible = false
board.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 0, 30)
title.Position = UDim2.new(0, 5, 0, 4)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(233, 241, 255)
title.Text = "Top Dungeon Clears (press L)"
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = board

local body = Instance.new("TextLabel")
body.Size = UDim2.new(1, -12, 1, -42)
body.Position = UDim2.new(0, 6, 0, 36)
body.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
body.BackgroundTransparency = 0.2
body.BorderSizePixel = 0
body.TextColor3 = Color3.fromRGB(216, 228, 255)
body.TextWrapped = true
body.TextXAlignment = Enum.TextXAlignment.Left
body.TextYAlignment = Enum.TextYAlignment.Top
body.TextSize = 15
body.Text = "No leaderboard data."
body.Parent = board

local function showBanner(text)
	banner.Text = text
	banner.Visible = true
	task.delay(3.0, function()
		if banner then
			banner.Visible = false
		end
	end)
end

local function refreshBoard()
	local resp = getLeaderboard:InvokeServer({ limit = 8 })
	if not (resp and resp.success and type(resp.rows) == "table") then
		body.Text = "Leaderboard unavailable."
		return
	end
	if #resp.rows == 0 then
		body.Text = "No leaderboard entries yet."
		return
	end
	local lines = {}
	for i, row in ipairs(resp.rows) do
		table.insert(lines, string.format("%d. %s - clears:%d | lvl:%d", i, tostring(row.player_id), tonumber(row.dungeons_completed or 0), tonumber(row.level or 1)))
	end
	body.Text = table.concat(lines, "\n")
end

globalCelebration.OnClientEvent:Connect(function(payload)
	if type(payload) ~= "table" then
		return
	end
	local who = tostring(payload.player_name or "A player")
	local rarity = tostring(payload.rarity or "Rare")
	showBanner(string.format("%s rolled a %s!", who, rarity))
	refreshBoard()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.L then
		board.Visible = not board.Visible
		if board.Visible then
			refreshBoard()
		end
	end
end)
