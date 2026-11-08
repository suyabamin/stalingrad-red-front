# Phase 3B Test Report: Enemy Combat AI

Verification date: 2026-11-09

## Runtime environment

- Godot `4.7.2.stable.official.ed1daf0bf`, invoked from the executable specified in the project brief.
- Headless runtime assertions plus a separate non-headless render run using the GL Compatibility renderer on `Intel(R) UHD Graphics 620`. The rendered 1280×720 test-range frame was inspected directly; visual claims below are based on that rendered frame, not headless output.
- Godot reported a Windows root-certificate-store warning and could not write its default `user://logs` path. The non-headless renderer also logged shader-cache write warnings. Scene loading, rendered capture, and runtime assertions still completed.

## Results

| Check | Result | Evidence |
|---|---|---|
| Project script registration / GDScript parse | PASSED | Godot 4.7.2 project scan and runtime harness loaded the changed enemy, test-range and capture scripts/scenes without project parse errors. |
| Enemy instance, health and initial state | PASSED | Runtime assertions confirmed the enemy exists in `enemy_test_range.tscn`, starts alive at full health, uses unit scale, and is inside the navigation polygon. |
| Camera visibility, obstruction, ground position | PASSED | At spawn `(3.5, 0, 1)` versus player `(0, 0.08, 8)`, the enemy is 7.8 m away, in the starting camera frustum, above ground, and the camera ray hits the enemy before any wall. |
| Collision, render layers, meshes and materials | PASSED | Runtime assertions confirmed enabled layer 4 collision, visible torso/head/helmet meshes on render layer 1, and assigned materials. The rendered frame shows the low-poly uniform, face, helmet, arms, legs and rifle placeholder. |
| Enemy animation height | PASSED | Runtime assertion and rendered frame confirmed the idle animation preserves the authored `Visual` root height; it no longer sinks the soldier into the floor. |
| AI startup / visible spawn | PASSED | The enemy entered ATTACK from the initial visible position. The test-range panel reports current AI state and distance. |
| Player approach | PASSED | The runtime harness pressed the existing forward movement action and confirmed the distance to the enemy decreased. |
| Idle outside detection; detection and chase | PASSED | Runtime assertions confirmed idle outside detection and chase when detected beyond attack range. |
| Navigation pursuit and bounds | PASSED | Runtime assertions confirmed the enemy closes distance to the player and remains within the test-range navigation polygon. |
| Enemy firing and player damage | PASSED | PlayerHealth decreased during enemy attack through the existing health component. |
| Wall blocks shots | PASSED | A test wall was confirmed as the first ray hit across the shot path; player health did not change while it blocked the enemy. |
| Magazine reload and reserve transfer | PASSED | One remaining round fired, then reload completed from two reserve rounds; magazine ended at two with reserve zero. |
| Empty reserve | PASSED | No reload state or ammunition restoration occurred with empty magazine and zero reserve. |
| Existing PPSH fire/ammunition/hitscan | PASSED | The player switched to PPSH, fired through `WeaponBase.fire()`, spent ammunition and damaged the enemy through its existing receiver. |
| Enemy kill using existing PPSH | PASSED | Repeated PPSH hits through the existing weapon hitscan reduced enemy health to zero and triggered its death state. |
| Player death stops attacks | PASSED | Lethal PlayerHealth damage transitioned the remaining live enemy to IDLE; its ammunition stayed unchanged. |
| Enemy death is terminal | PASSED | Lethal enemy damage transitioned to DEAD; the state remained terminal through subsequent frames. |
| Rendered test-range visibility | PASSED | A non-headless 1280×720 Godot frame was captured and visually inspected on the Intel UHD 620 renderer. Enemy is clearly visible to the right of the central barrier with the player weapon/HUD and test-range state/distance panel. |
| Mosin, weapon switching/reload, ADS/recoil, restart regression | NOT TESTED | These Phase 2 behaviors were not rerun by this Phase 3B harness. Existing weapon scripts were not modified. |
| Sustained interactive play / measured Intel UHD 620 performance | NOT TESTED | The render check confirms scene appearance, not frame-time profiling or a full manual play session. |

## Reproduction

From the project directory, run:

```powershell
& 'C:\Users\HP\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe' --headless --path . res://scenes/testing/phase_03b_runtime_check.tscn
```

The harness prints one PASSED line per assertion and `PHASE_03B_RUNTIME_CHECKS_PASSED=26` on completion. Open `res://scenes/testing/enemy_test_range.tscn` in Godot and run it with F6 for interactive checks of the enemy, obstacles, HUD and mouse aiming.

## Opening the isolated range

`project.godot` intentionally keeps `res://scenes/main/main.tscn` as the F5 startup scene. To enter the enemy range, open `res://scenes/testing/enemy_test_range.tscn` in the editor and run it with F6. Running F5 loads normal Mission 01 by design.
