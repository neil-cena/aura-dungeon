# Day 5 Test Execution Instructions

## Prerequisites

- Roblox Studio connected via Rojo and synced with local files.
- Day 5 scripts loaded:
  - `src/shared/config/PolishConfig.lua`
  - `src/shared/types/PolishTypes.lua`
  - `src/client/controllers/DungeonController.client.lua`
  - `src/client/ui/DungeonOverlay.client.lua`
  - `src/server/tests/day5/*`

## Automated Day 5 Tests

1. Press Play in Studio.
2. In Output, capture lines from `ServerScriptService.server.tests.day5.RunAll`.
3. Copy output from `[Day5 Tests] Running...` through total summary.
4. Paste output into `day5-ux-performance-test-checklist.md` -> Evidence Summary.

## Manual Validation Procedure (Device Matrix)

Run at least three device profiles:
- low-end
- mid-tier
- high-tier

For each profile:
1. Enter landscape orientation.
2. Perform 10 dungeon action cycles (`Start/Advance/Resolve`).
3. Confirm each core button is reachable without grip shift.
4. Repeat with sound muted and verify all critical cues remain readable.
5. Record FPS samples (minimum 30 values) and compute median.
6. Record input-to-action latency samples (minimum 20 values) and compute p95.

## Target Thresholds

- low-end median FPS >= 30
- mid-tier median FPS >= 45
- input-to-action latency p95 <= 150ms
- mute-play cues readable
- graceful downgrade behavior on low-end settings

## Evidence Format

- Include full device matrix table.
- Include calculations for medians and p95.
- Include pass/fail status for each Day 5 must-pass criterion.
