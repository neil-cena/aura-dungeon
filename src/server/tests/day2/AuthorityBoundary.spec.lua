--[[
	AuthorityBoundary.spec.lua
	Group A: Client attempts to submit forced rarity/counters -> server rejects.
	Run in test harness. Maps to day2-roll-system-test-checklist Group A.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RollTypes = require(ReplicatedStorage.shared.types.RollTypes)

local function runAuthorityTests()
	local passed = 0
	local failed = 0

	-- A1: Reject payload with forced rarity
	local payload1 = { lane = "Aura", rarity = "Legendary" }
	if RollTypes.IsSafeRollRequest(payload1) then
		failed = failed + 1
	else
		passed = passed + 1
	end

	-- A2: Reject payload with custom pity counters
	local payload2 = { lane = "Aura", since_rare_plus = 9 }
	if RollTypes.IsSafeRollRequest(payload2) then
		failed = failed + 1
	else
		passed = passed + 1
	end

	-- A3: Valid lane-only payload is safe
	local payload3 = { lane = "Aura" }
	if not RollTypes.IsSafeRollRequest(payload3) then
		failed = failed + 1
	else
		passed = passed + 1
	end

	-- A4: String lane validation
	if not RollTypes.IsValidLane("Aura") or not RollTypes.IsValidLane("Weapon") then
		failed = failed + 1
	elseif RollTypes.IsValidLane("Legendary") or RollTypes.IsValidLane(nil) then
		failed = failed + 1
	else
		passed = passed + 1
	end

	return passed, failed
end

return { run = runAuthorityTests }
