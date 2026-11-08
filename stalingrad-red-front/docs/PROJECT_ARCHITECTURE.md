# Project architecture

The project uses Godot 4.7 GDScript and the Compatibility renderer for a modest Windows PC. Mission 01 is the only playable level in this phase.

## Folder structure

```text
assets/
  audio/ characters/ effects/ environment/ textures/ weapons/
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

The asset and extension folders are reserved for later phases; no placeholder files are added to them.

## Runtime scenes and scripts

- `scenes/main/main.tscn` is the startup scene. It owns lighting, the battlefield, player instance, and HUD.
- `scripts/environment/battlefield.gd` builds low-poly concrete facades, rubble, a clear road and collidable obstacles from primitive meshes. No external assets are needed.
- `scenes/player/player.tscn` is a reusable `CharacterBody3D`; `scripts/player/player_controller.gd` implements first-person look and movement.
- `scripts/weapons/weapon_manager.gd` owns Mosin-Nagant and PPSH-41 instances, selection, cooldown, reload timing, ADS and recoil integration. `weapon_base.gd` handles reusable ammunition/reload state and camera-centered hitscan. Weapon statistics and optional audio streams are Resources under `resources/weapons/`.
- `scenes/testing/combat_test_range.tscn` is an isolated stationary-target range and is not the startup scene.
- `scenes/enemies/infantry_enemy.tscn` is a reusable CharacterBody3D graybox actor. Its `EnemyHealth` component implements `apply_damage(amount: int)`. `EnemyController` detects the registered player, investigates a hidden target's last known position, chases via NavigationAgent3D with local avoidance, fires line-of-sight checked hitscan, reloads a configurable magazine, and stops combat on either participant's death.
- `scenes/testing/enemy_test_range.tscn` is an isolated navigation and combat scene with the existing player/HUD, obstacles, one enemy and live enemy health/state/ammunition/player health readout. `scenes/testing/phase_03b_runtime_check.tscn` runs the headless combat assertions. Neither scene changes the Mission 01 startup scene.
- `scripts/ui/prototype_hud.gd` adds a reticle, controls hint, health display, and signal-driven weapon/ammunition/reload display.
- `scripts/core/game_manager.gd` tracks the active player and pause state, with signals for lifecycle changes.
- `scripts/missions/mission_manager.gd` tracks mission start and completion signals. It does not implement campaign content.
- `scripts/core/settings_manager.gd` owns mouse sensitivity. The initial `input_setup.gd` helper installs keyboard actions only when absent.

The hitscan damage receiver convention is `apply_damage(amount: int)`. The player's RID is excluded from the weapon ray query. Weapon graybox meshes and hit markers are generated with built-in primitives; there are no bundled weapon/audio assets.

Enemy and player health use the `apply_damage(amount: int)` damage receiver convention. Enemy detection and sight checks are interval driven; shot rays run only when firing. Enemy navigation waits safely for a synchronized map. Enemy combat settings are exported on `EnemyController`. The five animation names (idle, walking, running, hit, death) are procedural placeholder motion only; no licensed character model or animation assets are included.

## Performance choices

The scene uses primitive geometry, one directional light without real-time shadows, no post-processing, and basic static collision. The Compatibility renderer is selected in project settings.
