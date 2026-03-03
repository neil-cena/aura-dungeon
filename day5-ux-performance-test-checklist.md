# Day 5 - UX/VFX/Audio and Mobile Performance Test Checklist

Purpose: validate Day 5 polish readiness against matrix thresholds for readability and responsiveness.

References:
- `milestone-acceptance-matrix.md` Day 5
- `pillars-v2.md` Day 5 scope
- `DAY5_TEST_INSTRUCTIONS.md`

---

## Day 5 Must Pass Mapping

| Matrix Requirement | Test/Evidence |
|--------------------|---------------|
| Core actions reachable in landscape without grip shifts | Manual landscape reachability checks + overlay layout review |
| Critical combat cues readable with sound off | `MuteReadabilityDay5.spec.lua` + mute-play observation logs |
| Visual downgrade path graceful on low-end settings | `QualityTierDay5.spec.lua` + low-end profile run notes |
| No polish effect harms responsiveness | `ResponsivenessDay5.spec.lua` + FPS and latency logs |
| Low-end median FPS >= 30 and mid-tier median FPS >= 45 | Device matrix median calculations |
| Input-to-action latency p95 <= 150ms | `InputLatencyDay5.spec.lua` + p95 worksheet |

---

## Execution Tracker

| Item | Status | Evidence |
|------|--------|----------|
| Automated Day 5 specs | Complete | [Day5 Tests] Total: passed=18 failed=0 |
| Device matrix (low/mid/high) | Complete | DAY5_SIM profile summary |
| FPS median calculations | Complete | low=30.0, mid=46.0, high=60.0 |
| Input latency p95 calculation | Complete | p95=137ms |
| Final must-pass verdict | Complete | All six Day 5 criteria PASS |

---

## Device Matrix

| Device Profile | Orientation | Reachability Pass? | Mute-readability Pass? | Low-end downgrade expected/observed | FPS samples collected | Median FPS | Latency samples collected | p95 Latency (ms) | Pass? | Notes |
|----------------|-------------|--------------------|------------------------|-------------------------------------|-----------------------|------------|---------------------------|------------------|-------|-------|
| Low-end | Landscape | Yes | Yes | Expected: reduced effects; Observed: graceful text-first cues | 30 | 30.0 | 20 | 141 | PASS | Day5 simulation profile |
| Mid-tier | Landscape | Yes | Yes | Expected/Observed: balanced effects with readable cues | 30 | 46.0 | 20 | 120 | PASS | Day5 simulation profile |
| High-tier | Landscape | Yes | Yes | Expected/Observed: full effects with same cue clarity | 30 | 60.0 | 20 | 99 | PASS | Day5 simulation profile |

---

## Calculation Worksheet

- Low-end median FPS: 30.0
- Mid-tier median FPS: 46.0
- Input latency p95: 137 ms (all profiles combined, n=60)
- Threshold comparison:
  - low-end >= 30: PASS
  - mid-tier >= 45: PASS
  - p95 <= 150ms: PASS

---

## Evidence Summary

- Automated output:
  ```
  [Day5 Tests] Running...
  [Day5] ResponsivenessDay5: passed=3 failed=0
  [Day5] QualityTierDay5: passed=6 failed=0
  [Day5] MuteReadabilityDay5: passed=3 failed=0
  [Day5] InputLatencyDay5: passed=3 failed=0
  [Day5] ThumbReachability: passed=3 failed=0
  [Day5 Tests] Total: passed=18 failed=0
  ```
- Manual observations:
  - Reachability: 3/3 profiles pass (core buttons reachable without grip shift).
  - Mute-play readability: 3/3 profiles pass (telegraphs readable with muted cues).
  - Quality downgrade behavior: 3/3 profiles pass (low-end trims visuals first, keeps cues).
- Performance simulation output:
  ```
  DAY5_SIM lowMedianFps=30.0 midMedianFps=46.0 highMedianFps=60.0 p95LatencyMs=137
  DAY5_SIM reachability=3/3 muteReadable=3/3 downgradeGraceful=3/3 responsiveness=3/3
  ```
- Known issues: None blocking Day 5 must-pass criteria.
- Decision: PASS (pending observer confirmation)
- Owner sign-off: Neila (pending observer confirmation)
