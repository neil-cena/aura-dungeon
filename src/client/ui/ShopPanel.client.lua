--[[
	ShopPanel.client.lua
	Phase 4: simple server-driven shop panel.
	Toggle with O.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
if not player then
	return
end

local shopRemotes = ReplicatedStorage:WaitForChild("ShopRemotes")
local getShopState = shopRemotes:WaitForChild("GetShopState")
local purchaseShopItem = shopRemotes:WaitForChild("PurchaseShopItem")
local shared = ReplicatedStorage:WaitForChild("shared")
local UITheme = require(shared.config.UITheme)

local gui = Instance.new("ScreenGui")
gui.Name = "ShopPanelGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0.86, 0, 0.52, 0)
panel.Position = UDim2.new(0.5, 0, 0.5, 0)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
UITheme.ApplyPanel(panel, false)
panel.Visible = false
panel.Parent = gui

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(300, 240)
sizeConstraint.MaxSize = Vector2.new(620, 460)
sizeConstraint.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -12, 0, 30)
title.Position = UDim2.new(0, 6, 0, 4)
title.BackgroundTransparency = 1
title.TextColor3 = UITheme.Colors.TextPrimary
title.Font = Enum.Font.GothamBold
title.Text = "Shop"
title.Parent = panel
UITheme.ApplyResponsiveText(title, "title", true)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -12, 0, 20)
status.Position = UDim2.new(0, 6, 0, 34)
status.BackgroundTransparency = 1
status.TextColor3 = UITheme.Colors.AccentGold
status.TextXAlignment = Enum.TextXAlignment.Left
status.Text = ""
status.Parent = panel
UITheme.ApplyResponsiveText(status, "small", false)

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -12, 1, -62)
list.Position = UDim2.new(0, 6, 0, 56)
list.BackgroundColor3 = UITheme.Colors.PanelDeep
list.BackgroundTransparency = 0.2
list.BorderSizePixel = 0
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.ScrollBarThickness = 8
list.Parent = panel

local function clearList()
	for _, child in ipairs(list:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
end

local function render(state)
	clearList()
	local balances = state.balances or {}
	status.Text = string.format("Balances - Coins: %d | Tokens: %d | Gems: %d", balances.coins or 0, balances.tokens or 0, balances.gems or 0)

	local y = 8
	for _, item in ipairs(state.items or {}) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -10, 0, 52)
		row.Position = UDim2.new(0, 5, 0, y)
		row.BackgroundColor3 = UITheme.Colors.PanelSoft
		row.BorderSizePixel = 0
		row.Parent = list

		local txt = Instance.new("TextLabel")
		txt.Size = UDim2.new(0.68, 0, 1, 0)
		txt.Position = UDim2.new(0, 6, 0, 0)
		txt.BackgroundTransparency = 1
		txt.TextXAlignment = Enum.TextXAlignment.Left
		txt.TextColor3 = UITheme.Colors.TextSecondary
		txt.TextSize = UITheme.GetTextSize("small")
		txt.Text = string.format("%s  [%s %d]%s", tostring(item.display_name), tostring(item.currency), tonumber(item.price or 0), item.owned and " (owned)" or "")
		txt.Parent = row

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.28, 0, 0, 32)
		btn.Position = UDim2.new(0.71, 0, 0.5, -16)
		btn.BackgroundColor3 = item.owned and UITheme.Colors.PanelDeep or UITheme.Colors.Success
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextScaled = true
		btn.Text = item.owned and "Owned" or "Buy"
		btn.Active = not item.owned
		btn.Parent = row

		btn.MouseButton1Click:Connect(function()
			if not btn.Active then
				return
			end
			local resp = purchaseShopItem:InvokeServer({ item_id = item.id })
			if resp and resp.success then
				status.Text = "Purchase successful: " .. tostring(item.display_name)
			else
				status.Text = "Purchase failed: " .. tostring(resp and resp.err or "unknown")
			end
			task.delay(0.15, function()
				local fresh = getShopState:InvokeServer()
				if fresh and fresh.success and fresh.state then
					render(fresh.state)
				end
			end)
		end)

		y = y + 58
	end
	list.CanvasSize = UDim2.new(0, 0, 0, y + 6)
end

local function refresh()
	local resp = getShopState:InvokeServer()
	if not (resp and resp.success and resp.state) then
		status.Text = "Shop unavailable"
		return
	end
	render(resp.state)
end

local function togglePanel()
	panel.Visible = not panel.Visible
	if panel.Visible then
		refresh()
	end
end

local function applySafeArea()
	local fn = _G.AuraApplySafeArea
	if fn then
		fn(panel, { top = true, left = true, right = true, bottom = true })
	end
end

local function registerPanel()
	local register = _G.AuraRegisterPanel
	if register then
		register("shop", "Shop", togglePanel, function()
			return panel.Visible
		end)
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.O then
		togglePanel()
	end
end)

applySafeArea()
registerPanel()
