--[[
	DungeonTypes.lua
	Day 4: Payload validation helpers for dungeon run requests.
]]

local DungeonConfig = require(script.Parent.Parent.config.DungeonConfig)

local DungeonTypes = {}

local VALID_ACTIONS = {
	start_run = true,
	advance_wave = true,
	report_hit = true,
	report_loss = true,
	report_win = true,
}

local FORBIDDEN_KEYS = {
	runtime_seconds = true,
	status = true,
	boss_spawned = true,
	reward = true,
	coins = true,
	tokens = true,
	timestamps = true,
	phase = true,
}

function DungeonTypes.IsSafeDungeonRequest(payload)
	if type(payload) ~= "table" then
		return false
	end
	for key, _ in pairs(payload) do
		if FORBIDDEN_KEYS[key] then
			return false
		end
	end
	if payload.action ~= nil then
		return type(payload.action) == "string" and VALID_ACTIONS[payload.action] == true
	end
	return true
end

function DungeonTypes.IsValidOutcome(outcome)
	return outcome == DungeonConfig.Status.Won or outcome == DungeonConfig.Status.Lost
end

return DungeonTypes

