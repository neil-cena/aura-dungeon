--[[
	MacroUI.client.lua
	Macro layer UI: persistent HUD + macro panel with loop/progression/economy tabs.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
if not player then
	return
end

local macroRemotes = ReplicatedStorage:FindFirstChild("MacroRemotes")
local getMacroSnapshot = macroRemotes and macroRemotes:FindFirstChild("GetMacroSnapshot")

local inventoryRemotes = ReplicatedStorage:WaitForChild("InventoryRemotes")
local getInventory = inventoryRemotes:WaitForChild("GetInventory")
local dungeonRemotes = ReplicatedStorage:WaitForChild("DungeonRemotes")
local getDungeonState = dungeonRemotes:WaitForChild("GetDungeonState")
local onboardingRemotes = ReplicatedStorage:WaitForChild("OnboardingRemotes")
local getOnboardingState = onboardingRemotes:WaitForChild("GetOnboardingState")

local function computeFallbackProgression(inv)
	local prog = inv.progression or {}
	local dungeonsCompleted = tonumber(prog.dungeons_completed or 0)
	local bossKills = tonumber(prog.boss_kills or 0)
	local xp = (dungeonsCompleted * 100) + (bossKills * 60)
	local level = math.max(1, math.floor(xp / 250) + 1)
	local inLevelBase = (level - 1) * 250
	return {
		level = level,
		xp_total = xp,
		xp_in_level = xp - inLevelBase,
		xp_in_level_cap = 250,
		dungeons_completed = dungeonsCompleted,
		boss_kills = bossKills,
	}
end

local function fallbackObjective(onboardingState, dungeonState)
	local step = onboardingState and onboardingState.current_step
	if step and step ~= "rewarded" and step ~= "returnedHub" then
		return string.format("Finish onboarding (%s)", tostring(step))
	end
	local dStatus = dungeonState and dungeonState.status
	if dStatus == "wave" or dStatus == "boss" then
		return string.format("Complete dungeon run (%s)", tostring(dStatus))
	end
	return "Roll -> Equip -> Enter Rift"
end

local function readState()
	if getMacroSnapshot then
		local response = getMacroSnapshot:InvokeServer()
		if response and response.success and response.snapshot then
			return response.snapshot
		end
	end

	local invResp = getInventory:InvokeServer()
	local inv = invResp and invResp.success and invResp.inventory or nil
	if not inv then
		return nil
	end
	local dResp = getDungeonState:InvokeServer()
	local oResp = getOnboardingState:InvokeServer()
	local dState = dResp and dResp.success and dResp.state or nil
	local oState = oResp and oResp.success and oResp.state or nil
	local rollState = inv.roll_state or {}

	return {
		currencies = inv.currencies or {},
		equipped = inv.equipped or {},
		progression = computeFallbackProgression(inv),
		pity = {
			aura_lane = rollState.aura_lane or {},
			weapon_lane = rollState.weapon_lane or {},
		},
		objective = fallbackObjective(oState, dState),
		run_status = dState and dState.status or "idle",
		economy_recent = {},
	}
end

local gui = Instance.new("ScreenGui")
gui.Name = "MacroUIGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local hud = Instance.new("Frame")
hud.Size = UDim2.new(0.64, 0, 0, 64)
hud.Position = UDim2.new(0.18, 0, 0.01, 0)
hud.BackgroundColor3 = Color3.fromRGB(20, 28, 40)
hud.BackgroundTransparency = 0.1
hud.BorderSizePixel = 0
hud.Parent = gui

local hudText = Instance.new("TextLabel")
hudText.Size = UDim2.new(1, -12, 0, 30)
hudText.Position = UDim2.new(0, 6, 0, 2)
hudText.BackgroundTransparency = 1
hudText.TextXAlignment = Enum.TextXAlignment.Left
hudText.TextYAlignment = Enum.TextYAlignment.Center
hudText.TextColor3 = Color3.fromRGB(236, 242, 255)
hudText.TextScaled = true
hudText.Text = "Coins: - | Tokens: - | Lv -"
hudText.Parent = hud

local xpLabel = Instance.new("TextLabel")
xpLabel.Size = UDim2.new(1, -12, 0, 14)
xpLabel.Position = UDim2.new(0, 6, 0, 32)
xpLabel.BackgroundTransparency = 1
xpLabel.TextXAlignment = Enum.TextXAlignment.Left
xpLabel.TextYAlignment = Enum.TextYAlignment.Center
xpLabel.TextColor3 = Color3.fromRGB(208, 220, 255)
xpLabel.TextSize = 12
xpLabel.Text = "XP: - / -"
xpLabel.Parent = hud

local xpBarBg = Instance.new("Frame")
xpBarBg.Size = UDim2.new(1, -12, 0, 10)
xpBarBg.Position = UDim2.new(0, 6, 0, 50)
xpBarBg.BackgroundColor3 = Color3.fromRGB(50, 58, 78)
xpBarBg.BorderSizePixel = 0
xpBarBg.Parent = hud

local xpBarFill = Instance.new("Frame")
xpBarFill.Size = UDim2.new(0, 0, 1, 0)
xpBarFill.Position = UDim2.new(0, 0, 0, 0)
xpBarFill.BackgroundColor3 = Color3.fromRGB(110, 174, 255)
xpBarFill.BorderSizePixel = 0
xpBarFill.Parent = xpBarBg

local objective = Instance.new("TextLabel")
objective.Size = UDim2.new(0.64, 0, 0, 30)
objective.Position = UDim2.new(0.18, 0, 0.065, 0)
objective.BackgroundColor3 = Color3.fromRGB(39, 54, 82)
objective.BackgroundTransparency = 0.2
objective.BorderSizePixel = 0
objective.TextColor3 = Color3.fromRGB(255, 240, 196)
objective.TextScaled = true
objective.Text = "Objective: -"
objective.Parent = gui

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0.46, 0, 0.5, 0)
panel.Position = UDim2.new(0.27, 0, 0.15, 0)
panel.BackgroundColor3 = Color3.fromRGB(16, 21, 33)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -12, 0, 32)
title.Position = UDim2.new(0, 6, 0, 6)
title.BackgroundTransparency = 1
title.Text = "Macro Panel"
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.Parent = panel

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 34, 0, 28)
closeBtn.Position = UDim2.new(1, -40, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(62, 70, 92)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Text = "X"
closeBtn.Parent = panel

local tabs = Instance.new("Frame")
tabs.Size = UDim2.new(1, -12, 0, 36)
tabs.Position = UDim2.new(0, 6, 0, 42)
tabs.BackgroundTransparency = 1
tabs.Parent = panel

local tabLoop = Instance.new("TextButton")
tabLoop.Size = UDim2.new(0.32, 0, 1, 0)
tabLoop.Position = UDim2.new(0, 0, 0, 0)
tabLoop.Text = "Loop"
tabLoop.TextScaled = true
tabLoop.BackgroundColor3 = Color3.fromRGB(72, 121, 214)
tabLoop.TextColor3 = Color3.fromRGB(255, 255, 255)
tabLoop.Parent = tabs

local tabProg = Instance.new("TextButton")
tabProg.Size = UDim2.new(0.32, 0, 1, 0)
tabProg.Position = UDim2.new(0.34, 0, 0, 0)
tabProg.Text = "Progression"
tabProg.TextScaled = true
tabProg.BackgroundColor3 = Color3.fromRGB(53, 70, 104)
tabProg.TextColor3 = Color3.fromRGB(255, 255, 255)
tabProg.Parent = tabs

local tabEco = Instance.new("TextButton")
tabEco.Size = UDim2.new(0.32, 0, 1, 0)
tabEco.Position = UDim2.new(0.68, 0, 0, 0)
tabEco.Text = "Economy"
tabEco.TextScaled = true
tabEco.BackgroundColor3 = Color3.fromRGB(53, 70, 104)
tabEco.TextColor3 = Color3.fromRGB(255, 255, 255)
tabEco.Parent = tabs

local content = Instance.new("TextLabel")
content.Size = UDim2.new(1, -12, 1, -88)
content.Position = UDim2.new(0, 6, 0, 82)
content.BackgroundColor3 = Color3.fromRGB(24, 31, 48)
content.BackgroundTransparency = 0.25
content.BorderSizePixel = 0
content.TextWrapped = true
content.TextYAlignment = Enum.TextYAlignment.Top
content.TextXAlignment = Enum.TextXAlignment.Left
content.TextScaled = false
content.TextSize = 16
content.TextColor3 = Color3.fromRGB(225, 234, 255)
content.Text = ""
content.Parent = panel

local activeTab = "loop"
local lastSnapshot = nil

local function renderLoop(snapshot)
	local eq = snapshot.equipped or {}
	return string.format(
		"Main Loop\n\n1) Roll at station\n2) Equip in loadout\n3) Enter rift\n4) Complete run and repeat\n\nCurrent Objective:\n%s\n\nEquipped\nAura: %s\nWeapon: %s",
		tostring(snapshot.objective or "-"),
		tostring(eq.aura or "none"),
		tostring(eq.weapon or "none")
	)
end

local function renderProgression(snapshot)
	local prog = snapshot.progression or {}
	local pity = snapshot.pity or {}
	local aura = pity.aura_lane or {}
	local weap = pity.weapon_lane or {}
	return string.format(
		"Progression\n\nLevel: %d\nXP: %d / %d\nDungeons Completed: %d\nBoss Kills: %d\nBattle Pass Points: %d\nPremium Pass: %s\n\nPity Counters\nAura total rolls: %d\nWeapon total rolls: %d\nAura since Legendary: %d\nWeapon since Legendary: %d",
		tonumber(prog.level or 1),
		tonumber(prog.xp_in_level or 0),
		tonumber(prog.xp_in_level_cap or 250),
		tonumber(prog.dungeons_completed or 0),
		tonumber(prog.boss_kills or 0),
		tonumber(prog.battle_pass_points or 0),
		(prog.battle_pass_premium_unlocked and "Yes" or "No"),
		tonumber(aura.roll_count_total or 0),
		tonumber(weap.roll_count_total or 0),
		tonumber(aura.since_legendary or 0),
		tonumber(weap.since_legendary or 0)
	)
end

local function renderEconomy(snapshot)
	local lines = {
		"Recent Economy Events",
		"",
	}
	local txs = snapshot.economy_recent or {}
	if #txs == 0 then
		table.insert(lines, "No ledger entries yet (macro snapshot fallback mode).")
	else
		for _, tx in ipairs(txs) do
			local sign = (tx.delta or 0) >= 0 and "+" or ""
			table.insert(lines, string.format("%s %s%d (%s)", tostring(tx.currency or "?"), sign, tonumber(tx.delta or 0), tostring(tx.reason_code or "unknown")))
		end
	end
	return table.concat(lines, "\n")
end

local function render()
	if not lastSnapshot then
		return
	end
	local curr = lastSnapshot.currencies or {}
	local prog = lastSnapshot.progression or {}
	local eq = lastSnapshot.equipped or {}
	hudText.Text = string.format(
		"Coins: %d | Tokens: %d | Level: %d | Aura: %s | Weapon: %s",
		tonumber(curr.coins or 0),
		tonumber(curr.tokens or 0),
		tonumber(prog.level or 1),
		tostring(eq.aura or "none"),
		tostring(eq.weapon or "none")
	)
	local xpNow = tonumber(prog.xp_in_level or 0)
	local xpCap = math.max(1, tonumber(prog.xp_in_level_cap or 250))
	local xpRatio = math.clamp(xpNow / xpCap, 0, 1)
	xpLabel.Text = string.format("XP: %d / %d", xpNow, xpCap)
	xpBarFill.Size = UDim2.new(xpRatio, 0, 1, 0)
	local runStatus = tostring(lastSnapshot.run_status or "idle")
	if runStatus == "wave" or runStatus == "boss" then
		objective.Visible = false
	else
		objective.Visible = true
		objective.Text = "Objective: " .. tostring(lastSnapshot.objective or "-")
	end

	if activeTab == "loop" then
		content.Text = renderLoop(lastSnapshot)
	elseif activeTab == "progression" then
		content.Text = renderProgression(lastSnapshot)
	else
		content.Text = renderEconomy(lastSnapshot)
	end
end

local function setTab(tabId)
	activeTab = tabId
	tabLoop.BackgroundColor3 = tabId == "loop" and Color3.fromRGB(72, 121, 214) or Color3.fromRGB(53, 70, 104)
	tabProg.BackgroundColor3 = tabId == "progression" and Color3.fromRGB(72, 121, 214) or Color3.fromRGB(53, 70, 104)
	tabEco.BackgroundColor3 = tabId == "economy" and Color3.fromRGB(72, 121, 214) or Color3.fromRGB(53, 70, 104)
	render()
end

tabLoop.MouseButton1Click:Connect(function()
	setTab("loop")
end)
tabProg.MouseButton1Click:Connect(function()
	setTab("progression")
end)
tabEco.MouseButton1Click:Connect(function()
	setTab("economy")
end)
closeBtn.MouseButton1Click:Connect(function()
	panel.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.Tab then
		panel.Visible = not panel.Visible
		render()
	end
end)

task.spawn(function()
	while true do
		lastSnapshot = readState()
		render()
		task.wait(0.9)
	end
end)

setTab("loop")
