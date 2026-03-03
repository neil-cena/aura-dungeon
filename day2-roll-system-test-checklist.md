# Day 2 - Roll System Test Checklist

Purpose: validate Day 2 roll-system readiness before implementation sign-off.

References:

- `odds-and-pity-spec.md`
- `data-schema-v1.md`
- `milestone-acceptance-matrix.md` (Day 2 Must Pass)

---

## Day 2 Must Pass Mapping


| Matrix Requirement                                     | Test Group                     |
| ------------------------------------------------------ | ------------------------------ |
| No client-trusted roll or pity path exists             | Group A - Authority Boundary   |
| Pity guarantees trigger correctly at threshold         | Group B - Deterministic Pity   |
| Roll outcomes are logged with sufficient audit fields  | Group C - Audit Logging        |
| Disclosure text matches configured probabilities       | Group D - Disclosure Integrity |
| Critical economy write failure in test harness <= 0.3% | Group E - Failure/Resilience   |


---

## Execution Tracker (Complete Before Re-Audit)


| Group | Scope                        | Owner | Due        | Status      |
| ----- | ---------------------------- | ----- | ---------- | ----------- |
| A     | Authority Boundary (A1-A4)   | Neila | *set date* | Not started |
| B     | Deterministic Pity (B1-B7)   | Neila | *set date* | Not started |
| C     | Audit Logging (C1-C5)        | Neila | *set date* | Not started |
| D     | Disclosure Integrity (D1-D4) | Neila | *set date* | Not started |
| E     | Failure/Resilience (E1-E4)   | Neila | *set date* | Not started |


Re-audit gate:

- Do not request re-audit until all five groups are marked `Complete` with evidence filled.

---

## Group A - Authority Boundary

Goal: confirm roll and pity cannot be decided by client input.

- A1. Client attempts to submit forced rarity (e.g., Legendary) -> server rejects and resolves from authoritative path.
- A2. Client attempts to submit custom pity counters -> server ignores and uses persisted counters.
- A3. Client attempts to spend without sufficient balance -> server rejects mutation.
- A4. Roll result source is server-side only; client receives read-only outcome payload.

Evidence notes:

- Build/version:
- Test method:
- Result summary:

Pass criteria:

- 0 successful client-side overrides.

---

## Group B - Deterministic Pity

Goal: verify exact threshold behavior from `odds-and-pity-spec.md`.

- B1. Rare+ pity: after 9 failed rolls, 10th grants Rare+.
- B2. Epic+ pity: after 49 failed rolls, 50th grants Epic+.
- B3. Legendary pity: after 249 failed rolls, 250th grants Legendary.
- B4. Lane isolation: Aura rolls do not modify Weapon counters.
- B5. Lane isolation: Weapon rolls do not modify Aura counters.
- B6. Counter reset correctness after Rare/Epic/Legendary outcomes.
- B7. Highest-tier pity precedence when multiple pity conditions are eligible.

Evidence notes:

- Test harness seed/version:
- Inputs:
- Output snapshots:

Pass criteria:

- 100% threshold tests pass; 0 lane-cross contamination.

---

## Group C - Audit Logging

Goal: verify roll and economy logs are complete and reconciliation-safe.

Required fields from schema:

- `roll_events`: event_id, timestamp, player_id, lane, pre_counters, result_rarity, result_item_id, pity_override_used, post_counters, rng_table_version
- `economy_transactions`: tx_id, timestamp, player_id, currency, delta, balance_before, balance_after, reason_code, source_context
- C1. Every roll creates one `roll_events` record.
- C2. Every spend/grant involved in rolling creates `economy_transactions` entries.
- C3. `pre_counters` and `post_counters` correctly reflect pity updates.
- C4. IDs are unique and idempotency-safe (no duplicate writes for one action).
- C5. Logs are sufficient to reconstruct final balance and pity state.

Evidence notes:

- Sample event IDs:
- Sample transaction IDs:
- Reconciliation proof:

Pass criteria:

- 100% required fields present on sampled and automated checks.

---

## Group D - Disclosure Integrity

Goal: ensure player-facing disclosure reflects actual active config.

- D1. Disclosure text appears before roll confirmation in every roll entry point.
- D2. Displayed probabilities exactly match live config table.
- D3. Displayed pity thresholds exactly match live server thresholds.
- D4. Aura and Weapon lane separation is explicitly shown in disclosure text.

Evidence notes:

- Entry points checked:
- Screenshot references:
- Config vs UI diff result:

Pass criteria:

- 100% entry-point coverage with exact config match.

---

## Group E - Failure/Resilience

Goal: validate reliability under transient failure conditions.

Using retry/backoff policy from `data-schema-v1.md`:

- attempts: 3
- backoff: 100ms, 250ms, 500ms + jitter
- E1. Inject transient datastore errors and verify retries execute as specified.
- E2. Validate non-retry behavior for validation failures.
- E3. Confirm final failure emits error event with reason + identifiers.
- E4. Measure critical economy write failure rate in harness.

Evidence notes:

- Number of write attempts:
- Retry telemetry sample:
- Failure-rate calculation:

Pass criteria:

- Critical economy write failure rate <= 0.3% in test harness.

---

## Evidence Summary (for matrix Day 2 section)

- Test cases run:
  - Group A: Run `RunAll.server.lua` in Roblox Studio; AuthorityBoundary.spec (A1-A4)
  - Group B: PityDeterminism.spec (B1-B7)
  - Group C: AuditLogging.spec (C1-C5)
  - Group D: DisclosureParity.spec (D1-D4)
  - Group E: Resilience.spec (E1-E4)
- Run instructions: See `DAY2_TEST_INSTRUCTIONS.md`
- Known issues:
  - (none if all groups pass)
  - Severity:
  - Owner:
  - Target fix date:

Day 2 provisional recommendation:

- `PASS` / `FAIL` / `PENDING` (set after RunAll output is captured)
- Rationale: (paste RunAll output)

