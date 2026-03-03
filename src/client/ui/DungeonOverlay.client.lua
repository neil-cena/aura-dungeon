--[[
	DungeonOverlay.client.lua
	Day 5 polish UI: thumb-first layout, mute-readable cues, quality-aware rendering.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
if not player then
	return
end

local DungeonConfig = require(ReplicatedStorage.shared.config.DungeonConfig)
local PolishConfig = require(ReplicatedStorage.shared.config.PolishConfig)
local PolishTypes = require(ReplicatedStorage.shared.types.PolishTypes)

local gui = Instance.new("ScreenGui")
gui.Name = "DungeonOverlay"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.AnchorPoint = PolishConfig.ThumbLayout.ActionPanel.AnchorPoint
frame.Size = UDim2.new(PolishConfig.ThumbLayout.ActionPanel.SizeScale.X, 0, PolishConfig.ThumbLayout.ActionPanel.SizeScale.Y, 0)
frame.Position = UDim2.new(PolishConfig.ThumbLayout.ActionPanel.PositionScale.X, 0, PolishConfig.ThumbLayout.ActionPanel.PositionScale.Y, 0)
frame.BackgroundColor3 = Color3.fromRGB(22, 30, 40)
frame.BackgroundTransparency = 0.18
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -12, 0, 22)
title.Position = UDim2.new(0, 6, 0, 3)
title.BackgroundTransparency = 1
title.Text = "Dungeon Run"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local muteButton = Instance.new("TextButton")
muteButton.Size = UDim2.new(0.42, 0, 0.10, 0)
muteButton.Position = UDim2.new(0.56, 0, 0.02, 0)
muteButton.BackgroundColor3 = Color3.fromRGB(95, 75, 45)
muteButton.TextColor3 = Color3.new(1, 1, 1)
muteButton.TextSize = 11
muteButton.Text = "Mute cues: off"
muteButton.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -12, 0, 18)
statusLabel.Position = UDim2.new(0, 6, 0, 24)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: idle"
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, -12, 0, 18)
timerLabel.Position = UDim2.new(0, 6, 0, 42)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "Runtime: 0.0s"
timerLabel.TextColor3 = Color3.new(0.9, 0.95, 1)
timerLabel.TextSize = 12
timerLabel.TextXAlignment = Enum.TextXAlignment.Left
timerLabel.Parent = frame

local telegraphLabel = Instance.new("TextLabel")
telegraphLabel.Size = UDim2.new(1, -12, 0, 38)
telegraphLabel.Position = UDim2.new(0, 6, 0, 60)
telegraphLabel.BackgroundTransparency = 1
telegraphLabel.Text = "Cue: Ready."
telegraphLabel.TextWrapped = true
telegraphLabel.TextColor3 = PolishConfig.Readability.HighContrastCueTextColor
telegraphLabel.TextStrokeColor3 = PolishConfig.Readability.HighContrastCueStrokeColor
telegraphLabel.TextStrokeTransparency = 0.2
telegraphLabel.TextSize = 13
telegraphLabel.TextXAlignment = Enum.TextXAlignment.Left
telegraphLabel.Parent = frame

local resultLabel = Instance.new("TextLabel")
resultLabel.Size = UDim2.new(1, -12, 0, 22)
resultLabel.Position = UDim2.new(0, 6, 0, 102)
resultLabel.BackgroundTransparency = 1
resultLabel.Text = ""
resultLabel.TextWrapped = false
resultLabel.TextColor3 = Color3.fromRGB(220, 235, 255)
resultLabel.TextSize = 11
resultLabel.TextXAlignment = Enum.TextXAlignment.Left
resultLabel.Parent = frame

local qualityLabel = Instance.new("TextLabel")
qualityLabel.Size = UDim2.new(1, -12, 0, 16)
qualityLabel.Position = UDim2.new(0, 6, 0, 120)
qualityLabel.BackgroundTransparency = 1
qualityLabel.Text = "Quality: mid | Audio: on"
qualityLabel.TextColor3 = Color3.fromRGB(200, 215, 245)
qualityLabel.TextSize = 11
qualityLabel.TextXAlignment = Enum.TextXAlignment.Left
qualityLabel.Parent = frame

local mainButton = Instance.new("TextButton")
mainButton.Size = UDim2.new(
	PolishConfig.ThumbLayout.CoreButtons.Main.SizeScale.X,
	0,
	PolishConfig.ThumbLayout.CoreButtons.Main.SizeScale.Y,
	0
)
mainButton.Position = UDim2.new(
	PolishConfig.ThumbLayout.CoreButtons.Main.PositionScale.X,
	0,
	PolishConfig.ThumbLayout.CoreButtons.Main.PositionScale.Y,
	0
)
mainButton.BackgroundColor3 = Color3.fromRGB(60, 120, 190)
mainButton.Text = "Start Run"
mainButton.TextColor3 = Color3.new(1, 1, 1)
mainButton.TextSize = 14
mainButton.Parent = frame

local winButton = Instance.new("TextButton")
winButton.Size = UDim2.new(
	PolishConfig.ThumbLayout.CoreButtons.Win.SizeScale.X,
	0,
	PolishConfig.ThumbLayout.CoreButtons.Win.SizeScale.Y,
	0
)
winButton.Position = UDim2.new(
	PolishConfig.ThumbLayout.CoreButtons.Win.PositionScale.X,
	0,
	PolishConfig.ThumbLayout.CoreButtons.Win.PositionScale.Y,
	0
)
winButton.BackgroundColor3 = Color3.fromRGB(52, 140, 84)
winButton.Text = "Resolve Win"
winButton.TextColor3 = Color3.new(1, 1, 1)
winButton.TextSize = 13
winButton.Visible = false
winButton.Parent = frame

local lossButton = Instance.new("TextButton")
lossButton.Size = UDim2.new(
	PolishConfig.ThumbLayout.CoreButtons.Loss.SizeScale.X,
	0,
	PolishConfig.ThumbLayout.CoreButtons.Loss.SizeScale.Y,
	0
)
lossButton.Position = UDim2.new(
	PolishConfig.ThumbLayout.CoreButtons.Loss.PositionScale.X,
	0,
	PolishConfig.ThumbLayout.CoreButtons.Loss.PositionScale.Y,
	0
)
lossButton.BackgroundColor3 = Color3.fromRGB(154, 80, 62)
lossButton.Text = "Resolve Loss"
lossButton.TextColor3 = Color3.new(1, 1, 1)
lossButton.TextSize = 13
lossButton.Visible = false
lossButton.Parent = frame

local function getActions()
	return _G.Day4DungeonActions
end

local function getState()
	return _G.Day4DungeonState or {
		status = "idle",
		wave_index = 0,
		runtime_seconds = 0,
		boss_spawned = false,
		quality_tier = PolishConfig.QualityTier.Mid,
		mute_mode = false,
	}
end

local function applyTierVisuals(state)
	local visual = PolishTypes.GetVisualTierSettings(state.quality_tier or PolishConfig.QualityTier.Mid)
	frame.BackgroundTransparency = visual.panelOpacity
	telegraphLabel.TextSize = visual.telegraphTextSize
	qualityLabel.Text = string.format(
		"Quality: %s | Audio: %s | p95: %sms",
		tostring(state.quality_tier or PolishConfig.QualityTier.Mid),
		(state.mute_mode and "muted" or "on"),
		tostring(state.input_latency_p95_ms or "-")
	)
end

local function refresh()
	local actions = getActions()
	if actions and actions.refreshState then
		actions.refreshState()
	end
	local state = getState()
	applyTierVisuals(state)

	statusLabel.Text = string.format("Status: %s | Wave: %d", tostring(state.status or "idle"), tonumber(state.wave_index or 0))
	timerLabel.Text = string.format("Runtime: %.1fs (target %ds-%ds)", tonumber(state.runtime_seconds or 0), DungeonConfig.Run.TargetMinSeconds, DungeonConfig.Run.TargetMaxSeconds)
	muteButton.Text = (state.mute_mode and "Mute cues: on" or "Mute cues: off")

	if state.status == DungeonConfig.Status.Boss then
		telegraphLabel.Text = "Cue: " .. DungeonConfig.Telegraph.BossSpawnText .. " " .. DungeonConfig.Telegraph.PromptText
		mainButton.Text = "Next: Boss Resolve"
		winButton.Visible = true
		lossButton.Visible = true
	elseif state.status == DungeonConfig.Status.Wave then
		telegraphLabel.Text = "Cue: Wave active. Advance when combat is stable."
		mainButton.Text = "Advance Phase"
		winButton.Visible = false
		lossButton.Visible = false
	elseif state.status == DungeonConfig.Status.Won or state.status == DungeonConfig.Status.Lost then
		telegraphLabel.Text = "Cue: Run ended. Start another run."
		mainButton.Text = "Start Run"
		winButton.Visible = false
		lossButton.Visible = false
		if state.last_result and state.last_result.reward then
			resultLabel.Text = string.format(
				"Outcome: %s | Reward: +%d Coins, +%d Tokens",
				tostring(state.last_result.outcome),
				state.last_result.reward.coins or 0,
				state.last_result.reward.tokens or 0
			)
		end
	else
		telegraphLabel.Text = "Cue: Ready for dungeon run."
		mainButton.Text = "Start Run"
		winButton.Visible = false
		lossButton.Visible = false
	end

	if state.last_error then
		resultLabel.Text = "Error: " .. tostring(state.last_error)
	end
end

muteButton.MouseButton1Click:Connect(function()
	local actions = getActions()
	local state = getState()
	if actions and actions.setMuteMode then
		actions.setMuteMode(not (state.mute_mode == true))
	end
	task.delay(0.05, refresh)
end)

mainButton.MouseButton1Click:Connect(function()
	local actions = getActions()
	if not actions then
		return
	end
	local state = getState()
	if state.status == DungeonConfig.Status.Wave or state.status == DungeonConfig.Status.Boss then
		actions.advancePhase()
	else
		actions.startRun()
	end
	task.delay(0.2, refresh)
end)

winButton.MouseButton1Click:Connect(function()
	local actions = getActions()
	if actions then
		actions.completeRun(true)
		task.delay(0.2, refresh)
	end
end)

lossButton.MouseButton1Click:Connect(function()
	local actions = getActions()
	if actions then
		actions.completeRun(false)
		task.delay(0.2, refresh)
	end
end)

RunService.Heartbeat:Connect(function()
	local state = getState()
	if state.status == DungeonConfig.Status.Wave or state.status == DungeonConfig.Status.Boss then
		local runtime = tonumber(state.runtime_seconds or 0)
		timerLabel.Text = string.format("Runtime: %.1fs (target %ds-%ds)", runtime, DungeonConfig.Run.TargetMinSeconds, DungeonConfig.Run.TargetMaxSeconds)
	end
end)

task.defer(function()
	task.wait(0.3)
	refresh()
end)
