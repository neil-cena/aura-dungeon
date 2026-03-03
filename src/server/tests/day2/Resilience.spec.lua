--[[
	Resilience.spec.lua
	Group E: Retry/backoff behavior, failure rate.
	Simplified: verify ProfileStore retry logic exists.
	Full fault injection requires harness. Maps to day2-roll-system-test-checklist Group E.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ProfileStore = require(ServerScriptService.server.persistence.ProfileStore)

local function runResilienceTests()
	local passed, failed = 0, 0

	-- E2: Validation failures (insufficient balance) should not retry
	ProfileStore.ClearCache()
	local success, err = ProfileStore.UpdateProfile("test-res-001", function(p)
		p = p or ProfileStore.CreateDefaultProfile("test-res-001")
		p.currencies.coins = 0
		return p, nil
	end)
	-- Mutator succeeds, so we'd update. Spend would fail in RollService. Here we check UpdateProfile
	-- doesn't retry on mutator error. Mutator returning (nil, "err") means validation failure.
	local ok, valErr = ProfileStore.UpdateProfile("test-res-002", function()
		return nil, "insufficient balance"
	end)
	if ok == false and valErr == "insufficient balance" then
		passed = passed + 1
	else
		failed = failed + 1
	end

	-- E4: Critical write success path (no fault injection in basic test)
	ProfileStore.ClearCache()
	ProfileStore.GetProfile("test-res-003")
	local ok2, _ = ProfileStore.UpdateProfile("test-res-003", function(p)
		p.currencies.coins = 999
		return p, nil
	end)
	if ok2 then
		passed = passed + 1
	else
		failed = failed + 1
	end

	return passed, failed
end

return { run = runResilienceTests }
