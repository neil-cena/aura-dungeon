# Asset Mix-and-Match Guide

Use this guide to test Marketplace assets quickly without code edits.

## 1) Put models in one folder

- In Studio Explorer, create `ReplicatedStorage/AuraAssets`.
- Insert cloned Marketplace models under that folder (subfolders are fine).

## 2) Toggle model mode

Edit `src/shared/config/AssetCatalog.lua`:

- Set `AssetCatalog.Models.Enabled = true`.
- Keep `RootFolder = "AuraAssets"` unless you use a different folder name.

## 3) Map slots to model names

`AssetCatalog.Models` is slot-based:

- `Hub.DecorSet`, `Hub.RollStation`, `Hub.InventoryPedestal`, `Hub.RiftPortal`
- `Dungeon.FloorSet`, `Dungeon.WallSet`
- `Enemies.grunt_a`, `Enemies.grunt_b`, `Enemies.grunt_c`, `Enemies.rift_boss_v1`

You can map each slot using:

- string form:
  - `"MyModelName"`
- descriptor form:
  - `{ name = "MyModelName", offset = Vector3.new(0, 0, 0), rotation_degrees = Vector3.new(0, 0, 0), scale = 1.0, static = true }`

## 4) Practical test cycle

1. Change one slot mapping.
2. Play test.
3. Validate collision, prompt reachability, and readability.
4. Iterate `offset`, `rotation_degrees`, and `scale` until placement looks correct.

## 5) Safety behavior already enabled

- If a slot is missing or wrong, game falls back to primitives (gameplay still works).
- Embedded scripts inside cloned models are stripped.
- Static world art is auto-anchored and non-colliding by default.
- Enemy slots can be set to `static = false` automatically through spawn path.

## 6) Common issues

- **Model not appearing:** check exact model name and `RootFolder`.
- **Prompt blocked:** reduce model collision or move art using descriptor `offset`.
- **Art in wrong place/orientation:** tune `offset` and `rotation_degrees`.
- **Too big/small:** adjust `scale`.

