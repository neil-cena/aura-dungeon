# Aura Dungeon - Data Schema V1 (Day 1)

Purpose: define persistent player/economy schema with auditability, rollback safety, and anti-exploit boundaries.

Design goals:
- Server-authoritative economy and roll outcomes.
- Deterministic pity storage by lane.
- Transaction history for reconciliation and rollback.

## 1) Top-Level Profile Shape

```json
{
  "schema_version": 1,
  "player_id": "string",
  "created_at": "iso8601",
  "updated_at": "iso8601",
  "currencies": {},
  "inventory": {},
  "roll_state": {},
  "progression": {},
  "settings": {},
  "compliance": {},
  "telemetry_flags": {}
}
```

---

## 2) Currency Ledger

```json
"currencies": {
  "coins": 0,
  "tokens": 0,
  "gems": 0
}
```

Rules:
- All currency mutations happen on server.
- No direct client-set values.
- Negative balances prohibited.

Recommended guardrails:
- Max-balance sanity caps per currency (configured server-side).
- Reject mutation requests outside known reason codes.

---

## 3) Inventory Model

```json
"inventory": {
  "auras": [
    { "item_id": "aura_rare_bluefire", "rarity": "Rare", "count": 1 }
  ],
  "weapons": [
    { "item_id": "weapon_epic_blade", "rarity": "Epic", "count": 1, "level": 1 }
  ],
  "equipped": {
    "aura_item_id": "aura_rare_bluefire",
    "weapon_item_id": "weapon_epic_blade"
  }
}
```

Rules:
- Item ownership checked server-side before equip.
- Duplicate handling supports count-based stacking where applicable.

---

## 4) Roll and Pity State

```json
"roll_state": {
  "aura_lane": {
    "roll_count_total": 0,
    "since_rare_plus": 0,
    "since_epic_plus": 0,
    "since_legendary": 0
  },
  "weapon_lane": {
    "roll_count_total": 0,
    "since_rare_plus": 0,
    "since_epic_plus": 0,
    "since_legendary": 0
  }
}
```

Rules:
- Lanes are isolated.
- Pity counters are updated only after authoritative roll resolution.

---

## 5) Progression Fields

```json
"progression": {
  "dungeons_completed": 0,
  "boss_kills": 0,
  "session_best_clear_time_sec": null,
  "onboarding_state": {
    "first_roll_complete": false,
    "first_rift_complete": false,
    "first_reward_claimed": false
  }
}
```

Purpose:
- Supports first-minute funnel tracking and progression milestones.

---

## 6) Compliance and Feature Gating

```json
"compliance": {
  "region_code": "unknown",
  "age_group": "unknown",
  "restricted_monetization": false,
  "last_policy_check_at": "iso8601"
}
```

Rules:
- If policy service indicates restrictions, server enforces gated flows.
- Client UI reflects restrictions but server remains source of truth.

---

## 7) Transaction and Roll Audit Logs

Use append-only records (separate store or capped history with archive):

`economy_transactions` fields:
- `tx_id`
- `timestamp`
- `player_id`
- `currency`
- `delta`
- `balance_before`
- `balance_after`
- `reason_code` (ex: `DUNGEON_WIN`, `AURA_ROLL_COST`, `BOSS_BONUS`)
- `source_context` (run_id/session_id)

`roll_events` fields:
- `event_id`
- `timestamp`
- `player_id`
- `lane`
- `pre_counters`
- `result_rarity`
- `result_item_id`
- `pity_override_used`
- `post_counters`
- `rng_table_version`

Rules:
- Event IDs must be unique and idempotency-safe.
- Logs must exist for reconciliation and exploit investigation.

---

## 8) Mutation API Contracts (Server-Only)

Define strict internal server actions:
- `grant_currency(reason_code, amount, context)`
- `spend_currency(reason_code, amount, context)`
- `execute_roll(lane, context)`
- `grant_item(item_id, reason_code, context)`
- `equip_item(slot, item_id)`

Validation requirements:
- Validate player state version before write.
- Reject stale/conflicting writes with retry.
- Apply atomic update where possible for currency + roll + inventory changes.

Retry/backoff policy (critical writes):
- Max attempts: `3`
- Backoff: exponential (`100ms`, `250ms`, `500ms`) with small jitter (`0-50ms`)
- Retry only on transient failures (timeout, throttling, temporary datastore unavailability)
- Do not retry on validation failures (insufficient balance, invalid reason code, ownership mismatch)
- If all retries fail:
  - Return explicit failure to caller
  - Emit error event with `reason_code`, `tx_id/event_id`, and last known state version
  - Queue reconciliation marker for async recovery check

---

## 9) Versioning and Migration

- `schema_version` is mandatory.
- Use explicit migration functions for each version bump:
  - v1 -> v2
  - v2 -> v3
- Never silently infer missing fields in critical economy paths.
- Missing required fields trigger safe defaults + migration + audit entry.

---

## 10) Rollback and Recovery Plan (Minimum)

Required:
- Daily snapshot backup for profile store.
- Ability to replay transaction logs for currency reconciliation.
- Hotfix switch to disable rolling temporarily if integrity issue detected.
- Incident notes template for any economy correction.

Recovery acceptance:
- Can reconstruct a player's currency and pity state from logs + snapshot.
- Can identify and reverse duplicated or fraudulent grants by tx/event ID.

