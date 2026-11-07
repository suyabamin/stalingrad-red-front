# Phase 3A Test Report: Enemy Foundation

Verification date: 2026-11-08

## Runtime environment

- Godot executable located from the active process: `C:\Users\HP\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe`.
- Version reported by the executable: `4.7.2.stable.official.ed1daf0bf`.
- Validation was run headless on the Windows project. This verifies resource/script execution but does not replace visual editor testing.

## Checks performed and results

| Check | Result |
|---|---|
| Godot editor project scan and global script class registration | Completed; `EnemyController` and `EnemyHealth` registered. No project GDScript parse errors were reported. Godot logged an editor-settings save error outside the workspace and a Windows root-certificate-store warning. |
| Enemy test scene and referenced resources | Passed; `enemy_test_range.tscn` loaded and instantiated with player, enemy, HUD and test geometry. |
| NavigationRegion3D / NavigationMesh | Passed; region and mesh loaded, one floor polygon was present, and the navigation map RID was valid and synchronized. |
| NavigationAgent3D target and avoidance setup | Passed; configured target path resolved to `EnemyGoal`, and avoidance was enabled. |
| Target following and obstacle avoidance | Passed in a 3-second headless run: distance to target reduced from 14.69 to 8.26 units. Minimum distance to the center barrier was 2.15 units; the configured avoidance radius was 2.1 units. |
| Enemy health signal and test readout | Passed; nonlethal 18 damage changed health from 80 to 62, emitted `health_changed`, and updated the test-range readout. |
| Existing weapon damage interface | Passed; an actual Mosin-Nagant `WeaponBase.fire()` hitscan reduced the remaining health to zero. |
| Death state and signal | Passed; health and controller entered the dead state and the death signal emitted once. Further damage was ignored. |
| Death behavior | Passed; death animation was selected and reached its configured final visual pose; collision was disabled and navigation avoidance stopped. |
| Intel UHD 620 performance / visual appearance | Not measured; tests ran headless. |

The headless executable logged a Windows root-certificate-store warning. Early runs also could not write Godot's default `user://logs` location under the sandbox; the final navigation run used a workspace log file. These environment warnings did not prevent the listed project checks from completing.

## Confirmed issue found and fixed

Runtime firing initially missed even though the camera ray intersected the enemy. `WeaponBase.fire()` emitted recoil before hitscan; the recoil signal changed camera pitch immediately, so the shot ray used the kicked camera angle. `weapon_base.gd` now resolves hitscan before emitting recoil. The post-fix actual weapon-fire check passed.

## Remaining manual checks

Use the Godot Editor to open `res://scenes/testing/enemy_test_range.tscn` and run it (F6) for a visual check of the soldier placeholder, animation poses, HUD layout, mouse aiming, and target visibility. Confirm no errors in the editor debugger. Headless validation does not assess rendered appearance, Windows GPU performance, or interactive input feel.

No Phase 3B behavior was added or tested.
