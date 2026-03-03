# Day 2 Test Execution Instructions

## Prerequisites
- Roblox Studio with project synced (e.g. via Rojo)
- Or manually place scripts in the correct hierarchy

## Running Tests
1. Open the place in Roblox Studio
2. Ensure `ServerScriptService` contains:
   - `domain/` (PityEngine, RngEngine, RollService, AuditLogger)
   - `persistence/` (ProfileStore)
   - `network/` (Remotes, RollController)
   - `tests/day2/` (AuthorityBoundary, PityDeterminism, AuditLogging, DisclosureParity, Resilience, RunAll)
3. Run the game (Play button)
4. In the Output window, look for `[Day2 Tests]` lines
5. `RunAll.server.lua` runs on server start and prints: passed/failed per group

## Evidence to Record
- Copy the Output from `[Day2 Tests] Running...` through `Total: passed=X failed=Y`
- Paste into `day2-roll-system-test-checklist.md` Evidence Summary
- Update Execution Tracker status to `Complete` for each group with all passed
- Calculate critical economy write failure rate: (failed writes / total attempts) from Group E

## Manual Group A (Authority) Verification
- Use a client script to fire `RequestRoll:FireServer({ lane = "Aura", rarity = "Legendary" })`
- Confirm server rejects and client receives `success = false, err = "invalid_request"`
- Repeat for payload with `since_rare_plus = 9` -> should reject
- Valid `{ lane = "Aura" }` should succeed
