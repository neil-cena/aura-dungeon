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
- Blocker note (2026-03-03): Studio MCP `require(ServerScriptService.server.persistence.ProfileStore)` still returns `Requested module experienced an error while loading`, while source-level simulation passes (`schema_version=2`, flush/update APIs present). Need direct Studio output stack trace to resolve before sign-off.

## 4) Performance & UX

- [ ] Mobile emulation pass: thumb-reach controls and readable cues
- [x] Low tier quality: particles reduced, shadows off, UI remains legible
- [x] Mid/high tiers: no major frame hitching in combat and hub
- Evidence (2026-03-03): anime-neon UI theme + readability color pass + visual downgrade tuning updated (`UITheme`, `PolishConfig`, `MobileUXController`)

### 4.1 Mobile QA Matrix

- [ ] Small phone (portrait/landscape): verify rotate hint, no clipped controls, launcher buttons reachable with right thumb
- [ ] Small phone dungeon run: start run, clear waves, die/respawn, reward return loop without stuck combat UI
- [ ] Mid phone: macro/shop/battle pass/party/social open/close only via touch launcher (no keyboard)
- [ ] Tablet: panel sizing constraints keep text readable and no overlap

### 4.2 Mobile KPI Gates (must pass before publish)

- [ ] Touch coverage gate: all core loop actions available without keyboard
- [ ] Readability gate: no primary HUD text below baseline mobile size tokens
- [ ] Network gate: idle snapshot/polling traffic reduced vs previous baseline (macro/combat/social loops)
- [ ] Stability gate: no mobile-only blockers in run start/combat/reward/daily claim loops

## 5) Exploit & Authority Checks

- [x] Combat distance/rate checks enforced server-side
- [x] Dungeon phase completion cannot be spoofed by non-leader party members
- [x] Shop and battle pass claim routes are rate-limited and validated

## 6) Publish Readiness

- [ ] Game icon + thumbnails uploaded
- [ ] Experience description updated
- [ ] Creator dashboard social/community links set
- [ ] Final private server smoke test before public release

## 7) Beauty Pass Evidence

- [x] Shared rarity + display-name presentation added (`RarityPresentation`, `AuraDisplayCatalog`, `WeaponDisplayCatalog`)
- [x] Model pipeline with fallback added (`VisualFactory` + `AssetCatalog.Models`)
- [x] Hub/dungeon/enemy visual upgrades landed without gameplay rewrites
- [x] Runtime sound load warning for reward SFX resolved
