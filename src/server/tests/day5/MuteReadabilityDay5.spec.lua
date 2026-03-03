--[[
	MuteReadabilityDay5.spec.lua
	Day 5: Critical cues are readable in mute-play mode.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DungeonConfig = require(ReplicatedStorage.shared.config.DungeonConfig)
local PolishConfig = require(ReplicatedStorage.shared.config.PolishConfig)
local PolishTypes = require(ReplicatedStorage.shared.types.PolishTypes)

local function runMuteReadabilityDay5Tests()
	local passed, failed = 0, 0

	if PolishConfig.Readability.MuteReadable == true and DungeonConfig.Telegraph.MuteReadable == true then
		passed = passed + 1
	else
		failed = failed + 1
	end

	if PolishTypes.HasReadableCueText(DungeonConfig.Telegraph.PromptText) then
		passed = passed + 1
	else
		failed = failed + 1
	end

	if PolishTypes.HasReadableCueText(DungeonConfig.Telegraph.BossSpawnText) then
		passed = passed + 1
	else
		failed = failed + 1
	end

	return passed, failed
end

return { run = runMuteReadabilityDay5Tests }
