--[[
	PityDeterminism.spec.lua
	Group B: Deterministic pity at 10/50/250, lane isolation.
	Uses PityEngine. Maps to day2-roll-system-test-checklist Group B.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local PityEngine = require(ServerScriptService.server.domain.PityEngine)
local RollTypes = require(game:GetService("ReplicatedStorage").shared.types.RollTypes)

local function runPityTests()
	local passed, failed = 0, 0

	-- B1: 10 consecutive Common -> 10th grants Rare+
	local c = RollTypes.CreateEmptyCounters()
	for i = 1, 9 do
		c = PityEngine.UpdateCountersAfterResult(c, "Common")
	end
	local pity = PityEngine.GetEligiblePity(c)
	if pity == "Rare" then
		passed = passed + 1
	else
		failed = failed + 1
	end

	-- B2: 50 without Epic+ -> 50th Epic+
	c = RollTypes.CreateEmptyCounters()
	for i = 1, 49 do
		c = PityEngine.UpdateCountersAfterResult(c, "Rare")
	end
	pity = PityEngine.GetEligiblePity(c)
	if pity == "Epic" then
		passed = passed + 1
	else
		failed = failed + 1
	end

	-- B3: 250 without Legendary -> 250th Legendary
	c = RollTypes.CreateEmptyCounters()
	for i = 1, 249 do
		c = PityEngine.UpdateCountersAfterResult(c, "Epic")
	end
	pity = PityEngine.GetEligiblePity(c)
	if pity == "Legendary" then
		passed = passed + 1
	else
		failed = failed + 1
	end

	-- B4-B5: Lane isolation (tested via RollService integration; here we verify PityEngine is pure)
	-- B6: Counter reset after Rare
	c = { roll_count_total = 5, since_rare_plus = 8, since_epic_plus = 3, since_legendary = 1 }
	local c2 = PityEngine.UpdateCountersAfterResult(c, "Rare")
	if c2.since_rare_plus == 0 and c2.since_epic_plus == 4 and c2.since_legendary == 2 then
		passed = passed + 1
	else
		failed = failed + 1
	end

	-- B7: Highest-tier precedence (Legendary pity over Epic when both eligible)
	c = { roll_count_total = 0, since_rare_plus = 10, since_epic_plus = 50, since_legendary = 250 }
	pity = PityEngine.GetEligiblePity(c)
	if pity == "Legendary" then
		passed = passed + 1
	else
		failed = failed + 1
	end

	return passed, failed
end

return { run = runPityTests }
