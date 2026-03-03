---
name: Full Game Production Plan
overview: A 4-phase, 1-month production plan to transform the existing "Aura Dungeon" validated systems prototype into a fully playable, content-rich Roblox dungeon crawler with real environments, combat, social hub, inventory UI, progression, and all features described in the research document and pillars.
todos:
  - id: p1-hub
    content: "Phase 1.1-1.2: Create AssetCatalog, LightingConfig, HubBuilder, CharacterController, CameraController -- player spawns into a real 3D hub and can walk around"
    status: completed
  - id: p1-roll-ui
    content: "Phase 1.3: Roll Station with ProximityPrompt + proper RollPanel UI (lane select, balance, odds, animated result) wired to existing RollService"
    status: completed
  - id: p1-aura-inv
    content: "Phase 1.4-1.5: AuraCatalog, AuraRenderer (particles on character), InventoryService, InventoryPanel UI (grid, equip, rarity borders)"
    status: completed
  - id: p2-arena
    content: "Phase 2.1: DungeonArenaBuilder + teleport player to arena on StartRun, back to hub on end"
    status: completed
  - id: p2-enemies
    content: "Phase 2.2: EnemyCatalog, EnemyService (server AI, waves, spawning, health), EnemyRenderer (client models, health bars, damage numbers)"
    status: completed
  - id: p2-combat
    content: "Phase 2.3-2.4: WeaponCatalog, CombatService (server hit validation), CombatController (attack button, client prediction), boss telegraph + dodge"
    status: completed
  - id: p2-reward
    content: "Phase 2.5: RewardOverlay UI, wire dungeon entry to rift portal ProximityPrompt, full dungeon-to-hub loop"
    status: completed
  - id: p3-social
    content: "Phase 3.1: Other-player aura rendering, Legendary celebration broadcast, hub leaderboard display"
    status: completed
  - id: p3-tiers
    content: "Phase 3.2-3.3: DungeonTierCatalog, multi-tier dungeons, ProgressionService (XP/levels), ProgressionConfig, HUD"
    status: completed
  - id: p3-coop
    content: "Phase 3.4-3.5: Economy balance pass, DailyRewardService, PartyService + cooperative dungeon, PartyPanel UI"
    status: completed
  - id: p4-shop
    content: "Phase 4.1-4.2: ShopCatalog, ShopService, ShopPanel, BattlePassConfig, BattlePassService, BattlePassPanel"
    status: completed
  - id: p4-persist
    content: "Phase 4.3: Replace in-memory ProfileStore cache with real DataStoreService persistence + session locking"
    status: completed
  - id: p4-polish
    content: "Phase 4.4-4.5: Audio/VFX pass (sounds in AssetCatalog), mobile UX final pass (thumbstick, mute, quality tiers)"
    status: completed
  - id: p4-launch
    content: "Phase 4.6: Full regression test suite, performance profiling, exploit verification, Roblox publish"
    status: pending
isProject: false
---

# Aura Dungeon -- Full Game Production Plan

## Current State

What exists today is a **validated systems prototype**: server-authoritative roll logic, pity engine, audit logging, a state-machine onboarding flow, dungeon run lifecycle (all text/button UI), compliance gating, and passing automated tests for all 7 audit days. There is **no 3D world, no real combat, no visual auras, no social hub, no inventory UI, no shop, no progression feel**. The client code creates `ScreenGui` buttons and text labels over an empty baseplate.

## Architecture Principle: Reskinnable by Design

Every visual asset (maps, characters, auras, weapons, UI themes) will be referenced via **asset catalog modules** (`AssetCatalog.lua`) rather than hardcoded IDs. Swapping all Toolbox placeholders for custom art later means editing one config file per asset category.

---

## Phase 1 -- World, Character, and Core Feel (Week 1)

**Goal:** A player can spawn into a real social hub, see their character, walk around, and interact with a roll station.

### P1.1 -- Social Hub Environment

- Create `src/shared/config/AssetCatalog.lua` -- central registry of all model/sound/image asset IDs (Toolbox IDs for now, easily swapped later)
- Create `src/server/world/HubBuilder.server.lua` -- spawns hub parts from AssetCatalog on server start: ground platform, skybox, roll station prop, rift portal prop, NPC spawn points, lighting
- Place free Toolbox models via MCP `run_code` in Studio for: hub platform/terrain, roll station object, portal arch, decorative props
- Configure `Lighting` service (ambient, fog, skybox) via a `src/shared/config/LightingConfig.lua`

### P1.2 -- Character Controller and Camera

- Create `src/client/controllers/CharacterController.client.lua` -- mobile-friendly character movement: virtual thumbstick (left side), camera follow (right side drag)
- Integrate Roblox `StarterCharacterScripts` for standard R15 character
- Add `src/client/controllers/CameraController.client.lua` -- third-person camera with orbit, zoom clamp, and landscape lock option

### P1.3 -- Roll Station Interaction

- Add proximity prompt on the Roll Station model (server-side via `ProximityPrompt`)
- When triggered: open the existing roll flow (currently remote-only) via a proper **Roll UI panel** (`src/client/ui/RollPanel.client.lua`)
- Roll UI shows: lane selector (Aura/Weapon), current balance, odds disclosure, animated roll result with rarity-colored flash, inventory update
- Wire to existing `RollController.server.lua` and `RollService.lua` (no server changes needed)

### P1.4 -- Aura Visual System

- Create `src/shared/config/AuraCatalog.lua` -- maps `{rarity, item_id_pattern}` to a visual definition: `{particle_emitter_id, color, size, light_range, attachment_points}`
- Create `src/client/systems/AuraRenderer.client.lua` -- attaches particle/light/beam instances to the player's character HumanoidRootPart based on their equipped aura
- On roll result or equip change, update the local player's aura visuals; replicate to other players via an `AuraEquipped` RemoteEvent that sets an attribute on the character

### P1.5 -- Basic Inventory and Equip UI

- Create `src/client/ui/InventoryPanel.client.lua` -- scrolling grid of owned auras and weapons, tap to equip, rarity-colored borders, equipped indicator
- Server: add `src/server/domain/InventoryService.lua` with `GetInventory(playerId)` and `EquipItem(playerId, slot, itemId)` reading from ProfileStore
- Remotes: `InventoryRemotes` in `Remotes.lua`

---

## Phase 2 -- Real Combat and Dungeon Loop (Week 2)

**Goal:** Player enters a portal, gets teleported to a dungeon arena, fights waves of enemies and a boss with real-time combat, earns rewards, and returns to hub.

### P2.1 -- Dungeon Arena Instance

- Create `src/server/world/DungeonArenaBuilder.lua` -- module that builds a single enclosed arena (floor, walls, obstacles) from AssetCatalog parts
- On `StartRun`, teleport the player's character to a freshly-built arena (or a reserved workspace area offset from hub)
- On run end, teleport back to hub spawn

### P2.2 -- Enemy System

- Create `src/shared/config/EnemyCatalog.lua` -- enemy type definitions: `{model_id, health, damage, speed, attack_range, attack_cooldown, xp_reward}`
- Create `src/server/domain/EnemyService.lua` -- spawns enemy NPCs in waves per `DungeonConfig.Phases`, handles AI (chase player, attack on cooldown), server-authoritative health/damage
- Create `src/client/systems/EnemyRenderer.client.lua` -- renders enemy models, health bars, damage numbers, death VFX

### P2.3 -- Player Combat

- Create `src/shared/config/WeaponCatalog.lua` -- weapon type definitions: `{model_id, rarity, damage, range, attack_speed, ability_id}`
- Create `src/server/domain/CombatService.lua` -- processes attack requests, validates range (distance check anti-exploit), applies damage, handles knockback
- Create `src/client/controllers/CombatController.client.lua` -- attack button (thumb zone), ability button, sends `RequestAttack` to server, plays local hit effects immediately (client prediction), reconciles with server response
- Hitbox: server-side spatial check (magnitude between player position and enemy position vs weapon range)

### P2.4 -- Boss Fight

- `EnemyCatalog` includes boss entries with higher health, telegraphed attacks, and a unique model
- `EnemyService` spawns boss after wave completion per `DungeonConfig.Phases.BossGuaranteed`
- Boss telegraph: server sends `BossTelegraph` event 1.2s before attack, client shows visual warning zone on ground + text cue (already in `DungeonConfig.Telegraph`)
- Dodge mechanic: player must move out of the telegraph zone; server checks position at impact time

### P2.5 -- Reward and Return Flow

- On boss defeat or loss, `DungeonService.CompleteRun` already computes rewards
- Show reward screen overlay (`src/client/ui/RewardOverlay.client.lua`) with animated coin/token count-up, item drops, XP gained
- After dismiss, teleport player to hub; existing `DungeonService.ResetRun` clears state
- Wire dungeon entry to the **Rift Portal** proximity prompt in hub (replaces the text-button rift flow)

---

## Phase 3 -- Social, Progression, and Content Depth (Week 3)

**Goal:** Hub feels alive with other players, progression is visible, there are multiple dungeon tiers, and the economy sustains a session loop.

### P3.1 -- Social Hub Polish

- Other players' auras render via `AuraRenderer` (reads character attributes)
- Legendary/Mythic roll celebration: when server detects a Legendary+ roll, fire `GlobalCelebration` event to all clients in the hub instance; client plays big VFX burst + sound + chat announcement
- Leaderboard display in hub: top players by rarity collection, dungeon clears, etc. (uses `src/server/domain/LeaderboardService.lua` writing to in-memory sorted list, displayed on a SurfaceGui in the hub)

### P3.2 -- Dungeon Tiers and Scaling

- Extend `DungeonConfig` with multiple tiers: `Beginner`, `Normal`, `Hard`, `Elite` -- each with scaled enemy health/damage, better reward multipliers, and a level requirement
- Create `src/shared/config/DungeonTierCatalog.lua` mapping tier to enemy compositions and arena visual variants
- Rift portal UI shows available tiers and recommended level
- Player level derived from total dungeon clears + XP (tracked in ProfileStore)

### P3.3 -- Player Progression System

- Create `src/server/domain/ProgressionService.lua` -- XP gain from dungeon clears, level-up thresholds, stat scaling (health, base damage)
- Create `src/shared/config/ProgressionConfig.lua` -- XP per tier, level thresholds table, stat curve
- Level and XP shown in a persistent HUD (`src/client/ui/HUD.client.lua`) alongside currency, equipped aura name, minimap dot

### P3.4 -- Currency Economy Balancing

- Currently: coins from dungeons (200 win, 25 loss) vs roll cost (100 aura, 50 weapon)
- Balance pass: ensure 1 dungeon run funds ~2 aura rolls or ~4 weapon rolls for win, and ~0.25 rolls for loss -- this keeps the macro loop spinning
- Add daily login bonus (small coin/token grant) in `ProfileStore` default profile + `src/server/domain/DailyRewardService.lua`

### P3.5 -- Cooperative Dungeon (Multiplayer)

- Extend dungeon arena to support up to 4 players (research spec: "Party of 4")
- Party system: `src/server/domain/PartyService.lua` -- invite, accept, disband; share dungeon instance
- "Party Luck Bonus": +10% drop chance per friend in the party (applied as a multiplier in `RollService` or as bonus dungeon reward)
- Party UI: `src/client/ui/PartyPanel.client.lua`
- Tomorrow TODO: run 2-player manual verification pass (invite, accept, shared teleport, shared wave progression, shared rewards, leave/disband edge cases)

---

## Phase 4 -- Monetization, Shop, Polish, and Launch (Week 4)

**Goal:** Fully featured game ready for Roblox publication with shop, battle pass, final polish, and performance validation.

### P4.1 -- Shop and Monetization UI

- Create `src/client/ui/ShopPanel.client.lua` -- tabs for: Direct-Purchase Cosmetics, Season Pass, Starter Pack, QoL Gamepasses
- Create `src/shared/config/ShopCatalog.lua` -- each item: `{id, name, type, robux_price, preview_image, description, power_impact = "None"}`
- Server: `src/server/domain/ShopService.lua` -- validates purchase via `MarketplaceService`, grants items, compliance-checks via existing `ComplianceService.IsMonetizationAllowed`
- Starter Pack: one-time-purchase check in ProfileStore

### P4.2 -- Battle Pass System

- Create `src/shared/config/BattlePassConfig.lua` -- 30 tiers, XP per tier, free track rewards, premium track rewards (all previewable)
- Server: `src/server/domain/BattlePassService.lua` -- track progress, claim rewards, check premium status
- Client: `src/client/ui/BattlePassPanel.client.lua` -- horizontal scrolling tier display with free/premium columns

### P4.3 -- Persistent Data (Real DataStore)

- Replace in-memory `profileCache` in `ProfileStore.lua` with actual `DataStoreService` calls (or integrate ProfileService library)
- Add session locking, auto-save on interval, save on player leave
- Migrate `CreateDefaultProfile` to include all new fields (level, xp, daily_reward_claimed, battle_pass_tier, equipped_aura, equipped_weapon, party_luck_bonus)

### P4.4 -- Audio and VFX Pass

- Add sound effects: roll anticipation drum, rarity reveal (different per tier), combat hit/slash, boss telegraph warning, boss death, level up jingle, UI click
- All sound IDs in `AssetCatalog.lua` for easy swap
- Particle effects: aura particles per rarity tier (from `AuraCatalog`), hit sparks, enemy death burst, boss telegraph ground circle, reward coin shower

### P4.5 -- Mobile UX Final Pass

- Virtual thumbstick positioning per `PolishConfig.ThumbLayout`
- All interactive buttons in thumb-reach zone
- Mute mode: all combat feedback has text cue fallback (already architected in Day 5)
- Quality tier system: disable particles/shadows on low-end (already in `PolishConfig.VisualDowngrade`)
- Test on mobile emulator in Studio

### P4.6 -- Final QA, Performance, and Launch

- Run full automated test suite (Days 2-7) to ensure nothing regressed
- Performance profiling: target 30+ FPS on low-end, 60 FPS on high-end
- Exploit check: verify all server-authoritative guards (distance checks, rate limits, roll integrity)
- Publish to Roblox with game icon, thumbnails, description, and social links
- Execution checklist tracked in `phase4_launch_readiness_checklist.md`
- Latest automated regression run via Studio MCP: **88 passed, 0 failed, 0 errors** across Day2/3/4/5/7 specs

---

## File Architecture Summary (New Files)

```
src/
  shared/config/
    AssetCatalog.lua          -- central model/sound/image IDs (reskinnable)
    AuraCatalog.lua           -- aura visual definitions by rarity
    WeaponCatalog.lua         -- weapon stats and model refs
    EnemyCatalog.lua          -- enemy type definitions
    DungeonTierCatalog.lua    -- tier scaling configs
    LightingConfig.lua        -- ambient/fog/skybox settings
    ProgressionConfig.lua     -- XP thresholds, stat curves
    ShopCatalog.lua           -- shop items and prices
    BattlePassConfig.lua      -- battle pass tiers and rewards
  server/
    world/
      HubBuilder.server.lua   -- spawns hub environment
      DungeonArenaBuilder.lua -- builds dungeon instances
    domain/
      InventoryService.lua    -- get/equip items
      EnemyService.lua        -- enemy AI, spawning, health
      CombatService.lua       -- attack validation, damage
      ProgressionService.lua  -- XP, leveling
      LeaderboardService.lua  -- top players
      DailyRewardService.lua  -- login bonus
      PartyService.lua        -- cooperative parties
      ShopService.lua         -- purchase validation
      BattlePassService.lua   -- battle pass progression
  client/
    controllers/
      CharacterController.client.lua  -- movement + thumbstick
      CameraController.client.lua     -- third-person camera
      CombatController.client.lua     -- attack input handling
    systems/
      AuraRenderer.client.lua   -- attach aura VFX to characters
      EnemyRenderer.client.lua  -- enemy models + health bars
    ui/
      HUD.client.lua            -- persistent heads-up display
      RollPanel.client.lua      -- proper roll UI
      InventoryPanel.client.lua -- inventory grid + equip
      RewardOverlay.client.lua  -- post-dungeon rewards
      ShopPanel.client.lua      -- monetization shop
      BattlePassPanel.client.lua-- battle pass display
      PartyPanel.client.lua     -- party management
```

## Reskinning Strategy

All Toolbox asset IDs live in `AssetCatalog.lua`, `AuraCatalog.lua`, `WeaponCatalog.lua`, and `EnemyCatalog.lua`. To reskin the entire game:

1. Create/commission replacement models
2. Upload to Roblox
3. Replace the IDs in the catalog files
4. No code changes needed

## Key Existing Code Preserved

- `RollService.lua`, `PityEngine.lua`, `RngEngine.lua`, `AuditLogger.lua` -- untouched
- `ProfileStore.lua` -- extended for DataStore, not rewritten
- `DungeonService.lua` -- extended for tiers, not rewritten
- `ComplianceService.lua` -- used by ShopService for gating
- `Remotes.lua` -- extended with new remote groups
- All Day 2-7 tests -- kept passing as regression suite

