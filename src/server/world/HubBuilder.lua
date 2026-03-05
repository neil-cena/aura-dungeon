--[[
	HubBuilder.lua
	Builds a lightweight social hub with interaction prompts.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("shared")
local AssetCatalog = require(shared.config.AssetCatalog)
local LightingConfig = require(shared.config.LightingConfig)
local VisualFactory = require(script.Parent.VisualFactory)

local Remotes = require(script.Parent.Parent.network.Remotes)

local HubBuilder = {}

local HUB_FOLDER_NAME = "AuraHub"
local HUB_SPAWN_NAME = "HubSpawn"

local function removeIfPresent(parent, name)
	local item = parent and parent:FindFirstChild(name)
	if item then
		item:Destroy()
	end
end

local function getOrCreatePart(parent, name, size, cf, color, material)
	local part = parent:FindFirstChild(name)
	if not part then
		part = Instance.new("Part")
		part.Name = name
		part.Anchored = true
		part.CanCollide = true
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.Parent = parent
	end
	part.Size = size
	part.CFrame = cf
	part.Color = color
	part.Material = material
	return part
end

local function ensurePrompt(part, promptName, actionText, objectText, holdDuration, callback)
	local prompt = part:FindFirstChild(promptName)
	if not prompt then
		prompt = Instance.new("ProximityPrompt")
		prompt.Name = promptName
		prompt.Parent = part
	end
	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = holdDuration or 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Triggered:Connect(callback)
end

local function ensureBillboard(part, name, titleText, subtitleText)
	local billboard = part:FindFirstChild(name)
	if not billboard then
		billboard = Instance.new("BillboardGui")
		billboard.Name = name
		billboard.Parent = part
	end
	billboard.Size = UDim2.new(0, 200, 0, 64)
	billboard.StudsOffset = Vector3.new(0, (part.Size.Y / 2) + 3.5, 0)
	billboard.AlwaysOnTop = true

	local title = billboard:FindFirstChild("Title")
	if not title then
		title = Instance.new("TextLabel")
		title.Name = "Title"
		title.Parent = billboard
	end
	title.Size = UDim2.new(1, 0, 0.6, 0)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundTransparency = 1
	title.TextScaled = true
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextStrokeTransparency = 0.15
	title.Font = Enum.Font.GothamBold
	title.Text = titleText

	local subtitle = billboard:FindFirstChild("Subtitle")
	if not subtitle then
		subtitle = Instance.new("TextLabel")
		subtitle.Name = "Subtitle"
		subtitle.Parent = billboard
	end
	subtitle.Size = UDim2.new(1, 0, 0.4, 0)
	subtitle.Position = UDim2.new(0, 0, 0.6, 0)
	subtitle.BackgroundTransparency = 1
	subtitle.TextScaled = true
	subtitle.TextColor3 = Color3.fromRGB(225, 232, 255)
	subtitle.TextStrokeTransparency = 0.35
	subtitle.Font = Enum.Font.Gotham
	subtitle.Text = subtitleText
end

local function applyHubLighting()
	local cfg = LightingConfig.Hub
	Lighting.Ambient = cfg.Ambient
	Lighting.OutdoorAmbient = cfg.OutdoorAmbient
	Lighting.Brightness = cfg.Brightness
	Lighting.ClockTime = cfg.ClockTime
	Lighting.FogColor = cfg.FogColor
	Lighting.FogStart = cfg.FogStart
	Lighting.FogEnd = cfg.FogEnd
end

function HubBuilder.GetHubSpawnCFrame()
	local folder = Workspace:FindFirstChild(HUB_FOLDER_NAME)
	if not folder then
		return CFrame.new(0, 8, 0)
	end
	local spawnPart = folder:FindFirstChild(HUB_SPAWN_NAME)
	if not spawnPart or not spawnPart:IsA("BasePart") then
		return CFrame.new(0, 8, 0)
	end
	return spawnPart.CFrame + Vector3.new(0, 4, 0)
end

function HubBuilder.Build()
	local folder = Workspace:FindFirstChild(HUB_FOLDER_NAME)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = HUB_FOLDER_NAME
		folder.Parent = Workspace
	end

	local hubGround = getOrCreatePart(
		folder,
		"HubGround",
		Vector3.new(260, 6, 260),
		CFrame.new(0, -3, 0),
		AssetCatalog.Hub.GroundColor or Color3.fromRGB(52, 58, 70),
		AssetCatalog.Hub.GroundMaterial
	)
	hubGround.Locked = true

	local spawnPad = getOrCreatePart(
		folder,
		HUB_SPAWN_NAME,
		Vector3.new(18, 1, 18),
		CFrame.new(0, 3, 0),
		AssetCatalog.Hub.AccentColor,
		Enum.Material.Neon
	)
	spawnPad.CanCollide = true

	local rollStation = getOrCreatePart(
		folder,
		"RollStation",
		Vector3.new(12, 12, 12),
		CFrame.new(42, 6, 0),
		AssetCatalog.Hub.RollStationColor,
		Enum.Material.SmoothPlastic
	)

	local riftPortal = getOrCreatePart(
		folder,
		"RiftPortal",
		Vector3.new(16, 20, 3),
		CFrame.new(-46, 10, 0),
		AssetCatalog.Hub.PortalColor,
		Enum.Material.Neon
	)
	riftPortal.Transparency = 0.2

	local inventoryPedestal = getOrCreatePart(
		folder,
		"InventoryPedestal",
		Vector3.new(10, 8, 10),
		CFrame.new(0, 4, 38),
		AssetCatalog.Hub.SecondaryAccentColor or Color3.fromRGB(85, 215, 200),
		Enum.Material.SmoothPlastic
	)

	removeIfPresent(folder, "HubDecor")
	removeIfPresent(folder, "GroundArt")
	removeIfPresent(folder, "RollStationArt")
	removeIfPresent(folder, "InventoryPedestalArt")
	removeIfPresent(folder, "RiftPortalArt")
	local groundArt = VisualFactory.TrySpawnModel((AssetCatalog.Models.Hub or {}).Ground, folder, hubGround.CFrame, "GroundArt")
	if groundArt then
		-- Fully replace primitive floor when custom ground asset is provided.
		hubGround.Transparency = 1
		hubGround.CanCollide = false
		hubGround.CanTouch = false
	else
		hubGround.Transparency = 0
		hubGround.CanCollide = true
		hubGround.CanTouch = true
	end
	VisualFactory.TrySpawnModel((AssetCatalog.Models.Hub or {}).DecorSet, folder, CFrame.new(0, 0, 0), "HubDecor")
	VisualFactory.TrySpawnModel((AssetCatalog.Models.Hub or {}).RollStation, folder, rollStation.CFrame, "RollStationArt")
	VisualFactory.TrySpawnModel((AssetCatalog.Models.Hub or {}).InventoryPedestal, folder, inventoryPedestal.CFrame, "InventoryPedestalArt")
	VisualFactory.TrySpawnModel((AssetCatalog.Models.Hub or {}).RiftPortal, folder, riftPortal.CFrame, "RiftPortalArt")

	for i = 1, 8 do
		local angle = math.rad((i - 1) * 45)
		local radius = 92
		local pos = Vector3.new(math.cos(angle) * radius, 7, math.sin(angle) * radius)
		local crystal = getOrCreatePart(
			folder,
			"HubCrystal_" .. tostring(i),
			Vector3.new(4, 14, 4),
			CFrame.new(pos) * CFrame.Angles(0, angle, 0),
			(i % 2 == 0) and AssetCatalog.Hub.SecondaryAccentColor or AssetCatalog.Hub.AccentColor,
			Enum.Material.Neon
		)
		crystal.Transparency = 0.15
	end

	ensurePrompt(rollStation, "RollPrompt", "Open Rolls", "Aura Roll Station", 0, function(player)
		if player and player:IsA("Player") then
			Remotes.ShowRollPanel:FireClient(player, { source = "hub_station" })
		end
	end)
	ensureBillboard(rollStation, "RollStationLabel", "ROLL STATION", "Spend currency for auras or weapons")

	ensurePrompt(inventoryPedestal, "InventoryPrompt", "Open Inventory", "Loadout Console", 0, function(player)
		if player and player:IsA("Player") then
			Remotes.ShowInventoryPanel:FireClient(player, { source = "hub_portal" })
		end
	end)
	ensureBillboard(inventoryPedestal, "InventoryLabel", "LOADOUT", "Equip your best aura and weapon")

	ensurePrompt(riftPortal, "DungeonPrompt", "Enter Rift", "Dungeon Portal", 0, function(player)
		if player and player:IsA("Player") then
			Remotes.ShowDungeonPanel:FireClient(player, {
				source = "hub_rift_portal",
				auto_start = true,
			})
		end
	end)
	ensureBillboard(riftPortal, "RiftLabel", "DUNGEON RIFT", "Fight waves and claim rewards")

	applyHubLighting()
end

function HubBuilder.BindSpawnRouting()
	local function onCharacterAdded(character)
		local root = character:WaitForChild("HumanoidRootPart", 5)
		if root then
			root.CFrame = HubBuilder.GetHubSpawnCFrame()
		end
	end

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(onCharacterAdded)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		player.CharacterAdded:Connect(onCharacterAdded)
	end
end

return HubBuilder
