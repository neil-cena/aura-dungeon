--[[
	RuntimeWindow.spec.lua
	Day 4: Verify 2-3 minute runtime window checks.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local server = ServerScriptService.server

local DungeonService = require(server.domain.DungeonService)
local DungeonConfig = require(ReplicatedStorage.shared.config.DungeonConfig)

local function runRuntimeWindowTests()
	local passed, failed = 0, 0

	DungeonService.StartRun("day4-runtime-a")
	local resultA = DungeonService.CompleteRun("day4-runtime-a", DungeonConfig.Status.Won, 150)
	if resultA and resultA.runtime_seconds >= DungeonConfig.Run.TargetMinSeconds and resultA.runtime_seconds <= DungeonConfig.Run.TargetMaxSeconds then
		passed = passed + 1
	else
		failed = failed + 1
	end

	DungeonService.StartRun("day4-runtime-b")
	local resultB = DungeonService.CompleteRun("day4-runtime-b", DungeonConfig.Status.Won, 95)
	if resultB and (resultB.runtime_seconds < DungeonConfig.Run.TargetMinSeconds) then
		passed = passed + 1
	else
		failed = failed + 1
	end

	DungeonService.StartRun("day4-runtime-c")
	local resultC = DungeonService.CompleteRun("day4-runtime-c", DungeonConfig.Status.Won, 205)
	if resultC and (resultC.runtime_seconds > DungeonConfig.Run.TargetMaxSeconds) then
		passed = passed + 1
	else
		failed = failed + 1
	end

	return passed, failed
end

return { run = runRuntimeWindowTests }

