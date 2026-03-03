# Day 1 Simulation Notes

Purpose: provide evidence for Day 1 economy pass criteria in `milestone-acceptance-matrix.md`.

## Setup
- Method: Monte Carlo simulation
- Sessions per profile: `5000`
- Economy defaults used:
  - Aura roll cost: `100 Coins`
  - Weapon roll cost: `50 Tokens`
  - Win reward per run: `200 Coins`, `50 Tokens`
  - Loss reward per run: `50 Coins`, `12 Tokens` (25% retained baseline)
  - Onboarding grants: `500 Coins`, `100 Tokens`

Profiles:
- Low: 8-10 runs / 30 min, 45% win rate
- Mid: 10-13 runs / 30 min, 65% win rate
- High: 13-16 runs / 30 min, 80% win rate

## Results

Low:
- Aura rolls / 30m: mean `15.30`, p50 `15`
- Weapon rolls / 30m: mean `6.67`, p50 `7`
- Hard-stall sessions: `0 (0.0%)`
- No meaningful progress sessions (<3 total rolls): `0 (0.0%)`
- Time to first Rare: mean `4.08` min, p95 `10.50` min
- Loss recovery: mean `1.02` runs

Mid:
- Aura rolls / 30m: mean `21.70`, p50 `22`
- Weapon rolls / 30m: mean `9.85`, p50 `10`
- Hard-stall sessions: `0 (0.0%)`
- No meaningful progress sessions (<3 total rolls): `0 (0.0%)`
- Time to first Rare: mean `3.29` min, p95 `8.75` min
- Loss recovery: mean `1.02` runs

High:
- Aura rolls / 30m: mean `29.42`, p50 `29`
- Weapon rolls / 30m: mean `13.76`, p50 `14`
- Hard-stall sessions: `0 (0.0%)`
- No meaningful progress sessions (<3 total rolls): `0 (0.0%)`
- Time to first Rare: mean `2.56` min, p95 `6.56` min
- Loss recovery: mean `1.06` runs

## Pass/Fail Against Day 1 Criteria
- 0 hard-stall profiles in 30-minute window: `PASS`
- <=10% sessions with no meaningful progress: `PASS`
- Loss recovery in 1-2 runs: `PASS`

## Notes
- These are pre-implementation model checks and should be revalidated with live playtest telemetry.
- Any reward/price change requires rerunning this simulation and updating this file.

