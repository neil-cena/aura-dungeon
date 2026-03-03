--[[
	DungeonController.client.lua
	Day 4 client controller: wraps dungeon remotes and mirrors latest state.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local PolishConfig = require(ReplicatedStorage.shared.config.PolishConfig)
local PolishTypes = require(ReplicatedStorage.shared.types.PolishTypes)

local dungeonRemotes = ReplicatedStorage:WaitForChild("DungeonRemotes", 10)
if not dungeonRemotes then
	return
end

local GetDungeonState = dungeonRemotes:FindFirstChild("GetDungeonState")
local RequestStartDungeonRun = dungeonRemotes:FindFirstChild("RequestStartDungeonRun")
local RequestAdvanceDungeonPhase = dungeonRemotes:FindFirstChild("RequestAdvanceDungeonPhase")
local RequestCompleteDungeonRun = dungeonRemotes:FindFirstChild("RequestCompleteDungeonRun")
local DungeonUpdate = dungeonRemotes:FindFirstChild("DungeonUpdate")

if not GetDungeonState or not RequestStartDungeonRun or not RequestAdvanceDungeonPhase or not RequestCompleteDungeonRun or not DungeonUpdate then
	return
end

local state = {
	status = "idle",
	wave_index = 0,
	boss_spawned = false,
	runtime_seconds = 0,
	last_error = nil,
	last_result = nil,
	mute_mode = false,
	quality_tier = PolishConfig.QualityTier.Mid,
	device_profile = "mid",
}

local latencySamplesMs = {}
local pendingActionSentAt = nil

local function resolveDeviceProfile()
	local fromGlobal = _G.AuraDeviceProfile
	if type(fromGlobal) == "string" then
		return fromGlobal
	end
	if UserInputService.TouchEnabled then
		return "mid"
	end
	return "high"
end

local function updateQualityTier()
	state.device_profile = resolveDeviceProfile()
	state.quality_tier = PolishTypes.SelectQualityTierByDeviceProfile(state.device_profile)
end

local function setState(nextState)
	if type(nextState) ~= "table" then
		return
	end
	for k, v in pairs(nextState) do
		state[k] = v
	end
	updateQualityTier()
	_G.Day4DungeonState = state
end

local function refreshState()
	local r = GetDungeonState:InvokeServer()
	if r and r.success and r.state then
		setState(r.state)
		state.last_server_sent_at = r.server_sent_at
	end
	return state
end

local function startRun()
	pendingActionSentAt = os.clock()
	RequestStartDungeonRun:FireServer({ action = "start_run" })
end

local function advancePhase()
	pendingActionSentAt = os.clock()
	RequestAdvanceDungeonPhase:FireServer({ action = "advance_wave" })
end

local function completeRun(didWin)
	pendingActionSentAt = os.clock()
	RequestCompleteDungeonRun:FireServer({ action = didWin and "report_win" or "report_loss", did_win = didWin == true })
end

local function setMuteMode(enabled)
	state.mute_mode = enabled == true
	_G.Day4DungeonState = state
end

local function pushLatencySampleFromPending()
	if not pendingActionSentAt then
		return
	end
	local receivedAt = os.clock()
	local sampleMs = math.floor((receivedAt - pendingActionSentAt) * 1000)
	pendingActionSentAt = nil
	if sampleMs < 0 then
		return
	end
	table.insert(latencySamplesMs, sampleMs)
	local maxSamples = PolishConfig.Performance.RecommendedLatencySampleCount * 3
	if #latencySamplesMs > maxSamples then
		table.remove(latencySamplesMs, 1)
	end
	state.last_input_latency_ms = sampleMs
	state.input_latency_p95_ms = PolishTypes.ComputeP95(latencySamplesMs)
	state.input_latency_samples = #latencySamplesMs
	state.last_client_received_at = receivedAt
end

DungeonUpdate.OnClientEvent:Connect(function(payload)
	if not payload then
		return
	end
	if payload.success and payload.state then
		setState(payload.state)
		state.last_server_sent_at = payload.server_sent_at
		pushLatencySampleFromPending()
	elseif payload.success and payload.result then
		state.last_result = payload.result
		state.status = payload.result.status or state.status
		state.runtime_seconds = payload.result.runtime_seconds or state.runtime_seconds
		state.boss_spawned = payload.result.boss_spawned == true
		state.last_server_sent_at = payload.server_sent_at
		pushLatencySampleFromPending()
		_G.Day4DungeonState = state
	elseif not payload.success then
		state.last_error = payload.err or "unknown_error"
		state.last_server_sent_at = payload.server_sent_at
		pushLatencySampleFromPending()
		_G.Day4DungeonState = state
	end
end)

_G.Day4DungeonActions = {
	refreshState = refreshState,
	startRun = startRun,
	advancePhase = advancePhase,
	completeRun = completeRun,
	setMuteMode = setMuteMode,
}

updateQualityTier()
refreshState()

