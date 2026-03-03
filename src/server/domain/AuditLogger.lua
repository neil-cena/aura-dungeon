--[[
	AuditLogger.lua
	Append-only roll_events and economy_transactions.
	Unique IDs, idempotency-safe. Source: data-schema-v1 §7.
]]

local HttpService = game:GetService("HttpService")

local AuditLogger = {}

local rollEventsLog = {}
local economyTransactionsLog = {}
local seenEventIds = {}
local seenTxIds = {}

--[[
	LogRollEvent(payload) -> (eventId, err?)
	Writes one roll_events record. Returns event_id or nil, err.
]]
function AuditLogger.LogRollEvent(payload)
	local eventId = payload.event_id or HttpService:GenerateGUID(false)
	if seenEventIds[eventId] then
		return eventId, nil -- idempotent
	end
	seenEventIds[eventId] = true
	table.insert(rollEventsLog, {
		event_id = eventId,
		timestamp = payload.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ"),
		player_id = payload.player_id,
		lane = payload.lane,
		pre_counters = payload.pre_counters,
		result_rarity = payload.result_rarity,
		result_item_id = payload.result_item_id,
		pity_override_used = payload.pity_override_used,
		post_counters = payload.post_counters,
		rng_table_version = payload.rng_table_version,
	})
	return eventId, nil
end

--[[
	LogEconomyTransaction(payload) -> (txId, err?)
]]
function AuditLogger.LogEconomyTransaction(payload)
	local txId = payload.tx_id or HttpService:GenerateGUID(false)
	if seenTxIds[txId] then
		return txId, nil -- idempotent
	end
	seenTxIds[txId] = true
	table.insert(economyTransactionsLog, {
		tx_id = txId,
		timestamp = payload.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ"),
		player_id = payload.player_id,
		currency = payload.currency,
		delta = payload.delta,
		balance_before = payload.balance_before,
		balance_after = payload.balance_after,
		reason_code = payload.reason_code,
		source_context = payload.source_context,
	})
	return txId, nil
end

--[[
	GetRollEventsForPlayer(playerId) -> events[]
]]
function AuditLogger.GetRollEventsForPlayer(playerId)
	local out = {}
	for _, e in ipairs(rollEventsLog) do
		if e.player_id == playerId then
			table.insert(out, e)
		end
	end
	return out
end

--[[
	GetEconomyTransactionsForPlayer(playerId) -> txs[]
]]
function AuditLogger.GetEconomyTransactionsForPlayer(playerId)
	local out = {}
	for _, t in ipairs(economyTransactionsLog) do
		if t.player_id == playerId then
			table.insert(out, t)
		end
	end
	return out
end

-- For tests: clear logs
function AuditLogger.ClearLogs()
	table.clear(rollEventsLog)
	table.clear(economyTransactionsLog)
	table.clear(seenEventIds)
	table.clear(seenTxIds)
end

return AuditLogger
