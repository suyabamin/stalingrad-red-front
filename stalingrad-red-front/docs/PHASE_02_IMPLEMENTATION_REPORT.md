# Phase 2 Implementation Report — Weapons and Combat

## Scope

Implemented reusable, data-driven player weapons and a camera-based hitscan path. No enemy AI, campaign objectives, multiplayer, downloaded content, or third-party dependencies were added. Phase 1 `PlayerHealth` remains attached to the player and the death/restart path remains present.

## Architecture

- `scripts/weapons/weapon_data.gd` defines tunable damage, fire cadence, magazine/reserve starting ammunition, reload duration, firing mode, range, recoil, ADS field of view, and optional audio streams.
- `scripts/weapons/weapon_base.gd` owns runtime ammunition/reload state, performs camera-centered physics ray queries, calls the target's `apply_damage(amount)` method when present, and creates a short-lived low-cost impact marker.
- `scripts/weapons/weapon_manager.gd` owns weapon instances, selection, fire cooldown, one reload timer, ADS camera FOV/weapon position, sway and bounded camera recoil.
- Each weapon is an independent scene with its own data Resource. Basic meshes are generated at runtime as untextured graybox weapon visuals.
- `CombatTestTarget` is an isolated StaticBody3D damage receiver; `scenes/testing/combat_test_range.tscn` is not the mission startup scene.
- HUD ammunition/reload values are driven by weapon signals, not per-frame polling.

## Weapon statistics

| Weapon | Damage | Rate | Magazine | Starting reserve | Reload | Fire mode | Range | ADS FOV |
|---|---:|---:|---:|---:|---:|---|---:|---:|
| Mosin-Nagant | 80 | 1.2 shots/s | 5 | 30 | 2.8 s | Semi-automatic | 250 m | 58° |
| PPSH-41 | 18 | 10 shots/s | 35 | 105 | 2.5 s | Automatic | 160 m | 65° |

Values are tuning choices in `resources/weapons/*.tres`, not researched historical performance claims. The current resource field `rounds_per_second` sets the maximum cadence.

## Asset and audio notes

No external assets or sounds were downloaded or copied. The weapon visuals are simple procedural placeholder meshes. Optional fire, reload, empty-magazine and impact AudioStream fields exist in the weapon data resources, but no streams are assigned, so weapon audio is silent until suitable licensed or original audio is supplied. No external asset license claims apply.

## Verification status

Implementation is source-inspected but not runtime-verified by this agent. No Godot executable was found in PATH or the usual Program Files locations. `docs/PHASE_02_TEST_REPORT.md` contains exact manual validation steps and does not mark unexecuted checks as passed.

## Known limitations

- Weapon models and animations are placeholders; no reload animation or bolt-cycle animation exists.
- Audio resources are configurable but empty.
- Hitscan damage uses the simple `apply_damage(amount)` method convention; future enemy actors should implement this method or an adapter.
- Impacts use a short-lived sphere marker; no decals, particles, penetration, bullet drop, or projectile simulation.
- The actual Mission 01 street has no target actors yet. Use the isolated combat test range to validate hits/damage.
- No frame-rate measurement was available; UHD 620 performance remains unverified.