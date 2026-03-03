# Day 5 - UX/VFX/Audio Polish Plan

Purpose: implement polish improvements for mobile readability and responsiveness while preserving server-authoritative gameplay from Days 1-4.

References:
- `pillars-v2.md`
- `milestone-acceptance-matrix.md` (Day 5 section)
- `readiness-checklist.md`

---

## Day 5 Scope

- Improve combat readability for mute-play and quick glance interpretation.
- Keep core actions reachable in landscape without grip shifts.
- Add quality-tier behavior so low-end devices degrade effects before responsiveness.
- Add evidence instrumentation for FPS and input-to-action latency.

---

## Day 5 Must Pass Mapping

| Matrix Requirement | Planned Implementation | Validation Artifact |
|--------------------|------------------------|---------------------|
| Core actions reachable in landscape without grip shifts | Thumb-zone aligned action panel and button sizing in dungeon UI | Manual landscape reachability checks in `day5-ux-performance-test-checklist.md` |
| Critical combat cues readable with sound off | Persistent text telegraphs and high-contrast cue labels | `MuteReadabilityDay5.spec.lua` + mute-play checklist notes |
| Visual downgrade path graceful on low-end settings | Quality tiers with reduced visual load and optional audio reduction | `QualityTierDay5.spec.lua` + device matrix |
| No polish effect harms responsiveness | Lightweight UI updates and bounded visual behavior | `ResponsivenessDay5.spec.lua` + FPS/latency evidence |
| Low-end median FPS >= 30 and mid-tier median FPS >= 45 | Performance targets and capture procedure | Device matrix + median calculations |
| Core-button p95 input latency <= 150ms | Input timing samples and p95 helper | `InputLatencyDay5.spec.lua` + p95 worksheet |

---

## Execution Order

1. Add shared Day 5 config/types (`PolishConfig`, `PolishTypes`).
2. Implement dungeon overlay/controller polish for layout, cues, and quality mode.
3. Add lightweight latency sampling and p95 calculation hooks.
4. Add Day 5 server test suite and runner.
5. Run Day 5 validation and record evidence.
6. Prepare Day 5 re-audit request packet.

---

## Guardrails

- Do not trust client payloads for outcome/state authority.
- Keep critical cues available in text even when sound is unavailable.
- If performance or latency target misses, block Day 5 PASS until mitigated.
