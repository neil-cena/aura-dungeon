--[[
	InventoryPanel.client.lua
	Simple inventory + equip panel for aura/weapon ownership.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
if not player then
	return
end

local inventoryRemotes = ReplicatedStorage:WaitForChild("InventoryRemotes")
local interactionRemotes = ReplicatedStorage:WaitForChild("InteractionRemotes")
local shared = ReplicatedStorage:WaitForChild("shared")
local UITheme = require(shared.config.UITheme)
local RarityPresentation = require(shared.config.RarityPresentation)
local UIText = require(shared.config.UIText)
local AuraDisplayCatalog = require(shared.config.AuraDisplayCatalog)
local WeaponDisplayCatalog = require(shared.config.WeaponDisplayCatalog)

local getInventory = inventoryRemotes:FindFirstChild("GetInventory")
local requestEquip = inventoryRemotes:FindFirstChild("RequestEquipItem")
local inventoryUpdate = inventoryRemotes:FindFirstChild("InventoryUpdate")
local showInventoryPanel = interactionRemotes:FindFirstChild("ShowInventoryPanel")
if not getInventory or not requestEquip or not inventoryUpdate or not showInventoryPanel then
	return
end

local gui = Instance.new("ScreenGui")
gui.Name = "InventoryPanelGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "Panel"
frame.Size = UDim2.new(0.45, 0, 0.5, 0)
frame.Position = UDim2.new(0.03, 0, 0.2, 0)
UITheme.ApplyPanel(frame, false)
frame.Visible = false
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -12, 0, 26)
title.Position = UDim2.new(0, 6, 0, 6)
title.BackgroundTransparency = 1
title.Text = UIText.Inventory.Title
UITheme.ApplyText(title, true)
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 24)
closeButton.Position = UDim2.new(1, -36, 0, 8)
closeButton.BackgroundColor3 = Color3.fromRGB(62, 70, 92)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14
closeButton.Parent = frame

local equippedLabel = Instance.new("TextLabel")
equippedLabel.Size = UDim2.new(1, -12, 0, 20)
equippedLabel.Position = UDim2.new(0, 6, 0, 36)
equippedLabel.BackgroundTransparency = 1
equippedLabel.Text = "Equipped Aura: - | Weapon: -"
equippedLabel.TextColor3 = UITheme.Colors.TextSecondary
equippedLabel.TextSize = 13
equippedLabel.TextXAlignment = Enum.TextXAlignment.Left
equippedLabel.Parent = frame

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -12, 1, -66)
content.Position = UDim2.new(0, 6, 0, 60)
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.ScrollBarThickness = 8
content.BackgroundColor3 = UITheme.Colors.PanelDeep
content.BorderSizePixel = 0
content.Parent = frame

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0, 6)
uiList.Parent = content

local function clearRows()
	for _, child in ipairs(content:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
end

local function addRow(slot, itemId, isEquipped)
	local rarity = RarityPresentation.Get(itemId)
	local display = slot == "aura" and AuraDisplayCatalog.GetDisplay(itemId) or WeaponDisplayCatalog.GetDisplay(itemId)

	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -6, 0, 36)
	row.BackgroundColor3 = UITheme.Colors.PanelSoft
	row.BorderSizePixel = 0
	row.Parent = content

	local marker = Instance.new("Frame")
	marker.Size = UDim2.new(0, 6, 1, 0)
	marker.Position = UDim2.new(0, 0, 0, 0)
	marker.BackgroundColor3 = rarity.color
	marker.BorderSizePixel = 0
	marker.Parent = row

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.68, 0, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextSize = 12
	label.TextColor3 = UITheme.Colors.TextPrimary
	label.Text = string.format("%s: %s [%s]", slot, display.name, rarity.label)
	label.Parent = row

	local equipBtn = Instance.new("TextButton")
	equipBtn.Size = UDim2.new(0.27, 0, 0.72, 0)
	equipBtn.Position = UDim2.new(0.71, 0, 0.14, 0)
	equipBtn.BackgroundColor3 = isEquipped and UITheme.Colors.Success or UITheme.Colors.AccentBlue
	equipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	equipBtn.TextSize = 12
	equipBtn.Text = isEquipped and "Equipped" or "Equip"
	equipBtn.Parent = row

	equipBtn.MouseButton1Click:Connect(function()
		requestEquip:FireServer({ slot = slot, item_id = itemId })
	end)
end

local function render(inventory)
	clearRows()
	if not inventory then
		return
	end
	local equipped = inventory.equipped or {}
	equippedLabel.Text = string.format(
		"Equipped Aura: %s | Weapon: %s",
		tostring((equipped.aura and AuraDisplayCatalog.GetDisplay(equipped.aura).name) or "-"),
		tostring((equipped.weapon and WeaponDisplayCatalog.GetDisplay(equipped.weapon).name) or "-")
	)

	for _, item in ipairs(inventory.auras or {}) do
		addRow("aura", item.item_id or "unknown", equipped.aura == item.item_id)
	end
	for _, item in ipairs(inventory.weapons or {}) do
		addRow("weapon", item.item_id or "unknown", equipped.weapon == item.item_id)
	end

	local totalRows = #(inventory.auras or {}) + #(inventory.weapons or {})
	content.CanvasSize = UDim2.new(0, 0, 0, math.max(8, totalRows) * 42)
end

local function refresh()
	local response = getInventory:InvokeServer()
	if response and response.success then
		render(response.inventory)
	end
end

showInventoryPanel.OnClientEvent:Connect(function()
	frame.Visible = true
	refresh()
end)

inventoryUpdate.OnClientEvent:Connect(function(payload)
	if payload and payload.success then
		render(payload.inventory)
	end
end)

closeButton.MouseButton1Click:Connect(function()
	frame.Visible = false
end)
