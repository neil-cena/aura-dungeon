# Day 3 Test Execution Instructions

## Prerequisites
- Roblox Studio with project synced (Rojo)
- Day 3 modules under `ServerScriptService.server` (domain, network, tests)

## Running Automated Tests
1. Open the place in Roblox Studio.
2. Press **Play**.
3. In Output, look for `[Day3 Tests]` lines:
   - OnboardingTiming, OnboardingAuthority, RiftReward
   - Total: passed=X failed=Y
4. Copy output from `[Day3 Tests] Running...` through `Total: passed=X failed=Y` into `day3-onboarding-test-checklist.md`.

## Fresh-User 10-Run Protocol
For Must Pass "first-minute loop completion >= 70%":

1. **Reset between runs:** Use ProfileStore.ClearCache() or a fresh test place/player to simulate new user.
2. **Manual run:** Spawn, tap Start, tap Roll, tap Enter Rift, tap Attack, tap Complete.
3. **Record per run:**
   - Time to first interaction (s)
   - Time to first combat (s)
   - Reward by 60s? (Y/N)
   - Loop complete within 60s? (Y/N)
4. **Compute:** completed_runs / 10. Must be >= 0.7 (7/10).
5. **Document drop-off points** where users hesitated or quit.

## Test Harness Location
- `ServerScriptService.server.tests.day3.RunAll` (runs on server start)
- Specs: OnboardingTiming.spec, OnboardingAuthority.spec, RiftReward.spec
