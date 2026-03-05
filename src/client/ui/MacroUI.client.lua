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
local inventoryUpdate = inventoryRemotes:WaitForChild("InventoryUpdate")
local dungeonRemotes = ReplicatedStorage:WaitForChild("DungeonRemotes")
local getDungeonState = dungeonRemotes:WaitForChild("GetDungeonState")
local dungeonUpdate = dungeonRemotes:WaitForChild("DungeonUpdate")
local onboardingRemotes = ReplicatedStorage:WaitForChild("OnboardingRemotes")
local getOnboardingState = onboardingRemotes:WaitForChild("GetOnboardingState")
local onboardingResult = onboardingRemotes:WaitForChild("OnboardingResult")
local rollRemotes = ReplicatedStorage:WaitForChild("RollRemotes")
local rollResult = rollRemotes:WaitForChild("RollResult")
local shared = ReplicatedStorage:WaitForChild("shared")
local UITheme = require(shared.config.UITheme)
local UIText = require(shared.config.UIText)
local AuraDisplayCatalog = require(shared.config.AuraDisplayCatalog)
local WeaponDisplayCatalog = require(shared.config.WeaponDisplayCatalog)

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
	return UIText.Macro.DefaultObjective
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
hud.Size = UDim2.new(0.5, 0, 0, 44)
hud.Position = UDim2.new(0.25, 0, 0.01, 0)
UITheme.ApplyPanel(hud, false)
hud.Parent = gui

local hudText = Instance.new("TextLabel")
hudText.Size = UDim2.new(1, -10, 0, 18)
hudText.Position = UDim2.new(0, 5, 0, 3)
hudText.BackgroundTransparency = 1
hudText.TextXAlignment = Enum.TextXAlignment.Left
hudText.TextYAlignment = Enum.TextYAlignment.Center
hudText.TextColor3 = UITheme.Colors.TextPrimary
hudText.TextSize = UITheme.GetTextSize("small")
hudText.Text = "C: - | T: - | Lv -"
hudText.Parent = hud

local xpLabel = Instance.new("TextLabel")
xpLabel.Size = UDim2.new(1, -10, 0, 12)
xpLabel.Position = UDim2.new(0, 5, 0, 20)
xpLabel.BackgroundTransparency = 1
xpLabel.TextXAlignment = Enum.TextXAlignment.Left
xpLabel.TextYAlignment = Enum.TextYAlignment.Center
xpLabel.TextColor3 = UITheme.Colors.TextSecondary
xpLabel.TextSize = UITheme.GetTextSize("small")
xpLabel.Text = "XP: - / -"
xpLabel.Parent = hud

local xpBarBg = Instance.new("Frame")
xpBarBg.Size = UDim2.new(1, -10, 0, 6)
xpBarBg.Position = UDim2.new(0, 5, 0, 35)
xpBarBg.BackgroundColor3 = UITheme.Colors.PanelSoft
xpBarBg.BorderSizePixel = 0
xpBarBg.Parent = hud

local xpBarFill = Instance.new("Frame")
xpBarFill.Size = UDim2.new(0, 0, 1, 0)
xpBarFill.Position = UDim2.new(0, 0, 0, 0)
xpBarFill.BackgroundColor3 = UITheme.Colors.AccentBlue
xpBarFill.BorderSizePixel = 0
xpBarFill.Parent = xpBarBg

local objective = Instance.new("TextLabel")
objective.Size = UDim2.new(0.5, 0, 0, 18)
objective.Position = UDim2.new(0.25, 0, 0.055, 0)
objective.BackgroundColor3 = UITheme.Colors.PanelSoft
objective.BackgroundTransparency = 0.2
objective.BorderSizePixel = 0
objective.TextColor3 = UITheme.Colors.AccentGold
objective.TextSize = UITheme.GetTextSize("small")
objective.TextXAlignment = Enum.TextXAlignment.Left
objective.Text = "Obj: -"
objective.Parent = gui

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0.88, 0, 0.68, 0)
panel.Position = UDim2.new(0.5, 0, 0.52, 0)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
UITheme.ApplyPanel(panel, true)
panel.Visible = false
panel.Parent = gui

local panelSizeConstraint = Instance.new("UISizeConstraint")
panelSizeConstraint.MinSize = Vector2.new(320, 280)
panelSizeConstraint.MaxSize = Vector2.new(860, 620)
panelSizeConstraint.Parent = panel

local function applySafeArea()
	local fn = _G.AuraApplySafeArea
	if fn then
		fn(hud, { top = true, left = true, right = true })
		fn(objective, { top = true, left = true, right = true })
	end
end

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -12, 0, 32)
title.Position = UDim2.new(0, 6, 0, 6)
title.BackgroundTransparency = 1
title.Text = "Macro Panel"
title.TextColor3 = UITheme.Colors.TextPrimary
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.Parent = panel
UITheme.ApplyResponsiveText(title, "title", true)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 34, 0, 28)
closeBtn.Position = UDim2.new(1, -40, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(62, 70, 92)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = UITheme.GetTextSize("body")
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
tabLoop.TextSize = UITheme.GetTextSize("body")
tabLoop.BackgroundColor3 = UITheme.Colors.AccentBlue
tabLoop.TextColor3 = Color3.fromRGB(255, 255, 255)
tabLoop.Parent = tabs

local tabProg = Instance.new("TextButton")
tabProg.Size = UDim2.new(0.32, 0, 1, 0)
tabProg.Position = UDim2.new(0.34, 0, 0, 0)
tabProg.Text = "Progression"
tabProg.TextSize = UITheme.GetTextSize("body")
tabProg.BackgroundColor3 = Color3.fromRGB(53, 70, 104)
tabProg.TextColor3 = Color3.fromRGB(255, 255, 255)
tabProg.Parent = tabs

local tabEco = Instance.new("TextButton")
tabEco.Size = UDim2.new(0.32, 0, 1, 0)
tabEco.Position = UDim2.new(0.68, 0, 0, 0)
tabEco.Text = "Economy"
tabEco.TextSize = UITheme.GetTextSize("body")
tabEco.BackgroundColor3 = Color3.fromRGB(53, 70, 104)
tabEco.TextColor3 = Color3.fromRGB(255, 255, 255)
tabEco.Parent = tabs

local content = Instance.new("TextLabel")
content.Size = UDim2.new(1, -12, 1, -88)
content.Position = UDim2.new(0, 6, 0, 82)
content.BackgroundColor3 = UITheme.Colors.PanelSoft
content.BackgroundTransparency = 0.25
content.BorderSizePixel = 0
content.TextWrapped = true
content.TextYAlignment = Enum.TextYAlignment.Top
content.TextXAlignment = Enum.TextXAlignment.Left
content.TextScaled = false
content.TextSize = UITheme.GetTextSize("body")
content.TextColor3 = UITheme.Colors.TextSecondary
content.Text = ""
content.Parent = panel

local activeTab = "loop"
local lastSnapshot = nil
local refreshRequested = true

local function renderLoop(snapshot)
	local eq = snapshot.equipped or {}
	local auraName = eq.aura and AuraDisplayCatalog.GetDisplay(eq.aura).name or UIText.Common.NoneEquipped
	local weaponName = eq.weapon and WeaponDisplayCatalog.GetDisplay(eq.weapon).name or UIText.Common.NoneEquipped
	return string.format(
		"Main Loop\n\n1) Roll at station\n2) Equip in loadout\n3) Enter rift\n4) Complete run and repeat\n\nCurrent Objective:\n%s\n\nEquipped\nAura: %s\nWeapon: %s",
		tostring(snapshot.objective or "-"),
		tostring(auraName),
		tostring(weaponName)
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
	hudText.Text = string.format(
		"C:%d | T:%d | Lv:%d",
		tonumber(curr.coins or 0),
		tonumber(curr.tokens or 0),
		tonumber(prog.level or 1)
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
		objective.Text = "Obj: " .. tostring(lastSnapshot.objective or "-")
	end

	if activeTab == "loop" then
		content.Text = renderLoop(lastSnapshot)
	elseif activeTab == "progression" then
		content.Text = renderProgression(lastSnapshot)
	else
		content.Text = renderEconomy(lastSnapshot)
	end
end

local function requestRefresh()
	refreshRequested = true
end

local function setTab(tabId)
	activeTab = tabId
	tabLoop.BackgroundColor3 = tabId == "loop" and UITheme.Colors.AccentBlue or UITheme.Colors.PanelSoft
	tabProg.BackgroundColor3 = tabId == "progression" and UITheme.Colors.AccentBlue or UITheme.Colors.PanelSoft
	tabEco.BackgroundColor3 = tabId == "economy" and UITheme.Colors.AccentBlue or UITheme.Colors.PanelSoft
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

local function togglePanel()
	panel.Visible = not panel.Visible
	render()
end

local function registerPanel()
	local register = _G.AuraRegisterPanel
	if register then
		register("macro", "Macro", togglePanel, function()
			return panel.Visible
		end)
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.Tab then
		togglePanel()
	end
end)

task.spawn(function()
	while true do
		if refreshRequested then
			lastSnapshot = readState()
			render()
			refreshRequested = false
		end
		task.wait(0.25)
	end
end)

-- Event-driven updates with throttled polling fallback.
inventoryUpdate.OnClientEvent:Connect(requestRefresh)
dungeonUpdate.OnClientEvent:Connect(requestRefresh)
onboardingResult.OnClientEvent:Connect(requestRefresh)
rollResult.OnClientEvent:Connect(requestRefresh)

task.spawn(function()
	while true do
		requestRefresh()
		task.wait(3.0)
	end
end)

setTab("loop")
applySafeArea()
registerPanel()
