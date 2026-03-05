--[[
	AuraRenderer.client.lua
	Renders lightweight placeholder aura particles for equipped aura IDs.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("shared")
local AuraCatalog = require(shared.config.AuraCatalog)
local RarityPresentation = require(shared.config.RarityPresentation)

local inventoryRemotes = ReplicatedStorage:WaitForChild("InventoryRemotes")
local auraEquippedRemote = inventoryRemotes:FindFirstChild("AuraEquipped")

local function clearAura(character)
	local old = character:FindFirstChild("AuraAttachment")
	if old then
		old:Destroy()
	end
end

local function applyAura(character, itemId)
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	clearAura(character)

	local rarity = RarityPresentation.FromItemId(itemId)
	local cfg = AuraCatalog.RarityVfx[rarity] or AuraCatalog.RarityVfx.Common

	local attachment = Instance.new("Attachment")
	attachment.Name = "AuraAttachment"
	attachment.Parent = root

	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "AuraEmitter"
	emitter.Texture = cfg.Texture
	emitter.Rate = cfg.Rate
	emitter.Speed = NumberRange.new(0.6, 1.8)
	emitter.Lifetime = NumberRange.new(1.0, 1.8)
	emitter.SpreadAngle = Vector2.new(360, 360)
	emitter.Color = ColorSequence.new(cfg.Color)
	emitter.Parent = attachment

	local light = Instance.new("PointLight")
	light.Color = cfg.Color
	light.Range = cfg.LightRange
	light.Brightness = 1.1
	light.Parent = attachment
end

local function bindCharacter(player)
	local function updateAura(character)
		local equippedAuraId = character:GetAttribute("EquippedAuraId")
		if type(equippedAuraId) == "string" and equippedAuraId ~= "" then
			applyAura(character, equippedAuraId)
		else
			clearAura(character)
		end
	end

	player.CharacterAdded:Connect(function(character)
		character:GetAttributeChangedSignal("EquippedAuraId"):Connect(function()
			updateAura(character)
		end)
		task.delay(0.2, function()
			updateAura(character)
		end)
	end)

	if player.Character then
		local character = player.Character
		character:GetAttributeChangedSignal("EquippedAuraId"):Connect(function()
			updateAura(character)
		end)
		updateAura(character)
	end
end

for _, plr in ipairs(Players:GetPlayers()) do
	bindCharacter(plr)
end
Players.PlayerAdded:Connect(bindCharacter)

if auraEquippedRemote then
	auraEquippedRemote.OnClientEvent:Connect(function(payload)
		if type(payload) ~= "table" then
			return
		end
		local userId = tonumber(payload.player_user_id)
		local itemId = payload.item_id
		if not userId or type(itemId) ~= "string" then
			return
		end
		local target = Players:GetPlayerByUserId(userId)
		if target and target.Character then
			target.Character:SetAttribute("EquippedAuraId", itemId)
		end
	end)
end
