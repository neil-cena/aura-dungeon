--[[
	RollPanel.client.lua
	Hub roll station UI with disclosure, currency readout, and animated result text.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
if not player then
	return
end

local shared = ReplicatedStorage:WaitForChild("shared")
local RollConfig = require(shared.config.RollConfig)
local AssetCatalog = require(shared.config.AssetCatalog)

local rollRemotes = ReplicatedStorage:WaitForChild("RollRemotes")
local inventoryRemotes = ReplicatedStorage:WaitForChild("InventoryRemotes")
local interactionRemotes = ReplicatedStorage:WaitForChild("InteractionRemotes")

local requestRoll = rollRemotes:FindFirstChild("RequestRoll")
local rollResult = rollRemotes:FindFirstChild("RollResult")
local getInventory = inventoryRemotes:FindFirstChild("GetInventory")
local showRollPanel = interactionRemotes:FindFirstChild("ShowRollPanel")
if not requestRoll or not rollResult or not getInventory or not showRollPanel then
	return
end

local gui = Instance.new("ScreenGui")
gui.Name = "RollPanelGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "Panel"
frame.Size = UDim2.new(0.42, 0, 0.48, 0)
frame.Position = UDim2.new(0.29, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(23, 30, 46)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = gui

local sfx = Instance.new("Sound")
sfx.Name = "RollPanelSfx"
sfx.Parent = frame

local function play(soundId)
	if type(soundId) ~= "string" or soundId == "" then
		return
	end
	local state = _G.Day4DungeonState
	if state and state.mute_mode == true then
		return
	end
	sfx.SoundId = soundId
	sfx.TimePosition = 0
	sfx:Play()
end

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -12, 0, 28)
title.Position = UDim2.new(0, 6, 0, 6)
title.BackgroundTransparency = 1
title.Text = "Aura Rolls"
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 28)
closeButton.Position = UDim2.new(1, -36, 0, 6)
closeButton.BackgroundColor3 = Color3.fromRGB(62, 70, 92)
closeButton.Text = "X"
closeButton.TextSize = 16
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Parent = frame

local currencyLabel = Instance.new("TextLabel")
currencyLabel.Size = UDim2.new(1, -12, 0, 24)
currencyLabel.Position = UDim2.new(0, 6, 0, 40)
currencyLabel.BackgroundTransparency = 1
currencyLabel.Text = "Coins: - | Tokens: -"
currencyLabel.TextSize = 14
currencyLabel.TextColor3 = Color3.fromRGB(210, 222, 255)
currencyLabel.TextXAlignment = Enum.TextXAlignment.Left
currencyLabel.Parent = frame

local laneAuraBtn = Instance.new("TextButton")
laneAuraBtn.Size = UDim2.new(0.46, 0, 0, 32)
laneAuraBtn.Position = UDim2.new(0.04, 0, 0, 74)
laneAuraBtn.BackgroundColor3 = Color3.fromRGB(79, 133, 255)
laneAuraBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
laneAuraBtn.Text = "Roll Aura (100 Coins)"
laneAuraBtn.TextSize = 13
laneAuraBtn.Parent = frame

local laneWeaponBtn = Instance.new("TextButton")
laneWeaponBtn.Size = UDim2.new(0.46, 0, 0, 32)
laneWeaponBtn.Position = UDim2.new(0.5, 0, 0, 74)
laneWeaponBtn.BackgroundColor3 = Color3.fromRGB(113, 92, 255)
laneWeaponBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
laneWeaponBtn.Text = "Roll Weapon (50 Tokens)"
laneWeaponBtn.TextSize = 13
laneWeaponBtn.Parent = frame

local resultLabel = Instance.new("TextLabel")
resultLabel.Size = UDim2.new(1, -12, 0, 46)
resultLabel.Position = UDim2.new(0, 6, 0, 114)
resultLabel.BackgroundTransparency = 1
resultLabel.TextWrapped = true
resultLabel.Text = "Roll at the station to receive an item."
resultLabel.TextSize = 14
resultLabel.TextColor3 = Color3.fromRGB(255, 240, 170)
resultLabel.TextXAlignment = Enum.TextXAlignment.Left
resultLabel.Parent = frame

local disclosure = Instance.new("TextLabel")
disclosure.Size = UDim2.new(1, -12, 1, -172)
disclosure.Position = UDim2.new(0, 6, 0, 164)
disclosure.BackgroundTransparency = 1
disclosure.TextWrapped = true
disclosure.TextYAlignment = Enum.TextYAlignment.Top
disclosure.TextXAlignment = Enum.TextXAlignment.Left
disclosure.TextSize = 12
disclosure.TextColor3 = Color3.fromRGB(206, 215, 240)
disclosure.Text = RollConfig.GetDisclosureText()
disclosure.Parent = frame

local function refreshCurrency()
	local response = getInventory:InvokeServer()
	if not response or not response.success then
		return
	end
	local stats = response.inventory or {}
	local currencies = stats.currencies
	if not currencies then
		local profileResponse = response.profile
		currencies = profileResponse and profileResponse.currencies
	end
	if not currencies then
		currencyLabel.Text = "Coins: ? | Tokens: ?"
		return
	end
	currencyLabel.Text = string.format("Coins: %d | Tokens: %d", currencies.coins or 0, currencies.tokens or 0)
end

local function openPanel()
	frame.Visible = true
	refreshCurrency()
end

showRollPanel.OnClientEvent:Connect(function()
	openPanel()
end)

closeButton.MouseButton1Click:Connect(function()
	play((AssetCatalog.Sounds or {}).UiClick)
	frame.Visible = false
end)

laneAuraBtn.MouseButton1Click:Connect(function()
	play((AssetCatalog.Sounds or {}).RollAnticipation)
	requestRoll:FireServer({ lane = "Aura" })
end)

laneWeaponBtn.MouseButton1Click:Connect(function()
	play((AssetCatalog.Sounds or {}).RollAnticipation)
	requestRoll:FireServer({ lane = "Weapon" })
end)

rollResult.OnClientEvent:Connect(function(payload)
	if not payload then
		return
	end
	if not payload.success then
		resultLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
		resultLabel.Text = string.format("Roll failed: %s", tostring(payload.err or "unknown_error"))
		return
	end

	local result = payload.result or {}
	local rarity = tostring(result.rarity or "Unknown")
	local itemId = tostring(result.item_id or "unknown_item")
	local lane = tostring(result.lane or "Unknown")

	resultLabel.TextColor3 = Color3.fromRGB(255, 240, 170)
	resultLabel.Text = string.format("You rolled %s (%s)\n%s", rarity, lane, itemId)
	local baseSize = resultLabel.TextSize
	resultLabel.TextSize = baseSize + 2
	TweenService:Create(resultLabel, TweenInfo.new(0.2), { TextSize = baseSize }):Play()
	refreshCurrency()
end)
