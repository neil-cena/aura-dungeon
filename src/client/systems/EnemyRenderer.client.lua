--[[
	EnemyRenderer.client.lua
	Adds health bars and lightweight damage number pops for dungeon enemies.
]]

local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local combatRemotes = ReplicatedStorage:WaitForChild("CombatRemotes")
local combatUpdate = combatRemotes:WaitForChild("CombatUpdate")

local activeBars = {}

local function resolveVisualPart(enemyInstance)
	if enemyInstance:IsA("BasePart") then
		return enemyInstance
	end
	if enemyInstance:IsA("Model") then
		if enemyInstance.PrimaryPart then
			return enemyInstance.PrimaryPart
		end
		for _, d in ipairs(enemyInstance:GetDescendants()) do
			if d:IsA("BasePart") then
				enemyInstance.PrimaryPart = d
				return d
			end
		end
	end
	return nil
end

local function ensureBar(enemyInstance)
	if activeBars[enemyInstance] then
		return
	end
	local enemyPart = resolveVisualPart(enemyInstance)
	if not enemyPart or not enemyPart:IsA("BasePart") then
		return
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "EnemyHealthBillboard"
	billboard.Size = UDim2.new(0, 88, 0, 28)
	billboard.StudsOffset = Vector3.new(0, (enemyPart.Size.Y / 2) + 2.1, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = enemyPart

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 0, 10)
	bg.Position = UDim2.new(0, 0, 1, -12)
	bg.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	bg.BorderSizePixel = 0
	bg.Parent = billboard

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.BackgroundColor3 = enemyPart:GetAttribute("EnemyIsBoss") and Color3.fromRGB(255, 120, 120) or Color3.fromRGB(120, 255, 125)
	fill.BorderSizePixel = 0
	fill.Parent = bg

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 16)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.fromRGB(255, 250, 230)
	nameLabel.TextStrokeTransparency = 0.25
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Text = tostring(enemyPart:GetAttribute("EnemyDisplayName") or (enemyPart:GetAttribute("EnemyIsBoss") and "Boss" or "Enemy"))
	nameLabel.Parent = billboard

	activeBars[enemyInstance] = { billboard = billboard, part = enemyPart }
end

local function updateBar(enemyInstance)
	local rec = activeBars[enemyInstance]
	local bar = rec and rec.billboard
	if not bar then
		return
	end
	local enemyPart = rec.part
	if not enemyPart or not enemyPart.Parent then
		enemyPart = resolveVisualPart(enemyInstance)
		if not enemyPart then
			return
		end
		rec.part = enemyPart
	end
	local bg = bar:FindFirstChildOfClass("Frame")
	local fill = bg and bg:FindFirstChild("Fill")
	if not fill then
		return
	end
	local hp = tonumber(enemyPart:GetAttribute("EnemyCurrentHealth") or 0)
	local maxHp = tonumber(enemyPart:GetAttribute("EnemyMaxHealth") or hp)
	local ratio = 0
	if maxHp > 0 then
		ratio = math.clamp(hp / maxHp, 0, 1)
	end
	fill.Size = UDim2.new(ratio, 0, 1, 0)
end

local function destroyBar(enemyInstance)
	local rec = activeBars[enemyInstance]
	if rec and rec.billboard then
		rec.billboard:Destroy()
		activeBars[enemyInstance] = nil
	end
end

local function createDamagePop(position, text, color)
	local marker = Instance.new("Part")
	marker.Name = "DamagePop"
	marker.Anchored = true
	marker.CanCollide = false
	marker.Transparency = 1
	marker.Size = Vector3.new(1, 1, 1)
	marker.CFrame = CFrame.new(position)
	marker.Parent = Workspace

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 120, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = marker

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.TextColor3 = color
	label.TextStrokeTransparency = 0.15
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.Parent = billboard

	task.spawn(function()
		for i = 1, 14 do
			marker.CFrame = marker.CFrame + Vector3.new(0, 0.16, 0)
			label.TextTransparency = i / 15
			label.TextStrokeTransparency = math.min(1, 0.15 + (i / 15))
			task.wait(0.04)
		end
		if marker then
			marker:Destroy()
		end
	end)
	Debris:AddItem(marker, 1.5)
end

for _, enemyInstance in ipairs(CollectionService:GetTagged("AuraEnemy")) do
	ensureBar(enemyInstance)
	updateBar(enemyInstance)
end

CollectionService:GetInstanceAddedSignal("AuraEnemy"):Connect(function(enemy)
	ensureBar(enemy)
	updateBar(enemy)
end)

CollectionService:GetInstanceRemovedSignal("AuraEnemy"):Connect(function(enemy)
	destroyBar(enemy)
end)

combatUpdate.OnClientEvent:Connect(function(payload)
	if not payload or not payload.success then
		return
	end
	if payload.hit and payload.hit.target_position then
		createDamagePop(payload.hit.target_position + Vector3.new(0, 4, 0), string.format("-%d", payload.hit.damage or 0), Color3.fromRGB(255, 215, 120))
	end
	if payload.boss_impact then
		local rootPos = Vector3.new(0, 8, 0)
		local localPlayer = Players.LocalPlayer
		local character = localPlayer and localPlayer.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		if hrp then
			rootPos = hrp.Position + Vector3.new(0, 5, 0)
		end
		if payload.did_hit then
			createDamagePop(rootPos, string.format("Boss Hit -%d", payload.damage or 0), Color3.fromRGB(255, 125, 125))
		else
			createDamagePop(rootPos, "Dodged", Color3.fromRGB(132, 255, 170))
		end
	end
end)

task.spawn(function()
	while true do
		for enemyInstance in pairs(activeBars) do
			if enemyInstance and enemyInstance.Parent then
				updateBar(enemyInstance)
			else
				destroyBar(enemyInstance)
			end
		end
		task.wait(0.15)
	end
end)
