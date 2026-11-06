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
  combat/ core/ enemies/ environment/ missions/ player/ ui/
tests/                        Automated checks as they are added
```

The asset and extension folders are reserved for later phases; no placeholder files are added to them.

## Runtime scenes and scripts

- `scenes/main/main.tscn` is the startup scene. It owns lighting, the battlefield, player instance, and HUD.
- `scripts/environment/battlefield.gd` builds low-poly concrete facades, rubble, a clear road and collidable obstacles from primitive meshes. No external assets are needed.
- `scenes/player/player.tscn` is a reusable `CharacterBody3D`; `scripts/player/player_controller.gd` implements first-person look and movement.
- `scripts/ui/prototype_hud.gd` adds a reticle and controls hint.
- `scripts/core/game_manager.gd` tracks the active player and pause state, with signals for lifecycle changes.
- `scripts/missions/mission_manager.gd` tracks mission start and completion signals. It does not implement campaign content.
- `scripts/core/settings_manager.gd` owns mouse sensitivity. The initial `input_setup.gd` helper installs keyboard actions only when absent.

## Performance choices

The scene uses primitive geometry, one directional light without real-time shadows, no post-processing, and basic static collision. The Compatibility renderer is selected in project settings.
