--[[
	BossPresence.spec.lua
	Day 4: Boss appears in every run.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local server = ServerScriptService.server

local DungeonService = require(server.domain.DungeonService)
local DungeonConfig = require(ReplicatedStorage.shared.config.DungeonConfig)

local function runBossPresenceTests()
	local passed, failed = 0, 0

	for i = 1, 10 do
		local playerId = "day4-boss-" .. tostring(i)
		DungeonService.StartRun(playerId)
		for _ = 1, DungeonConfig.Phases.WaveCount do
			DungeonService.AdvancePhase(playerId)
		end
		local state = DungeonService.GetState(playerId)
		if state and state.boss_spawned == true and state.status == DungeonConfig.Status.Boss then
			passed = passed + 1
		else
			failed = failed + 1
		end
	end

	return passed, failed
end

return { run = runBossPresenceTests }

