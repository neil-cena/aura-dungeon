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
local shared = ReplicatedStorage:WaitForChild("shared")
local UITheme = require(shared.config.UITheme)

local socialRemotes = ReplicatedStorage:WaitForChild("SocialRemotes")
local globalCelebration = socialRemotes:WaitForChild("GlobalCelebration")
local getLeaderboard = socialRemotes:WaitForChild("GetLeaderboard")
local leaderboardCache = nil
local leaderboardCachedAt = 0
local LEADERBOARD_CACHE_TTL_SEC = 15

local gui = Instance.new("ScreenGui")
gui.Name = "SocialFeedUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local banner = Instance.new("TextLabel")
banner.Size = UDim2.new(0.62, 0, 0, 42)
banner.Position = UDim2.new(0.19, 0, 0.11, 0)
banner.BackgroundColor3 = UITheme.Colors.AccentGold
banner.BackgroundTransparency = 0.12
banner.TextColor3 = Color3.fromRGB(40, 22, 70)
banner.TextScaled = true
banner.Font = Enum.Font.GothamBold
banner.Text = ""
banner.Visible = false
banner.Parent = gui

local board = Instance.new("Frame")
board.Size = UDim2.new(0.5, 0, 0.38, 0)
board.Position = UDim2.new(0.02, 0, 0.36, 0)
UITheme.ApplyPanel(board, false)
board.Visible = false
board.Parent = gui

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(260, 210)
sizeConstraint.MaxSize = Vector2.new(520, 420)
sizeConstraint.Parent = board

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 0, 30)
title.Position = UDim2.new(0, 5, 0, 4)
title.BackgroundTransparency = 1
title.TextColor3 = UITheme.Colors.TextPrimary
title.Text = "Top Dungeon Clears"
title.Font = Enum.Font.GothamBold
title.Parent = board
UITheme.ApplyResponsiveText(title, "title", true)

local body = Instance.new("TextLabel")
body.Size = UDim2.new(1, -12, 1, -42)
body.Position = UDim2.new(0, 6, 0, 36)
body.BackgroundColor3 = UITheme.Colors.PanelDeep
body.BackgroundTransparency = 0.2
body.BorderSizePixel = 0
body.TextColor3 = UITheme.Colors.TextSecondary
body.TextWrapped = true
body.TextXAlignment = Enum.TextXAlignment.Left
body.TextYAlignment = Enum.TextYAlignment.Top
body.TextSize = UITheme.GetTextSize("body")
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
	local now = os.clock()
	if leaderboardCache and (now - leaderboardCachedAt) <= LEADERBOARD_CACHE_TTL_SEC then
		body.Text = leaderboardCache
		return
	end
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
	leaderboardCache = table.concat(lines, "\n")
	leaderboardCachedAt = now
	body.Text = leaderboardCache
end

local function toggleBoard()
	board.Visible = not board.Visible
	if board.Visible then
		refreshBoard()
	end
end

local function applySafeArea()
	local fn = _G.AuraApplySafeArea
	if fn then
		fn(banner, { top = true, left = true, right = true })
		fn(board, { top = true, left = true, bottom = true })
	end
end

local function registerPanel()
	local register = _G.AuraRegisterPanel
	if register then
		register("social", "Social", toggleBoard, function()
			return board.Visible
		end)
	end
end

globalCelebration.OnClientEvent:Connect(function(payload)
	if type(payload) ~= "table" then
		return
	end
	local who = tostring(payload.player_name or "A player")
	local rarity = tostring(payload.rarity or "Rare")
	showBanner(string.format("%s rolled a %s!", who, rarity))
	if board.Visible then
		refreshBoard()
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.L then
		toggleBoard()
	end
end)

applySafeArea()
registerPanel()
