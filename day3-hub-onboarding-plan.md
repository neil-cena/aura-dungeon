# Day 3 - Hub and Onboarding (First 60 Seconds)

**Goal:** Player spawns in a social hub, does a first roll within 5s, enters a beginner rift, gets a meaningful reward within 60s, and can infer the loop without tutorial walls.

References: `pillars-v2.md` §1.2 First 60 Seconds, `milestone-acceptance-matrix.md` Day 3.

---

## Deliverables

| # | Deliverable | Notes |
|---|-------------|--------|
| 1 | **Social hub baseline** | Spawn point, simple environment, other players visible (or placeholder). No dead time. |
| 2 | **First-roll onboarding flow** | One scripted “first roll” (flashy, low-power outcome). Uses existing RollService + disclosure; entry point is obvious and within 5s. |
| 3 | **Beginner rift entry and return** | Entry to a short “beginner rift” (minimal dungeon), complete or exit, return to hub with currency/reward. |

---

## Must Pass (Evidence Required)

| # | Criterion | How to evidence |
|---|-----------|------------------|
| 1 | First interaction within **5 seconds** | 10 fresh runs; record time to first meaningful action (e.g. first roll or first button). |
| 2 | First combat action within **30–50 seconds** | 10 runs; record time to first combat (e.g. first hit / ability). |
| 3 | Meaningful reward within **60 seconds** | 10 runs; confirm reward (currency/item) before 60s. |
| 4 | Loop inferable without tutorial wall text | Design review + 10 runs; no mandatory tutorial text; flow teaches “roll → rift → reward → hub”. |
| 5 | First-minute loop completion **≥ 70%** | Of 10 fresh runs, ≥ 7 complete: spawn → first roll → first combat → reward within 60s. |

---

## Evidence to Capture

- **10 recorded fresh-user runs:** timestamps for first interaction, first combat, first reward; completion (Y/N) within 60s.
- **Observed drop-off points:** where players hesitated, got stuck, or quit (if any).

---

## Suggested Implementation Order

1. **Hub**
   - Place/spawn in a simple hub (Part or existing map).
   - Spawn character; ensure no long intro sequence (first interaction possible in &lt; 5s).

2. **First-roll flow**
   - Single prominent UI or proximity prompt: “Roll” / “First roll” that fires existing roll (e.g. Aura lane).
   - Reuse `RollController` + disclosure; optional one-time “first roll” reward or fixed outcome for onboarding.

3. **Beginner rift**
   - Minimal “rift” instance or area: enter (teleport/door), simple combat or “complete” trigger, then teleport back to hub.
   - Grant currency or item on rift completion so “meaningful reward within 60s” is achievable.

4. **Timing and tuning**
   - Measure and tune so first interaction &lt; 5s, first combat 30–50s, reward &lt; 60s.
   - Run 10 test runs and fill evidence table; fix drop-off points if completion &lt; 70%.

---

## Day 3 Test Run Log (template)

| Run | First interaction (s) | First combat (s) | Reward by 60s? | Loop complete (Y/N) | Notes |
|-----|------------------------|------------------|----------------|---------------------|-------|
| 1   |                       |                  |                |                     |       |
| 2   |                       |                  |                |                     |       |
| …   |                       |                  |                |                     |       |
| 10  |                       |                  |                |                     |       |

**First-minute completion rate:** _____ / 10 = _____ % (target ≥ 70%).

---

## Sign-off

- Decision: `PASS` / `FAIL`
- Owner sign-off: _____________________
