# Aura Dungeon - Milestone Acceptance Matrix

This matrix operationalizes the 7-day plan in `pillars-v2.md`.  
Each day must end with a playable increment and a pass/fail decision.

## Rules

- A day is `PASS` only when all `Must Pass` checks pass.
- Any Trust/Ethics/Compliance failure is an automatic `FAIL`.
- Open risks must have owner + date before next-day start.
- Use these sample sizes unless a larger test is available:
  - Onboarding tests: `>= 10` fresh runs
  - Dungeon runtime tests: `>= 20` runs
  - Device performance tests: `>= 3` devices (low/mid/high)
  - Compliance + store flow checks: `100%` of purchasable entry points

---

## Day 1 - Economy, Odds, Data Model

Deliverables:

- Economy design sheet (currencies, sources, sinks, pacing targets).
- Probability tables and hard pity thresholds.
- Data schema draft (profile, inventory, pity, transactions).

Must Pass:

- Odds and pity tables are explicit and human-readable.
- Progression simulation runs for low/mid/high engagement profiles.
- No pay-to-win enhancement item appears in catalog draft.
- Data schema covers rollback-safe transaction history.
- Simulation shows no hard progression stall within a 30-minute session for any profile.

Evidence:

- Economy sheet link/path: `economy-sheet.md`
- Simulation screenshots/notes: `day1-simulation-notes.md`
- Schema doc link/path: `data-schema-v1.md`
- Odds/pity spec link/path: `odds-and-pity-spec.md`

Decision: `PASS`  
Owner sign-off: `Neila (observer re-audit approved, 2026-03-03)`

---

## Day 2 - Roll System and Server Authority

Deliverables:

- Server-authoritative roll logic.
- Hard pity counter logic.
- Probability disclosure draft UI text.

Must Pass:

- No client-trusted roll or pity path exists.
- Pity guarantees trigger correctly at threshold.
- Roll outcomes are logged with sufficient audit fields.
- Disclosure text matches configured probabilities.
- Critical economy write failure in test harness is <= 0.3%.

Evidence:

- Test cases run: `day2-roll-system-test-checklist.md`
- Known issues: `TBD during Day 2 execution`

Decision: `PASS` / `FAIL`  
Owner sign-off:

---

## Day 3 - Hub and Onboarding (First 60 Seconds)

Deliverables:

- Social hub baseline.
- First-roll onboarding flow.
- Beginner rift entry and return path to hub.

Must Pass:

- First interaction occurs within 5 seconds.
- First combat action occurs within 30-50 seconds.
- Player receives meaningful reward within 60 seconds.
- Loop explanation can be inferred without tutorial wall text.
- First-minute loop completion is >= 70% across fresh test runs.

Evidence:

- 10 recorded fresh-user runs:
- Observed drop-off points:

Decision: `PASS` / `FAIL`  
Owner sign-off:

---

## Day 4 - Dungeon Loop and Boss Runtime

Deliverables:

- Dungeon generation/entry flow.
- Combat core and enemy telegraphs.
- Boss phase and rewards.

Must Pass:

- Average run time remains in 2-3 minute target.
- Boss appears in every run.
- Loss state preserves partial progress.
- Mute-play readability is acceptable.
- Runtime variance is controlled (at least 80% of runs complete inside 2-3 minutes).

Evidence:

- 20-run timing sample:
- Failure-state results:

Decision: `PASS` / `FAIL`  
Owner sign-off:

---

## Day 5 - UX/VFX/Audio Polish and Mobile Readability

Deliverables:

- Combat feedback polish (readable and responsive).
- UI interaction polish for thumb-first use.
- Performance-aware VFX/audio settings.

Must Pass:

- Core actions are reachable in landscape without grip shifts.
- Critical combat cues remain readable with sound off.
- Visual downgrade path is graceful on low-end settings.
- No polish effect harms responsiveness.
- Low-end combat median FPS is >= 30 and mid-tier combat median FPS is >= 45.
- Input-to-action latency (p95) for core buttons is <= 150ms.

Evidence:

- Device test matrix:
- FPS/memory snapshots:

Decision: `PASS` / `FAIL`  
Owner sign-off:

---

## Day 6 - Playtest, Exploit Mitigation, Balance

Deliverables:

- Structured playtest results.
- Exploit test report.
- Balance adjustments based on telemetry/playtests.

Must Pass:

- No critical economy exploit remains open.
- No critical progression blocker remains open.
- Retention risk items have mitigation owner/date.
- Config changes are versioned and reversible.
- All high-severity risks have mitigation date <= 7 days from discovery.

Evidence:

- Playtest report:
- Exploit findings:
- Balance changelog:

Decision: `PASS` / `FAIL`  
Owner sign-off:

---

## Day 7 - Monetization, Compliance, Launch Readiness

Deliverables:

- Approved monetization catalog integration.
- Compliance gating behavior.
- Launch and rollback checklists.

Must Pass:

- Every paid item is tagged and approved as `Expression` or `Convenience`.
- No paid item grants insurmountable combat advantage.
- Region/age restricted flows are properly gated.
- Probabilities and pity disclosures are visible and accurate.
- Rollback + hotfix procedure is validated.
- Disclosure checks pass in 100% of roll entry points.
- Crash-free sessions in release candidate test window are >= 99.0%.

Evidence:

- Monetization review sheet:
- Compliance test notes:
- Launch dry-run output:

Decision: `PASS` / `FAIL`  
Owner sign-off:

---

## Release Go/No-Go Summary

Required for `GO`:

- All 7 days are `PASS`.
- No open critical Trust/Ethics/Compliance risk.
- Analytics and alerting are live for day-one monitoring.
- D1 forecast from internal proxy signals is >= 30% (or explicit mitigation plan exists).

Final decision:

- `GO`
- `GO WITH RISKS` (list explicitly)
- `NO-GO`

Risk register snapshot:

- Risk:
- Severity:
- Owner:
- Mitigation date:

---

## Release-Week RYG Dashboard (Template)

Use one row per day to keep decisions objective.


| Day   | Scope Status | Quality Status | Trust/Compliance Status | Key Metric Snapshot               | RYG | Decision    |
| ----- | ------------ | -------------- | ----------------------- | --------------------------------- | --- | ----------- |
| Day 1 |              |                |                         | Economy sim pass rate:            |     | PASS / FAIL |
| Day 2 |              |                |                         | Pity trigger accuracy:            |     | PASS / FAIL |
| Day 3 |              |                |                         | First-minute loop completion:     |     | PASS / FAIL |
| Day 4 |              |                |                         | % runs inside 2-3 min:            |     | PASS / FAIL |
| Day 5 |              |                |                         | Low-end FPS / p95 input latency:  |     | PASS / FAIL |
| Day 6 |              |                |                         | Open critical exploit count:      |     | PASS / FAIL |
| Day 7 |              |                |                         | Disclosure coverage / crash-free: |     | PASS / FAIL |


Dashboard legend:

- `Green`: pass target, no blocker
- `Yellow`: miss risk, mitigation in progress
- `Red`: blocker, cannot promote build

Final release checkpoint:

- `GO` if all days are `PASS` and no critical red remains.
- `GO WITH RISKS` only with explicit owner/date for each yellow risk.
- `NO-GO` if any trust/compliance/economy integrity red remains open.

## 5-Minute Daily Matrix Workflow

1. Mark yesterday's day-row `PASS`/`FAIL` from evidence, not opinion.
2. Update `Key Metric Snapshot` with one number that best represents that day.
3. Set `RYG`:
  - `Green`: all must-pass checks satisfied
  - `Yellow`: exactly one non-critical check at risk with mitigation active
  - `Red`: any critical failure or multiple unresolved must-pass misses
4. If `Yellow`/`Red`, write owner + mitigation date in risk register.
5. Confirm promotion rule:
  - `Green` -> promote build
  - `Yellow` -> conditional promote with explicit guardrails
  - `Red` -> do not promote

Guardrail:

- No team may override a `Red` trust/compliance/economy-integrity status without formal `NO-GO` review.

