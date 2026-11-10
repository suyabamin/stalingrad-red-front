# Project architecture

The project uses Godot 4.7 GDScript and the Compatibility renderer for a modest Windows PC. Mission 01 is the only playable level in this phase.

## Folder structure

```text
assets/
  models/phase_5b/             Imported environment models and source textures
  textures/environment/        Shared tiling battlefield surfaces
  audio/ characters/ effects/ weapons/
data/                         Mission and tuning data as it is added
docs/                         Project and workflow documentation
resources/                    Reusable Godot resources
  scenes/
  enemies/ main/ player/ ui/ environment/ weapons/
scripts/
  core/ enemies/ environment/ missions/ player/ testing/ ui/ weapons/
resources/
  weapons/                    Tunable weapon data Resources
tests/                        Automated checks as they are added
```

Environment models and texture sources are under `assets/`; original third-party model files are preserved alongside their project license/attribution records.

## Runtime scenes and scripts

- `scenes/main/main.tscn` is the startup scene. It owns lighting, the battlefield, player instance, and HUD.
- `scripts/environment/battlefield.gd` builds the Volga landing and ruined street route, objective markers, and one hand-authored central `NavigationRegion3D` corridor. It instances imported ruined-house, rubble, sandbag and crate visuals without generated collision or navigation.
- `resources/missions/mission_01.tres` stores the Across the Volga briefing, ordered objectives, and optional encounter references. `EncounterDefinition` resources under `resources/missions/encounters/` hold enemy scene references, Battlefield-local spawn positions, and per-encounter live caps.
- `scenes/missions/objective_trigger.tscn` is a reusable nonblocking Area3D marker. Its script accepts only `PlayerController` entries and reports the matching active location condition through `MissionManager`.
- `scripts/missions/mission_manager.gd` owns READY/ACTIVE/COMPLETED/FAILED mission state, sequential objective states, location/encounter completion gates, duplicate and run-token guards, and lifecycle signals. Objectives 1–4 require both location and encounter clear; objective 5 remains location-only. Player death fails the active objective.
- `scripts/missions/mission_encounter_manager.gd` is a Mission 01-local child under Battlefield. It spawns the existing infantry scene on objective activation, tracks death signals, stages reinforcements below a two-living-enemy cap, validates spawn projection onto the synchronized corridor, and cleans up on mission reset/failure/completion.
- `scenes/player/player.tscn` is a reusable `CharacterBody3D`; `scripts/player/player_controller.gd` implements first-person look and movement.
- `scripts/weapons/weapon_manager.gd` owns Mosin-Nagant and PPSH-41 instances, selection, cooldown, reload timing, ADS and recoil integration. `weapon_base.gd` handles reusable ammunition/reload state and camera-centered hitscan. Weapon statistics and optional audio streams are Resources under `resources/weapons/`.
- `scenes/testing/combat_test_range.tscn` is an isolated stationary-target range and is not the startup scene.
- `scenes/enemies/infantry_enemy.tscn` is a reusable CharacterBody3D graybox actor. Its `EnemyHealth` component implements `apply_damage(amount: int)`. `EnemyController` detects the registered player, investigates a hidden target's last known position, chases via NavigationAgent3D with local avoidance, fires line-of-sight checked hitscan, reloads a configurable magazine, and stops combat on either participant's death.
- `scenes/testing/enemy_test_range.tscn` is an isolated navigation and combat scene with the existing player/HUD, obstacles, one enemy and live enemy health/state/ammunition/player health readout. `scenes/testing/phase_03b_runtime_check.tscn` runs the headless combat assertions. Neither scene changes the Mission 01 startup scene.
- `scripts/ui/prototype_hud.gd` retains reticle, health, weapon/ammunition/reload, controls and death recovery, and adds a mouse-interactive briefing, signal-driven objective display, completion feedback, and mission completion/restart screen. UI updates use manager signals.
- `scripts/core/game_manager.gd` tracks the active player and pause state, with signals for lifecycle changes.
- `scenes/testing/phase_04b_runtime_check.tscn` exercises the briefing, combat-aware objective sequence, weapon regressions, completion restart, and death/restart encounter cleanup.
- `scenes/testing/phase_04c_runtime_check.tscn` checks Mission 01 map/spawn readiness, combat AI and weapon hits, objective gates, staged encounters, run reset, and stale reports. Automated checks do not substitute for manual visual/input verification.
- `scripts/core/settings_manager.gd` owns mouse sensitivity. The initial `input_setup.gd` helper installs keyboard actions only when absent.

The hitscan damage receiver convention is `apply_damage(amount: int)`. The player's RID is excluded from the weapon ray query. Weapon graybox meshes and hit markers are generated with built-in primitives; there are no bundled weapon/audio assets.

Enemy and player health use the `apply_damage(amount: int)` damage receiver convention. Enemy detection and sight checks are interval driven; shot rays run only when firing. Enemy navigation waits safely for a synchronized map. Enemy combat settings are exported on `EnemyController`. The five animation names (idle, walking, running, hit, death) are procedural placeholder motion only; no licensed character model or animation assets are included. Phase 4C automated checks passed, and the project owner reports manual gameplay verification passed. Phase 5B adds render-only, reused ruined-house, rubble, sandbag, and crate models plus restrained shoulder dressing in `battlefield.gd`; original colliders and navigation remain. Phase 5B implementation and checks are recorded in the Phase 5B reports. The editor-only F5 close remains unconfirmed and needs owner verification before Phase 5C.

## Performance choices

The scene uses shared rough materials, one directional light without real-time shadows, no post-processing, and basic static collision. The Compatibility renderer is selected in project settings. A 1,200-frame Phase 5B sample at 1280×720 on Intel UHD 620 is recorded in `PHASE_05B_TEST_REPORT.md`; thermal, memory and export profiling remain outstanding.
