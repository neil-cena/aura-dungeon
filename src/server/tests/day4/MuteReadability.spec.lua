--[[
	MuteReadability.spec.lua
	Day 4: Critical combat feedback readable without audio.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DungeonConfig = require(ReplicatedStorage.shared.config.DungeonConfig)

local function runMuteReadabilityTests()
	local passed, failed = 0, 0

	if DungeonConfig.Telegraph.MuteReadable == true then
		passed = passed + 1
	else
		failed = failed + 1
	end

	if type(DungeonConfig.Telegraph.PromptText) == "string" and #DungeonConfig.Telegraph.PromptText > 0 then
		passed = passed + 1
	else
		failed = failed + 1
	end

	if type(DungeonConfig.Telegraph.BossSpawnText) == "string" and #DungeonConfig.Telegraph.BossSpawnText > 0 then
		passed = passed + 1
	else
		failed = failed + 1
	end

	return passed, failed
end

return { run = runMuteReadabilityTests }

