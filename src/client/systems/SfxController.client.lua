--[[
	SfxController.client.lua
	Phase 4 polish: centralized local SFX playback with mute support.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
if not player then
	return
end

local shared = ReplicatedStorage:WaitForChild("shared")
local AssetCatalog = require(shared.config.AssetCatalog)

local rollRemotes = ReplicatedStorage:WaitForChild("RollRemotes")
local dungeonRemotes = ReplicatedStorage:WaitForChild("DungeonRemotes")
local combatRemotes = ReplicatedStorage:WaitForChild("CombatRemotes")

local rollResult = rollRemotes:WaitForChild("RollResult")
local dungeonUpdate = dungeonRemotes:WaitForChild("DungeonUpdate")
local combatUpdate = combatRemotes:WaitForChild("CombatUpdate")

local uiFolder = Instance.new("Folder")
uiFolder.Name = "AuraSfx"
uiFolder.Parent = SoundService

local soundPool = {}

local function isMuted()
	local state = _G.Day4DungeonState
	return state and state.mute_mode == true
end

local function getOrCreate(soundId)
	if soundPool[soundId] and soundPool[soundId].Parent then
		return soundPool[soundId]
	end
	local sound = Instance.new("Sound")
	sound.Name = "AuraSfx_" .. tostring(#soundPool + 1)
	sound.SoundId = soundId
	sound.Volume = 0.42
	sound.RollOffMaxDistance = 60
	sound.Parent = uiFolder
	soundPool[soundId] = sound
	return sound
end

local function playSoundById(soundId)
	if type(soundId) ~= "string" or soundId == "" then
		return
	end
	if isMuted() then
		return
	end
	local sound = getOrCreate(soundId)
	if sound.IsPlaying then
		sound.TimePosition = 0
	end
	sound:Play()
end

local function playFromCatalog(key)
	local map = AssetCatalog.Sounds or {}
	playSoundById(map[key])
end

rollResult.OnClientEvent:Connect(function(payload)
	if type(payload) ~= "table" then
		return
	end
	if payload.success ~= true then
		playFromCatalog("UiClick")
		return
	end
	local rarity = tostring((payload.result or {}).rarity or "Common")
	if rarity == "Legendary" then
		playFromCatalog("RollRevealLegendary")
	elseif rarity == "Epic" then
		playFromCatalog("RollRevealEpic")
	elseif rarity == "Rare" then
		playFromCatalog("RollRevealRare")
	else
		playFromCatalog("RollRevealCommon")
	end
end)

combatUpdate.OnClientEvent:Connect(function(payload)
	if type(payload) ~= "table" then
		return
	end
	if payload.boss_telegraph == true then
		playFromCatalog("BossTelegraph")
		return
	end
	if payload.success and payload.hit then
		playFromCatalog("CombatHit")
	end
end)

dungeonUpdate.OnClientEvent:Connect(function(payload)
	if type(payload) ~= "table" or payload.success ~= true then
		return
	end
	if payload.action == "run_completed" then
		playFromCatalog("Reward")
		if payload.result and payload.result.outcome == "won" then
			playFromCatalog("BossDeath")
		end
	end
end)
