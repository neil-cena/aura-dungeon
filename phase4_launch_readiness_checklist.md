# Phase 4 Launch Readiness Checklist

Use this after all code-side Phase 4 tasks are merged.

## 1) Regression Suite

- [x] Run Day 2-7 server test specs with clean cache state
- [x] Verify no regressions in roll/pity, onboarding, dungeon loop, compliance
- [ ] Verify shop and battle pass flows with restricted and unrestricted compliance profiles
- Evidence (2026-03-03, Studio MCP): Day2=24 pass, Day3=11 pass, Day4=21 pass, Day5=18 pass, Day7=14 pass, Total=88 pass / 0 fail / 0 errors

## 2) Multiplayer Verification

- [ ] 2-player party flow: create/invite/accept/leave/disband
- [ ] Party run starts from leader only
- [ ] Shared wave progression and completion rewards are consistent
- [ ] Party luck bonus observed over repeated roll samples

## 3) Persistence Verification

- [ ] Confirm profile save on leave and server shutdown
- [ ] Confirm autosave interval writes during long sessions
- [ ] Confirm session lock rejects duplicate concurrent session load
- [ ] Confirm default profile migration fills new fields on older profiles

## 4) Performance & UX

- [ ] Mobile emulation pass: thumb-reach controls and readable cues
- [ ] Low tier quality: particles reduced, shadows off, UI remains legible
- [ ] Mid/high tiers: no major frame hitching in combat and hub

## 5) Exploit & Authority Checks

- [x] Combat distance/rate checks enforced server-side
- [x] Dungeon phase completion cannot be spoofed by non-leader party members
- [x] Shop and battle pass claim routes are rate-limited and validated

## 6) Publish Readiness

- [ ] Game icon + thumbnails uploaded
- [ ] Experience description updated
- [ ] Creator dashboard social/community links set
- [ ] Final private server smoke test before public release
