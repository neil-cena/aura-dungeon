--[[
	CombatController.client.lua
	Adds a dedicated attack button for dungeon combat.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:WaitForChild("shared")
local AssetCatalog = require(shared.config.AssetCatalog)

local player = Players.LocalPlayer
if not player then
	return
end

local combatRemotes = ReplicatedStorage:WaitForChild("CombatRemotes")

local requestAttack = combatRemotes:FindFirstChild("RequestAttack")
local combatUpdate = combatRemotes:FindFirstChild("CombatUpdate")
if not requestAttack or not combatUpdate then
	return
end

local gui = Instance.new("ScreenGui")
gui.Name = "CombatHud"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local sfx = Instance.new("Sound")
sfx.Name = "CombatButtonSfx"
sfx.Parent = gui

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

local attackButton = Instance.new("TextButton")
attackButton.Name = "AttackButton"
attackButton.Size = UDim2.new(0.16, 0, 0.11, 0)
attackButton.Position = UDim2.new(0.8, 0, 0.83, 0)
attackButton.BackgroundColor3 = Color3.fromRGB(222, 83, 83)
attackButton.TextColor3 = Color3.fromRGB(255, 255, 255)
attackButton.Text = "Attack"
attackButton.TextSize = 18
attackButton.Visible = false
attackButton.Parent = gui

local feedback = Instance.new("TextLabel")
feedback.Size = UDim2.new(0.24, 0, 0.06, 0)
feedback.Position = UDim2.new(0.74, 0, 0.76, 0)
feedback.BackgroundTransparency = 1
feedback.TextXAlignment = Enum.TextXAlignment.Right
feedback.TextColor3 = Color3.fromRGB(255, 230, 170)
feedback.Text = ""
feedback.TextSize = 14
feedback.Parent = gui

local function isCombatState()
	local state = _G.Day4DungeonState
	return state and (state.status == "wave" or state.status == "boss")
end

local function tryRefreshDungeonState()
	local actions = _G.Day4DungeonActions
	if actions and actions.refreshState then
		actions.refreshState()
	end
end

attackButton.MouseButton1Click:Connect(function()
	play((AssetCatalog.Sounds or {}).UiClick)
	local base = attackButton.BackgroundColor3
	attackButton.BackgroundColor3 = Color3.fromRGB(255, 126, 126)
	task.delay(0.08, function()
		if attackButton then
			attackButton.BackgroundColor3 = base
		end
	end)
	feedback.Text = "Swing..."
	requestAttack:FireServer()
end)

combatUpdate.OnClientEvent:Connect(function(payload)
	if not payload then
		return
	end
	if payload.success and payload.boss_telegraph then
		feedback.Text = "Boss attack incoming - dodge!"
		task.delay(1.0, function()
			if feedback then
				feedback.Text = ""
			end
		end)
		return
	end
	if payload.success and payload.boss_impact then
		feedback.Text = payload.did_hit and string.format("Boss hit you -%d", payload.damage or 0) or "Dodged boss hit!"
		task.delay(1.2, function()
			if feedback then
				feedback.Text = ""
			end
		end)
		return
	end
	if payload.success and payload.hit then
		feedback.Text = string.format("Hit -%d | Left: %d", payload.hit.damage or 0, payload.hit.remaining_count or 0)
	else
		feedback.Text = tostring(payload.err or "attack_failed")
	end
	task.delay(1.2, function()
		if feedback then
			feedback.Text = ""
		end
	end)
end)

task.spawn(function()
	local nextRefreshAt = 0
	while true do
		local now = os.clock()
		local inCombat = isCombatState()
		if now >= nextRefreshAt then
			nextRefreshAt = now + (inCombat and 2.5 or 6.0)
			tryRefreshDungeonState()
		end
		attackButton.Visible = inCombat
		task.wait(0.25)
	end
end)
