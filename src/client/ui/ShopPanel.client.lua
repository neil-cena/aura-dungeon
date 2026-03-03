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

local gui = Instance.new("ScreenGui")
gui.Name = "ShopPanelGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 420, 0, 320)
panel.Position = UDim2.new(0.5, -210, 0.2, 0)
panel.BackgroundColor3 = Color3.fromRGB(21, 31, 48)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -12, 0, 30)
title.Position = UDim2.new(0, 6, 0, 4)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(244, 248, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Text = "Shop (Press O)"
title.Parent = panel

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -12, 0, 20)
status.Position = UDim2.new(0, 6, 0, 34)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(255, 229, 168)
status.TextXAlignment = Enum.TextXAlignment.Left
status.Text = ""
status.Parent = panel

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -12, 1, -62)
list.Position = UDim2.new(0, 6, 0, 56)
list.BackgroundColor3 = Color3.fromRGB(13, 19, 30)
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
		row.BackgroundColor3 = Color3.fromRGB(31, 44, 69)
		row.BorderSizePixel = 0
		row.Parent = list

		local txt = Instance.new("TextLabel")
		txt.Size = UDim2.new(0.68, 0, 1, 0)
		txt.Position = UDim2.new(0, 6, 0, 0)
		txt.BackgroundTransparency = 1
		txt.TextXAlignment = Enum.TextXAlignment.Left
		txt.TextColor3 = Color3.fromRGB(226, 236, 255)
		txt.TextSize = 14
		txt.Text = string.format("%s  [%s %d]%s", tostring(item.display_name), tostring(item.currency), tonumber(item.price or 0), item.owned and " (owned)" or "")
		txt.Parent = row

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.28, 0, 0, 32)
		btn.Position = UDim2.new(0.71, 0, 0.5, -16)
		btn.BackgroundColor3 = item.owned and Color3.fromRGB(92, 92, 92) or Color3.fromRGB(86, 151, 92)
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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.O then
		panel.Visible = not panel.Visible
		if panel.Visible then
			refresh()
		end
	end
end)
