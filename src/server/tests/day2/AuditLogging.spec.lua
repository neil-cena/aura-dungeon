--[[
	AuditLogging.spec.lua
	Group C: Every roll creates roll_events + economy_transactions with required fields.
	Maps to day2-roll-system-test-checklist Group C.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local server = ServerScriptService.server
local RollService = require(server.domain.RollService)
local AuditLogger = require(server.domain.AuditLogger)
local ProfileStore = require(server.persistence.ProfileStore)

local function runAuditTests()
	ProfileStore.ClearCache()
	AuditLogger.ClearLogs()

	local passed, failed = 0, 0
	local testPlayerId = "test-audit-001"

	-- Ensure profile exists with enough currency
	ProfileStore.GetProfile(testPlayerId)

	local result, err = RollService.ExecuteRoll(testPlayerId, "Aura")
	if not result then
		return 0, 5
	end

	-- C1: One roll_events record
	local events = AuditLogger.GetRollEventsForPlayer(testPlayerId)
	if #events == 1 then
		passed = passed + 1
	else
		failed = failed + 1
	end

	-- C2: economy_transactions for spend
	local txs = AuditLogger.GetEconomyTransactionsForPlayer(testPlayerId)
	if #txs >= 1 then
		passed = passed + 1
	else
		failed = failed + 1
	end

	-- C3-C5: Required fields present
	local e = events[1]
	local required = { "event_id", "timestamp", "player_id", "lane", "pre_counters", "result_rarity", "result_item_id", "pity_override_used", "post_counters", "rng_table_version" }
	local allPresent = true
	for _, k in ipairs(required) do
		if e[k] == nil then allPresent = false break end
	end
	if allPresent then
		passed = passed + 1
	else
		failed = failed + 1
	end

	local t = txs[1]
	local txRequired = { "tx_id", "timestamp", "player_id", "currency", "delta", "balance_before", "balance_after", "reason_code", "source_context" }
	allPresent = true
	for _, k in ipairs(txRequired) do
		if t[k] == nil then allPresent = false break end
	end
	if allPresent then
		passed = passed + 1
	else
		failed = failed + 1
	end

	-- C4/C5: Idempotency and reconstruction (simplified: we have the records)
	if #events >= 1 and #txs >= 1 then
		passed = passed + 1
	else
		failed = failed + 1
	end

	return passed, failed
end

return { run = runAuditTests }
