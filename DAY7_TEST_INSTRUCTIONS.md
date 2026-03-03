# Day 7 Test Execution Instructions

## Prerequisites

- Rojo sync active.
- Day 7 compliance remotes/service and tests available.
- Existing disclosure UI active (`RollDisclosure.client.lua`).

## Automated Day 7 Tests

1. Start Play in Roblox Studio.
2. Execute `ServerScriptService.server.tests.day7.RunAll`.
3. Capture output from `[Day7 Tests] Running...` to total summary.
4. Paste output into `day7-release-readiness-checklist.md`.

## Compliance Validation

1. Evaluate compliance states (allowed/restricted) via Day 7 checks.
2. Confirm restricted flows are blocked before purchase interaction.
3. Record each case in `day7-compliance-test-notes.md`.

## Disclosure Coverage Validation

1. Enumerate all roll entry points.
2. For each entry point, verify odds/pity disclosure appears before roll confirmation.
3. Verify displayed values match `RollConfig` values.
4. Record pass/fail and coverage percentage in checklist.

## Launch Dry-Run

1. Simulate rollback scenario.
2. Execute rollback steps and verify smoke checks.
3. Simulate hotfix and rerun smoke checks.
4. Log timings and outcomes in `day7-launch-dry-run-output.md`.

## RC Stability Metric

1. Record release-candidate session sample count.
2. Record crash count.
3. Compute crash-free percentage:
   - `(sessions - crash_sessions) / sessions * 100`
4. Target: `>= 99.0%`.
