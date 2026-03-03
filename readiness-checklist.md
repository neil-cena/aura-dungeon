# Aura Dungeon - Project Readiness Checklist

Use this checklist before writing production code.  
Outcome should be one of: `GO`, `GO WITH RISKS`, `NO-GO`.

## Default V1 Targets (Tune After First Playtest Week)

Use these as initial thresholds if none are already set:

- Retention:
  - D1 New User Retention: `>= 30%`
  - D7 New User Retention: `>= 10%`
- Onboarding:
  - First-minute loop completion (spawn -> first roll -> first combat -> reward): `>= 70%`
  - Time to first interaction: `<= 5s`
  - Time to first combat action: `<= 50s`
- Stability:
  - Crash-free sessions: `>= 99.0%`
  - Critical economy/data write failure rate: `<= 0.3%`
- Performance:
  - Low-end mobile median FPS during combat: `>= 30`
  - Mid-tier mobile median FPS during combat: `>= 45`
  - Input-to-action latency for core buttons (p95): `<= 150ms`
- Economy fairness:
  - No simulated player profile is hard-stalled for progression in a 30-minute session.
  - Loss state preserves meaningful progress in 100% of tested dungeon runs.
- Trust/compliance:
  - Odds + pity disclosures are visible before rolling in 100% of tested entry points.
  - 0 unresolved compliance blockers for age/region restricted flows.

Gate:

- `NO-GO` if fewer than 80% of these baseline targets are met in internal testing.

## 1) Vision and Scope Lock

- MVP one-pager exists with in-scope and out-of-scope items.
- `pillars-v2.md` is accepted as the design source of truth.
- Success metrics are defined (D1, D7, loop completion, crash rate, conversion).
- Team agrees what "polish" means for v1 (UI feel, VFX clarity, stability target).

Gate:

- `NO-GO` if scope is still changing daily.

## 2) Economy and Progression Readiness

- Economy sheet includes all currencies, sources, sinks, and expected rates.
- Drop tables and hard pity thresholds are defined and approved.
- Progression targets are set for 1-session, 1-day, 7-day, and 30-day horizons.
- Spreadsheet simulation has been run for at least low/mid/high engagement players.
- Catch-up plan for unlucky players is specified.

Gate:

- `NO-GO` if progression fairness cannot be demonstrated in simulation.

## 3) Ethics, Trust, and Compliance

- Public probability disclosure format is finalized.
- Hard pity disclosure text is finalized and plain-language reviewed.
- Monetization catalog is tagged by type: `Expression`, `Convenience`, `Enhancement`.
- Anything tagged `Enhancement` is blocked or explicitly reviewed and rejected.
- Region/age policy behavior is defined (including disabled flows).
- Store copy avoids manipulative language and deceptive framing.

Gate:

- `NO-GO` if any monetized item creates insurmountable power advantage.

## 4) UX and Gameplay Clarity

- First 60-second storyboard is complete and timestamped.
- Core loop transitions are mapped (spawn -> roll -> dungeon -> reward -> hub).
- Mobile target sizes and thumb zones are defined for all core controls.
- Mute-play readability is verified for telegraphs and combat feedback.
- Failure states and recovery flows are designed (no full frustration resets).

Gate:

- `NO-GO` if first-minute loop cannot be completed without instructions.

## 5) Technical and Data Foundations

- Data model is defined (profile, inventory, pity counters, currency ledgers).
- Data migration/versioning plan exists.
- Server-authoritative boundaries are defined (no client trust for rolls/pity/economy).
- Anti-exploit strategy is drafted for economy and combat inputs.
- Error handling/retry patterns are specified for critical data writes.

Gate:

- `NO-GO` if there is no persistence rollback/recovery strategy.

## 6) Performance and Platform Readiness

- Performance budgets are set (FPS floor, memory ceiling, particle budgets).
- Low-end fallback modes are defined.
- Battery-friendly mode behavior is defined.
- Network assumptions and degraded experience handling are documented.

Gate:

- `NO-GO` if low-end mode removes critical gameplay readability.

## 7) Analytics and Decision Instrumentation

- Event taxonomy exists with names, payload schema, and owners.
- Key funnels are instrumented on paper: onboarding, loop, monetization, churn.
- Dashboard definitions are drafted (daily and release-week views).
- "Red alert" thresholds are defined (retention drop, crash spike, economy exploit).

Gate:

- `NO-GO` if launch KPIs cannot be measured from day one.

## 8) QA and Release Process

- Test plan includes unit, integration, playtest scripts, and exploit cases.
- Release blockers are defined (what must pass before shipping).
- Rollback plan exists for economy/config regressions.
- Hotfix workflow and communication template are prepared.

Gate:

- `NO-GO` if rollback and hotfix procedures are not rehearsed.

## 9) Team Operating Rhythm

- Single owner is assigned for each domain: Economy, Combat, UX, Data, QA.
- Daily risk log process is active.
- Decision log template exists for irreversible choices.
- External dependencies and deadlines are tracked.

Gate:

- `NO-GO` if responsibilities are ambiguous.

---

## Readiness Scoring

Scoring:

- 2 points = complete and reviewed
- 1 point = drafted but not validated
- 0 points = missing

Status:

- `GO`: >= 85% score and no `NO-GO` gates triggered.
- `GO WITH RISKS`: 70-84% score and max 2 open high-risk items with owners/dates.
- `NO-GO`: < 70% score or any critical gate triggered.

Risk severity guidance:

- `Critical`: trust/compliance/economy integrity risk that can harm players or platform standing.
- `High`: likely to damage retention, fairness, or core-loop clarity.
- `Medium`: noticeable quality issue with workaround.
- `Low`: polish issue with minimal gameplay impact.

## Daily Standup RYG Scorecard (Template)

Legend:
- `Green`: on target / no blocker
- `Yellow`: at risk / mitigation active
- `Red`: off target / release blocker

| Area | Metric | Target | Current | RYG | Owner | Mitigation / Next Action |
|---|---|---:|---:|---|---|---|
| Onboarding | First interaction time | <= 5s |  |  |  |  |
| Onboarding | First combat action time | <= 50s |  |  |  |  |
| Onboarding | First-minute loop completion | >= 70% |  |  |  |  |
| Performance | Low-end combat median FPS | >= 30 |  |  |  |  |
| Performance | Mid-tier combat median FPS | >= 45 |  |  |  |  |
| Performance | Core input latency (p95) | <= 150ms |  |  |  |  |
| Stability | Crash-free sessions | >= 99.0% |  |  |  |  |
| Economy | Critical data write failure rate | <= 0.3% |  |  |  |  |
| Fairness | Hard progression stall cases | 0 |  |  |  |  |
| Ethics/Trust | Odds + pity disclosure coverage | 100% |  |  |  |  |
| Compliance | Age/region gating failures | 0 |  |  |  |  |
| Retention Proxy | D1 forecast (internal proxy) | >= 30% |  |  |  |  |

Standup summary:
- Total `Red`:
- Total `Yellow`:
- Ship risk today (`Low`/`Medium`/`High`):
- Go/No-Go recommendation:

## 5-Minute Update Workflow

1. Pull latest numbers for the 12 scorecard metrics.
2. Fill `Current` values only (do not edit targets during standup).
3. Set `RYG` per row:
   - `Green`: meets target
   - `Yellow`: within 10% of target or unstable trend
   - `Red`: misses target by >10% or has active blocker
4. For every `Yellow`/`Red`, add owner + one mitigation action with due date.
5. Complete standup summary and state one recommendation: `GO`, `GO WITH RISKS`, or `NO-GO`.

Cadence:
- Update daily before standup.
- Re-baseline targets only in a dedicated weekly review, never ad hoc.

## Sign-Off

- Product Owner:
- Design Lead:
- Economy Owner:
- Tech Lead:
- QA Owner:
- Date:

