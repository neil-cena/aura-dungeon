# Day 4 Test Execution Instructions

## Prerequisites
- Roblox Studio connected via Rojo.
- Day 4 files synced to Studio.

## Automated Day 4 Tests
1. Press Play in Studio.
2. In Output, find `[Day4 Tests]` lines from `ServerScriptService.server.tests.day4.RunAll`.
3. Copy output from `Running...` to `Total: passed=X failed=Y`.
4. Paste output into `day4-dungeon-test-checklist.md` Evidence Summary.

## 20-Run Sample Procedure
1. Run 20 dungeon runs (or use controlled simulation harness).
2. Record each runtime in seconds.
3. Mark boss appeared every run (Y/N).
4. For loss runs, confirm partial reward retained.
5. Compute:
   - average runtime (target 120-180s)
   - in-window runs / 20 (target >= 80%)

## Must Pass Mapping
- Runtime target: average 2-3 min
- Boss every run: 100%
- Loss retention: partial progress preserved
- Mute readability: telegraph text visible
- Variance: >= 80% runs in 2-3 min window

