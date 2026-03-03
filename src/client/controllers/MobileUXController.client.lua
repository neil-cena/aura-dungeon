--[[
	MobileUXController.client.lua
	Phase 4 polish: applies quality-tier visual downgrade and mobile-friendly UI scaling.
]]

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
if not player then
	return
end

local PolishConfig = require(ReplicatedStorage.shared.config.PolishConfig)
local PolishTypes = require(ReplicatedStorage.shared.types.PolishTypes)

local playerGui = player:WaitForChild("PlayerGui")
local uiScaleByGui = {}
local lastAppliedTier = nil

local function getTier()
	local state = _G.Day4DungeonState
	if state and PolishTypes.IsValidQualityTier(state.quality_tier) then
		return state.quality_tier
	end
	return PolishConfig.QualityTier.Mid
end

local function ensureScale(gui)
	if uiScaleByGui[gui] and uiScaleByGui[gui].Parent then
		return uiScaleByGui[gui]
	end
	local scale = gui:FindFirstChild("AuraAutoScale")
	if not (scale and scale:IsA("UIScale")) then
		scale = Instance.new("UIScale")
		scale.Name = "AuraAutoScale"
		scale.Parent = gui
	end
	uiScaleByGui[gui] = scale
	return scale
end

local function applyUiScale()
	local viewport = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
	local isSmall = viewport.X < 1400 or viewport.Y < 800
	local targetScale = isSmall and 1.07 or 1.0
	for _, gui in ipairs(playerGui:GetChildren()) do
		if gui:IsA("ScreenGui") then
			local scale = ensureScale(gui)
			scale.Scale = targetScale
		end
	end
end

local function setEffectsEnabled(enabled)
	for _, inst in ipairs(Workspace:GetDescendants()) do
		if inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam") then
			inst.Enabled = enabled
		end
	end
end

local function applyVisualTier(tier)
	if tier == lastAppliedTier then
		return
	end
	lastAppliedTier = tier
	local visual = PolishTypes.GetVisualTierSettings(tier)
	Lighting.GlobalShadows = visual.showShadows == true
	if tier == PolishConfig.QualityTier.Low then
		setEffectsEnabled(false)
	else
		setEffectsEnabled(true)
	end
end

playerGui.ChildAdded:Connect(function(child)
	if child:IsA("ScreenGui") then
		ensureScale(child)
		applyUiScale()
	end
end)

Workspace.DescendantAdded:Connect(function(inst)
	if lastAppliedTier ~= PolishConfig.QualityTier.Low then
		return
	end
	if inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam") then
		inst.Enabled = false
	end
end)

task.spawn(function()
	while true do
		applyVisualTier(getTier())
		applyUiScale()
		task.wait(1.5)
	end
end)
