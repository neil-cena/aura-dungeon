# Aura Dungeon - Pillars V2 (Research-Aligned)

This document replaces the previous pillars draft and is the implementation guide for building as close as possible to the principles in `aura-dungeon-research.pdf`.

## 0) Product Intent

Build a mobile-first Roblox experience that combines:

- Fast dopamine anticipation from rolling.
- Serotonin status from social identity display.
- Short, controlled cortisol spikes from dungeon challenge and boss resolution.

The game must prioritize trust, long-term retention, and ethical monetization over short-term extraction.

Acceptance criteria:

- Every shipped feature maps to at least one of: `Retention`, `Clarity`, `Trust`, `Accessibility`.
- No feature may ship if it increases monetization pressure while reducing transparency.

---

## 1) Core Loop Pillar

### 1.1 Dual Loop Structure

- Macro loop: earn currency -> roll -> equip identity/power -> social display.
- Micro loop: short dungeon run -> boss encounter -> guaranteed progression -> return to hub.
- Maintain clear causal chain: combat yields roll resources; rolling updates player identity and combat options.

Acceptance criteria:

- Average full loop completion target: 2-3 minutes.
- Players can explain the loop unaided within first session (combat -> currency -> roll).
- No mandatory dead-time sequences between loop transitions.

### 1.2 First 60 Seconds (Onboarding Contract)

- Spawn directly into an active social hub.
- Present one immediate scripted "first roll" with flashy but low power outcome.
- Route player into a beginner combat encounter with low failure risk.
- Return player to hub with enough currency for additional rolls.

Acceptance criteria:

- First interaction begins within 5 seconds of spawn.
- First combat action happens within 30-50 seconds.
- Player receives meaningful reward within first minute.

---

## 2) Combat and Dungeon Pillar

### 2.1 Session Format

- Dungeons are short, intense, and repeatable.
- Boss fights are the tension peak and progression anchor.
- Failure should still feel recoverable (avoid total-loss frustration).

Acceptance criteria:

- Dungeon runtime target remains inside 2-3 minute window.
- Boss encounter appears every run.
- Loss never wipes all progress from the run.

### 2.2 Gameplay Clarity

- Visual telegraphs must communicate danger clearly.
- Combat feedback must be readable on small screens.
- Avoid mechanics that require precision interaction beyond mobile comfort.

Acceptance criteria:

- Core enemy attacks have explicit pre-hit telegraph.
- Critical combat feedback is understandable with audio muted.

---

## 3) Social Hub and Identity Pillar

### 3.1 Hub Function

- Hub is the central social status stage and loop reset space.
- High-tier aura identity should be visible and aspirational.
- Global/social cues should celebrate notable player outcomes.

Acceptance criteria:

- Hub visibly communicates progression differences between new and advanced players.
- Returning from dungeon naturally re-enters social context (not isolated menus).

### 3.2 Aura vs Weapon Roles

- Auras are primarily expression and identity.
- Weapons drive combat function.
- Visual identity should remain distinct from direct spending power.

Acceptance criteria:

- Cosmetic acquisition paths remain meaningful independent of combat optimization.
- Combat balance is not determined by cosmetic ownership.

---

## 4) Mobile UX Pillar

### 4.1 Thumb-First Interaction

- Favor one-handed patterns and large hit targets.
- Minimize modal interruptions and tiny close controls.
- Keep high-frequency actions in comfortable thumb zones.

Acceptance criteria:

- Core actions are reachable without hand repositioning in landscape mode.
- No required interaction depends on precision tapping small targets.

### 4.2 Performance and Stability

- Prioritize smooth runtime on mid/low-end mobile devices.
- Apply adaptive quality controls for battery and device constraints.
- Preserve readability and input responsiveness under load.

Acceptance criteria:

- Visual effects degrade gracefully before gameplay responsiveness degrades.
- Battery-saving behavior never removes critical gameplay information.

---

## 5) Ethical Economy Pillar (Non-Negotiable)

### 5.1 Monetization Philosophy

- Monetize `Expression` and `Convenience`, not raw combat enhancement.
- Revenue must remain compatible with player trust and long-term retention.
- Pricing and purchase outcomes must be transparent.

Acceptance criteria:

- Paid offerings do not create insurmountable power advantage.
- Store content is previewable with clear expected value.

### 5.2 RNG Ethics

- Publicly disclose probabilities.
- Implement deterministic hard pity thresholds.
- Ensure server-authoritative roll logic and pity counters.

Acceptance criteria:

- Odds are visible to players before rolling.
- Hard pity guarantees are explicit and enforceable.
- Roll outcomes are not trusted to client logic.

### 5.3 Compliance

- Respect policy constraints for age and region where applicable.
- Disable or modify restricted monetization flows automatically.

Acceptance criteria:

- Compliance checks gate restricted flows before purchase interaction.
- No region-restricted mechanic appears without legal/policy validation.

---

## 6) Approved Monetization Surface

Allowed categories:

- Direct-purchase cosmetics with clear fixed pricing.
- Battle pass with previewable guaranteed rewards.
- QoL upgrades that save time without granting dominant combat power.
- One-time onboarding offers only when value and contents are explicit.

Acceptance criteria:

- Each monetized item must declare: `Type`, `Value`, `Power Impact`, `Transparency`.
- Any item marked as combat enhancement requires design review and is blocked by default.

---

## 7) Explicitly Prohibited Patterns

Do not ship:

- Any mechanic described or tuned as "aggressive conversion" at the expense of trust.
- Any design intended to artificially inflate platform metrics.
- Deceptive offer framing (fake discounts, obscured costs, ambiguous outcomes).
- Monetization that relies on frustration engineering to force spending.
- Roll presentation tricks that can be interpreted as misleading outcome manipulation.

Acceptance criteria:

- Product copy and UI language pass a plain-language honesty check.
- No growth KPI is optimized through deception or coercion patterns.

---

## 8) Seven-Day Delivery Plan (Execution Scaffold)

Day 1:

- Define economy schema, probability tables, pity thresholds, and server data model.

Day 2:

- Implement server-authoritative rolling, pity logic, and validation.

Day 3:

- Build social hub flow and first-60-seconds onboarding path.

Day 4:

- Implement dungeon instance loop, combat logic, and boss phase.

Day 5:

- Polish VFX/audio/UI feedback for readability and excitement.

Day 6:

- Run playtests, exploit checks, performance tuning, and balance pass.

Day 7:

- Integrate approved monetization, compliance gating, and launch QA.

Acceptance criteria:

- End of each day includes a playable build and a short risk log.
- Any unresolved issue touching trust, transparency, or compliance blocks release.

---

## 9) Feature Review Gate (Must Pass Before Merge)

Every feature PR/spec must answer:

1. What part of the loop does this strengthen?
2. How does this reduce friction for mobile users?
3. How does this preserve transparency and trust?
4. Could this create perceived pay-to-win pressure?
5. Is policy/regional compliance affected?

If any answer is unclear, the feature does not ship.