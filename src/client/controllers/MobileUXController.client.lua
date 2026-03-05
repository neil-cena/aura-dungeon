--[[
	MobileUXController.client.lua
	Phase 4 polish: applies quality-tier visual downgrade and mobile-friendly UI scaling.
]]

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
if not player then
	return
end

local PolishConfig = require(ReplicatedStorage.shared.config.PolishConfig)
local PolishTypes = require(ReplicatedStorage.shared.types.PolishTypes)

local playerGui = player:WaitForChild("PlayerGui")
local uiScaleByGui = {}
local lastAppliedTier = nil
local safeAreaBindings = {}
local panelRegistry = {}
local launcherButtonsById = {}
local launcherGui = nil
local launcherBar = nil
local launcherDirty = true
local rotateHintLabel = nil

local function getSafeInsets()
	local topLeftInset, bottomRightInset = GuiService:GetGuiInset()
	return {
		left = topLeftInset.X,
		top = topLeftInset.Y,
		right = bottomRightInset.X,
		bottom = bottomRightInset.Y,
	}
end

local function applySafeAreaToBinding(binding)
	local target = binding.target
	if not target or not target.Parent then
		return
	end
	local insets = getSafeInsets()
	local basePosition = binding.basePosition
	local xOffset = 0
	local yOffset = 0
	if binding.opts.left then
		xOffset += insets.left
	end
	if binding.opts.right then
		xOffset -= insets.right
	end
	if binding.opts.top then
		yOffset += insets.top
	end
	if binding.opts.bottom then
		yOffset -= insets.bottom
	end
	target.Position = UDim2.new(basePosition.X.Scale, basePosition.X.Offset + xOffset, basePosition.Y.Scale, basePosition.Y.Offset + yOffset)
end

local function applySafeArea(target, opts)
	if not target or not target:IsA("GuiObject") then
		return
	end
	local binding = safeAreaBindings[target]
	if not binding then
		binding = {
			target = target,
			basePosition = target.Position,
			opts = {
				top = opts and opts.top == true,
				bottom = opts and opts.bottom == true,
				left = opts and opts.left == true,
				right = opts and opts.right == true,
			},
		}
		safeAreaBindings[target] = binding
	else
		binding.opts = {
			top = opts and opts.top == true,
			bottom = opts and opts.bottom == true,
			left = opts and opts.left == true,
			right = opts and opts.right == true,
		}
	end
	applySafeAreaToBinding(binding)
end

local function makeButton(parent, label)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 68, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(33, 41, 68)
	btn.TextColor3 = Color3.fromRGB(235, 241, 255)
	btn.TextSize = 13
	btn.Font = Enum.Font.GothamBold
	btn.Text = label
	btn.AutoButtonColor = true
	btn.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn
	return btn
end

local function ensureLauncher()
	if launcherGui and launcherGui.Parent then
		return
	end
	launcherGui = Instance.new("ScreenGui")
	launcherGui.Name = "MobileLauncherGui"
	launcherGui.ResetOnSpawn = false
	launcherGui.DisplayOrder = 20
	launcherGui.Parent = playerGui

	launcherBar = Instance.new("Frame")
	launcherBar.Name = "LauncherBar"
	launcherBar.Size = UDim2.new(0, 0, 0, 40)
	launcherBar.Position = UDim2.new(0.5, 0, 1, -50)
	launcherBar.AnchorPoint = Vector2.new(0.5, 1)
	launcherBar.BackgroundColor3 = Color3.fromRGB(16, 21, 36)
	launcherBar.BackgroundTransparency = 0.15
	launcherBar.Parent = launcherGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = launcherBar

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.Padding = UDim.new(0, 6)
	list.Parent = launcherBar

	applySafeArea(launcherBar, { bottom = true, left = true, right = true })

	rotateHintLabel = Instance.new("TextLabel")
	rotateHintLabel.Name = "RotateHint"
	rotateHintLabel.Size = UDim2.new(0.8, 0, 0, 42)
	rotateHintLabel.Position = UDim2.new(0.5, 0, 0.12, 0)
	rotateHintLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	rotateHintLabel.BackgroundColor3 = Color3.fromRGB(18, 22, 38)
	rotateHintLabel.BackgroundTransparency = 0.15
	rotateHintLabel.BorderSizePixel = 0
	rotateHintLabel.TextColor3 = Color3.fromRGB(239, 244, 255)
	rotateHintLabel.TextSize = 16
	rotateHintLabel.Font = Enum.Font.GothamBold
	rotateHintLabel.Text = "Rotate device to landscape for best controls"
	rotateHintLabel.Visible = false
	rotateHintLabel.Parent = launcherGui
	applySafeArea(rotateHintLabel, { top = true, left = true, right = true })
end

local function refreshLauncher()
	ensureLauncher()
	for id, btn in pairs(launcherButtonsById) do
		if not panelRegistry[id] then
			btn:Destroy()
			launcherButtonsById[id] = nil
		end
	end

	local order = { "macro", "shop", "battlepass", "party", "social" }
	local count = 0
	for _, id in ipairs(order) do
		local panel = panelRegistry[id]
		if panel then
			count += 1
			local btn = launcherButtonsById[id]
			if not btn or not btn.Parent then
				btn = makeButton(launcherBar, panel.label or id)
				btn.MouseButton1Click:Connect(function()
					if panel.toggle then
						panel.toggle()
					end
				end)
				launcherButtonsById[id] = btn
			end
			if panel.isVisible and panel.isVisible() then
				btn.BackgroundColor3 = Color3.fromRGB(75, 126, 214)
			else
				btn.BackgroundColor3 = Color3.fromRGB(33, 41, 68)
			end
		end
	end

	local width = math.max(152, count * 74 + 14)
	launcherBar.Size = UDim2.new(0, width, 0, 40)
	launcherBar.Visible = UserInputService.TouchEnabled
	local viewport = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
	local isPortrait = viewport.Y > viewport.X
	if rotateHintLabel then
		rotateHintLabel.Visible = UserInputService.TouchEnabled and PolishConfig.ThumbLayout.LandscapeOnly == true and isPortrait
	end
end

_G.AuraApplySafeArea = applySafeArea
_G.AuraRegisterPanel = function(id, label, toggleFn, isVisibleFn)
	if type(id) ~= "string" or id == "" then
		return
	end
	panelRegistry[id] = {
		label = label,
		toggle = toggleFn,
		isVisible = isVisibleFn,
	}
	launcherDirty = true
end

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
		for target, binding in pairs(safeAreaBindings) do
			if target and target.Parent then
				applySafeAreaToBinding(binding)
			else
				safeAreaBindings[target] = nil
			end
		end
		if launcherDirty then
			refreshLauncher()
			launcherDirty = false
		else
			refreshLauncher()
		end
		task.wait(1.5)
	end
end)
