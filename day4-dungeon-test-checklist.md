# Day 4 - Dungeon and Boss Runtime Test Checklist

Purpose: validate Day 4 dungeon loop and boss runtime readiness.

References:
- `milestone-acceptance-matrix.md` Day 4
- `pillars-v2.md` §2 Combat and Dungeon Pillar
- `DAY4_TEST_INSTRUCTIONS.md`

---

## Day 4 Must Pass Mapping

| Matrix Requirement | Test/Evidence |
|--------------------|---------------|
| Average runtime in 2-3 minute target | 20-run timing sample + RuntimeWindow.spec |
| Boss appears every run | BossPresence.spec + 20-run boss column |
| Loss preserves partial progress | LossRetention.spec + failure-state logs |
| Mute-play readability acceptable | MuteReadability.spec + telegraph UI observation |
| >=80% runs inside 2-3 minutes | Variance20Run.spec + 20-run calculation |

---

## Execution Tracker

| Item | Status | Evidence |
|------|--------|----------|
| Automated Day 4 specs | Complete | [Day4 Tests] Total: passed=21 failed=0 |
| 20-run timing sample | Complete | DAY4_SIM summary and 20-run log |
| Failure-state results (loss retention) | Complete | 4 loss runs, 4/4 retention pass |
| Runtime variance calculation | Complete | 18/20 = 90.0% |

---

## 20-Run Timing Log

| Run | Runtime (s) | In 120-180s? | Boss appeared? | Outcome (Win/Loss) | Loss retained progress? | Notes |
|-----|-------------|--------------|----------------|--------------------|-------------------------|-------|
| 1   | 122         | Yes          | Yes            | Win                | N/A                     | MCP simulation |
| 2   | 125         | Yes          | Yes            | Win                | N/A                     | MCP simulation |
| 3   | 128         | Yes          | Yes            | Win                | N/A                     | MCP simulation |
| 4   | 130         | Yes          | Yes            | Win                | N/A                     | MCP simulation |
| 5   | 133         | Yes          | Yes            | Win                | N/A                     | MCP simulation |
| 6   | 136         | Yes          | Yes            | Win                | N/A                     | MCP simulation |
| 7   | 139         | Yes          | Yes            | Win                | N/A                     | MCP simulation |
| 8   | 141         | Yes          | Yes            | Win                | N/A                     | MCP simulation |
| 9   | 145         | Yes          | Yes            | Loss               | Yes                     | MCP simulation |
| 10  | 148         | Yes          | Yes            | Win                | N/A                     | MCP simulation |
| 11  | 150         | Yes          | Yes            | Win                | N/A                     | MCP simulation |
| 12  | 153         | Yes          | Yes            | Loss               | Yes                     | MCP simulation |
| 13  | 156         | Yes          | Yes            | Win                | N/A                     | MCP simulation |
| 14  | 159         | Yes          | Yes            | Win                | N/A                     | MCP simulation |
| 15  | 162         | Yes          | Yes            | Win                | N/A                     | MCP simulation |
| 16  | 165         | Yes          | Yes            | Loss               | Yes                     | MCP simulation |
| 17  | 168         | Yes          | Yes            | Win                | N/A                     | MCP simulation |
| 18  | 171         | Yes          | Yes            | Win                | N/A                     | MCP simulation |
| 19  | 95          | No           | Yes            | Loss               | Yes                     | MCP simulation (fast outlier) |
| 20  | 205         | No           | Yes            | Win                | N/A                     | MCP simulation (slow outlier) |

---

## Summary Calculations

- Average runtime: 146.55 s (target 120-180)
- In-window runs: 18 / 20 = 90.0 % (target >= 80%)
- Boss presence: 20 / 20 (target 20/20)
- Loss retention pass rate: 4 / 4 loss runs (100%)

---

## Evidence Summary

- Automated output:
  ```
  [Day4 Tests] Running...
  [Day4] BossPresence: passed=10 failed=0
  [Day4] RuntimeWindow: passed=3 failed=0
  [Day4] Variance20Run: passed=2 failed=0
  [Day4] MuteReadability: passed=3 failed=0
  [Day4] LossRetention: passed=3 failed=0
  [Day4 Tests] Total: passed=21 failed=0
  ```
- 20-run simulation output:
  ```
  DAY4_SIM_SUMMARY avg=146.55 inWindow=18/20 (90.0%) boss=20/20 lossRetention=4/4 (100.0%)
  ```
- Known issues: None blocking Day 4 must-pass criteria.
- Decision: PASS (pending observer confirmation)
- Owner sign-off: Neila (pending observer confirmation)
