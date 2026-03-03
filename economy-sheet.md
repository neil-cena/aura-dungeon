# Aura Dungeon - Economy Sheet (Day 1)

Purpose: define currencies, sources/sinks, pacing targets, and anti-frustration controls for V1.

## 1) Currency Model

## Soft Currency A: `Coins`
- Purpose: Aura rolls (expression/cosmetic lane).
- Earned from:
  - Dungeon completion reward
  - Boss kill reward
  - First-session onboarding grant
  - Daily quest completion (later, not required for Day 1 build)
- Spent on:
  - Aura roll pulls

## Soft Currency B: `Tokens`
- Purpose: Weapon rolls (combat lane).
- Earned from:
  - Boss kill reward (primary source)
  - Milestone dungeon clears
- Spent on:
  - Weapon roll pulls

## Optional Hard Currency: `Gems` (Robux purchased)
- Purpose: convenience and expression only.
- Allowed uses:
  - QoL unlocks (inventory expansion, roll speed convenience)
  - Direct-purchase cosmetics
- Prohibited uses:
  - Direct raw stat purchases
  - Guaranteed dominance items

---

## 2) Baseline Prices and Rewards (V1 Defaults)

These are starting values for internal tests and can be tuned after 20+ observed runs.

- Aura Roll Cost: `100 Coins`
- Weapon Roll Cost: `50 Tokens`

Dungeon rewards (target 2-3 minute run):
- Completion (win): `120 Coins`, `30 Tokens`
- Boss bonus: `80 Coins`, `20 Tokens`
- Total successful run: `200 Coins`, `50 Tokens`

Loss rewards:
- Retain `25%` of earned run currency
- Minimum consolation floor: `25 Coins`, `5 Tokens`

Onboarding grants:
- First minute completion grant: `500 Coins` (enables 5 aura rolls at start)
- First boss clear milestone grant: `100 Tokens` (enables 2 weapon rolls)

---

## 3) Target Pacing

## Session 1 targets
- First aura roll within first `15s` of play.
- At least `5` aura rolls available in first session.
- First weapon roll available after first successful boss cycle or milestone grant.

## Short-session targets (30 minutes)
- Casual profile: `10-15` aura rolls, `6-10` weapon rolls.
- Mid profile: `15-25` aura rolls, `10-18` weapon rolls.
- High profile: `25+` aura rolls, `18+` weapon rolls.

## Horizon targets (readiness requirement)
- 1-day target (new player, first 60-90 min total play):
  - Aura rolls: `25-45`
  - Weapon rolls: `10-20`
  - At least one Rare+ in each lane via base odds + pity protection
- 7-day target (casual retention profile):
  - Aura rolls: `120-220`
  - Weapon rolls: `60-110`
  - At least one Epic+ expected in at least one lane without pay dependence
- 30-day target (casual-mid profile):
  - Aura rolls: `500+`
  - Weapon rolls: `220+`
  - Multiple Epic+ outcomes with deterministic pity preventing extreme droughts

## Progression fairness targets
- No profile should be hard-stalled from meaningful progression over 30 minutes.
- Loss states should still permit eventual progress (no zero-value loop traps).

---

## 4) Anti-Inflation and Sink Controls

- Primary sinks are roll costs, not punitive repairs/taxes.
- Avoid multi-layer fees that obscure true costs.
- Keep gain/cost ratio near 1 successful run ~= 2 aura rolls + 1 weapon roll.
- If inflation appears:
  - Prefer mild roll cost tuning (+5-10%) over reward nerfs that increase frustration.

---

## 5) Monetization Boundary Rules

- Paid routes may accelerate convenience, not guarantee combat dominance.
- Any paid item must be tagged as:
  - `Expression`
  - `Convenience`
  - `Enhancement` (blocked by default)
- If item tag = `Enhancement`, mark as rejected unless re-approved by explicit policy review.

---

## 6) Simulation Scenarios (Day 1 Required)

Run spreadsheet simulation for:
- Low engagement: short runs, lower win rate.
- Mid engagement: average runs, moderate win rate.
- High engagement: many runs, high win rate.

Track outputs:
- Rolls per 30 minutes by lane
- Time-to-first-rare by lane
- Fraction of sessions with zero perceived progress
- Loss recovery time (number of runs to return to normal pace)

Pass criteria:
- 0 hard-stall profiles in 30-minute simulation window.
- <= 10% sessions with "no meaningful progress" feeling.
- Loss recovery typically within 1-2 runs.

## Simulation evidence (executed)
- Source: Monte Carlo run (`5000` sessions per profile).
- Assumptions:
  - Low profile: 8-10 runs per 30m, 45% win rate
  - Mid profile: 10-13 runs per 30m, 65% win rate
  - High profile: 13-16 runs per 30m, 80% win rate
- Results summary:
  - Low: mean `15.30` aura rolls, `6.67` weapon rolls, `0.0%` hard stall, `0.0%` low-progress sessions, loss recovery mean `1.02` runs
  - Mid: mean `21.70` aura rolls, `9.85` weapon rolls, `0.0%` hard stall, `0.0%` low-progress sessions, loss recovery mean `1.02` runs
  - High: mean `29.42` aura rolls, `13.76` weapon rolls, `0.0%` hard stall, `0.0%` low-progress sessions, loss recovery mean `1.06` runs
- Artifact with full notes: `day1-simulation-notes.md`

## Catch-up plan (explicit)
- Deterministic pity:
  - Rare+ guarantee at 10 pulls without Rare+
  - Epic+ guarantee at 50 pulls without Epic+
  - Legendary guarantee at 250 pulls without Legendary
- Onboarding catch-up:
  - `500 Coins` first-minute grant
  - `100 Tokens` first boss milestone grant
- Loss protection:
  - Keep 25% run currency with minimum floor (prevents full reset frustration)
- Milestone smoothing levers (if telemetry shows bad luck streaks):
  - Temporary +10-15% token reward event
  - One-time streak breaker grant triggered by repeated failed boss clears
  - Quest-based guaranteed Rare+ reward at defined completion milestones

---

## 7) Open Risks (Initial)

- If weapon power scaling is too steep, token scarcity can feel pay-pressuring even without pay-to-win intent.
- If aura lane gets too generous while weapon lane is too strict, loop motivation may split and retention may drop.
- If run time exceeds 3 minutes consistently, rewards feel delayed and pacing breaks.

Mitigations:
- Keep token yield tightly coupled to boss completion consistency.
- Use pity and milestone grants to smooth unlucky streaks.
- Re-tune before launch from observed runtime + completion rates.

