--[[
	BattlePassPanel.client.lua
	Phase 4: season progress + claim UI.
	Toggle with B.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
if not player then
	return
end

local bpRemotes = ReplicatedStorage:WaitForChild("BattlePassRemotes")
local getBattlePassState = bpRemotes:WaitForChild("GetBattlePassState")
local claimBattlePassTier = bpRemotes:WaitForChild("ClaimBattlePassTier")

local gui = Instance.new("ScreenGui")
gui.Name = "BattlePassPanelGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 460, 0, 350)
panel.Position = UDim2.new(0.5, -230, 0.18, 0)
panel.BackgroundColor3 = Color3.fromRGB(24, 31, 50)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -12, 0, 30)
title.Position = UDim2.new(0, 6, 0, 4)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(245, 248, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Text = "Battle Pass (Press B)"
title.Parent = panel

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -12, 0, 20)
info.Position = UDim2.new(0, 6, 0, 34)
info.BackgroundTransparency = 1
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextColor3 = Color3.fromRGB(255, 230, 176)
info.TextSize = 14
info.Text = ""
info.Parent = panel

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -12, 1, -62)
list.Position = UDim2.new(0, 6, 0, 56)
list.BackgroundColor3 = Color3.fromRGB(12, 18, 31)
list.BackgroundTransparency = 0.2
list.BorderSizePixel = 0
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.ScrollBarThickness = 8
list.Parent = panel

local function rewardToText(reward)
	if type(reward) ~= "table" then
		return "-"
	end
	local parts = {}
	if reward.coins then
		table.insert(parts, "+" .. tostring(reward.coins) .. " coins")
	end
	if reward.tokens then
		table.insert(parts, "+" .. tostring(reward.tokens) .. " tokens")
	end
	if reward.gems then
		table.insert(parts, "+" .. tostring(reward.gems) .. " gems")
	end
	return #parts > 0 and table.concat(parts, ", ") or "-"
end

local function clearRows()
	for _, child in ipairs(list:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
end

local function addClaimButton(parent, text, active, color, onClick)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 94, 0, 24)
	btn.BackgroundColor3 = color
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextScaled = true
	btn.Text = text
	btn.Active = active
	btn.Parent = parent
	if active then
		btn.MouseButton1Click:Connect(onClick)
	end
	return btn
end

local function refresh()
	local resp = getBattlePassState:InvokeServer()
	if not (resp and resp.success and resp.state) then
		info.Text = "Battle pass unavailable"
		return
	end
	local state = resp.state
	info.Text = string.format("Season: %s | Points: %d | Unlocked Tier: %d | Premium: %s", tostring(state.season_id), tonumber(state.points or 0), tonumber(state.unlocked_tier or 1), state.premium_unlocked and "Yes" or "No")

	clearRows()
	local y = 8
	for _, tier in ipairs(state.tiers or {}) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -10, 0, 64)
		row.Position = UDim2.new(0, 5, 0, y)
		row.BackgroundColor3 = Color3.fromRGB(31, 45, 73)
		row.BorderSizePixel = 0
		row.Parent = list

		local desc = Instance.new("TextLabel")
		desc.Size = UDim2.new(1, -210, 1, 0)
		desc.Position = UDim2.new(0, 6, 0, 0)
		desc.BackgroundTransparency = 1
		desc.TextXAlignment = Enum.TextXAlignment.Left
		desc.TextYAlignment = Enum.TextYAlignment.Top
		desc.TextColor3 = Color3.fromRGB(226, 236, 255)
		desc.TextSize = 13
		desc.Text = string.format("Tier %d (Req %d)\nFree: %s\nPremium: %s", tier.id, tier.points_required or 0, rewardToText(tier.free_reward), rewardToText(tier.premium_reward))
		desc.Parent = row

		local freeUnlocked = (state.points or 0) >= (tier.points_required or 0)
		local freeClaimable = freeUnlocked and not tier.claimed_free
		local freeBtn = addClaimButton(
			row,
			tier.claimed_free and "Free Done" or (freeClaimable and "Claim Free" or "Free Locked"),
			freeClaimable,
			freeClaimable and Color3.fromRGB(81, 147, 88) or Color3.fromRGB(95, 95, 95),
			function()
				local claimResp = claimBattlePassTier:InvokeServer({ tier_id = tier.id, track = "free" })
				info.Text = claimResp and claimResp.success and ("Claimed free tier " .. tostring(tier.id)) or ("Claim failed: " .. tostring(claimResp and claimResp.err or "unknown"))
				task.delay(0.15, refresh)
			end
		)
		freeBtn.Position = UDim2.new(1, -198, 0.5, -12)

		local premiumUnlocked = state.premium_unlocked and freeUnlocked
		local premiumClaimable = premiumUnlocked and not tier.claimed_premium
		local premiumBtn = addClaimButton(
			row,
			tier.claimed_premium and "Prem Done" or (premiumClaimable and "Claim Prem" or "Prem Locked"),
			premiumClaimable,
			premiumClaimable and Color3.fromRGB(125, 94, 168) or Color3.fromRGB(95, 95, 95),
			function()
				local claimResp = claimBattlePassTier:InvokeServer({ tier_id = tier.id, track = "premium" })
				info.Text = claimResp and claimResp.success and ("Claimed premium tier " .. tostring(tier.id)) or ("Claim failed: " .. tostring(claimResp and claimResp.err or "unknown"))
				task.delay(0.15, refresh)
			end
		)
		premiumBtn.Position = UDim2.new(1, -100, 0.5, -12)

		y = y + 70
	end
	list.CanvasSize = UDim2.new(0, 0, 0, y + 8)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.B then
		panel.Visible = not panel.Visible
		if panel.Visible then
			refresh()
		end
	end
end)
