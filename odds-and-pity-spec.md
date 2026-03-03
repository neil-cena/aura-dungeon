# Aura Dungeon - Odds and Pity Spec (Day 1)

Purpose: define transparent probabilities and deterministic hard pity behavior for both roll lanes.

Principles:
- Server-authoritative only (no client trust).
- Publicly disclosed probabilities and pity thresholds.
- Deterministic hard pity to cap worst-case frustration.

## 1) Roll Lanes

- Aura lane (cosmetic expression): uses `Coins`.
- Weapon lane (combat lane): uses `Tokens`.

Each lane maintains independent pity counters.

---

## 2) Baseline Probability Table (V1 Default)

Use this table in both lanes initially; tune later if needed with disclosure updates.

- Common: `60.0%`
- Rare: `30.0%`
- Epic: `9.1%`
- Legendary: `0.9%`

Sum: `100.0%`

Note:
- Mythic tier can be added in future versions; omitted in V1 to reduce complexity risk.

---

## 3) Hard Pity Thresholds (Deterministic)

Counters increment on each failed roll for the target tier.

- Guaranteed Rare if no Rare+ in `10` rolls.
- Guaranteed Epic if no Epic+ in `50` rolls.
- Guaranteed Legendary if no Legendary in `250` rolls.

Resolution policy when multiple pity conditions are eligible:
- Highest-tier eligible pity takes priority.
- Lower pity counters are adjusted consistently after grant:
  - Counter for granted tier resets to `0`.
  - Lower-tier counters reset if the granted result also satisfies them.

---

## 4) Counter Rules

Per lane (`Aura`, `Weapon`) store:
- `roll_count_total`
- `since_rare_plus`
- `since_epic_plus`
- `since_legendary`

On each roll:
1. Check hard pity eligibility.
2. If eligible, grant deterministic outcome by highest active threshold.
3. Else resolve by weighted RNG table.
4. Update counters from resulting rarity.

Reset behavior:
- Rare result resets `since_rare_plus`.
- Epic result resets `since_rare_plus` and `since_epic_plus`.
- Legendary result resets all three streak counters.

---

## 5) Disclosure Text (Player-Facing Draft)

Use plain-language disclosure in roll UI:

"Drop Rates:
Common 60.0%, Rare 30.0%, Epic 9.1%, Legendary 0.9%.
Guaranteed Rare+ at 10 pulls without Rare+.
Guaranteed Epic+ at 50 pulls without Epic+.
Guaranteed Legendary at 250 pulls without Legendary.
Pity counters are tracked separately for Aura and Weapon rolls."

Placement requirements:
- Must appear before confirming a roll.
- Must be visible from every roll entry point.
- Must be updated with any live tuning before changes go live.

---

## 6) Audit and Integrity Requirements

Every roll must log:
- Timestamp
- Player ID
- Lane (`Aura`/`Weapon`)
- RNG seed/version ID
- Pre-roll pity counters
- Final rarity/result
- Pity override flag (true/false)
- Post-roll pity counters

Acceptance checks:
- 0 client-side authority for final roll result.
- 100% of roll paths produce auditable logs.
- Pity grant accuracy = 100% in automated threshold tests.

---

## 7) Test Cases (Day 1-2)

Required deterministic tests:
- 10 consecutive below-Rare outcomes -> 10th grants Rare+.
- 50 consecutive below-Epic outcomes -> 50th grants Epic+.
- 250 consecutive below-Legendary outcomes -> 250th grants Legendary.
- Verify lane isolation:
  - Aura rolls never modify Weapon pity counters.
  - Weapon rolls never modify Aura pity counters.

Edge-case tests:
- Simultaneous eligible pity states resolve to highest-tier payout.
- Counter resets are consistent after pity vs normal RNG outcomes.

