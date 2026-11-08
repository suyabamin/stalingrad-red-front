# Phase 4A Test Report: Mission 01 Battlefield

Verification date: 2026-11-09

## Runtime environment

- Godot `4.7.2.stable.official.ed1daf0bf`, launched with the executable specified in the project brief.
- Headless runtime assertions for scene setup/traversal and Phase 3B combat regression.
- Direct non-headless launch of the configured startup scene (`--path . --quit-after 180`) exited successfully after its short startup run.
- Non-headless render on GL Compatibility using `Intel(R) UHD Graphics 620`; a rendered 1280×720 startup view was captured and inspected. The frame showed the landing label, Volga water, continuous street route, existing player weapon and HUD.
- Godot emitted a Windows root-certificate-store warning, could not write its default `user://logs` path, and logged shader-cache write warnings during non-headless rendering. The project scan, scene runtime checks, combat harness and rendered capture completed.

## Results

| Check | Result | Evidence |
|---|---|---|
| Godot 4.7.2 project scan | PASSED | `--editor --quit` completed. Initial scan exposed a script parse error that was corrected before final run. |
| Configured F5 startup scene | PASSED | Godot launched the `project.godot` main scene non-headlessly and exited after 180 frames without scene/script errors. |
| Main scene and existing gameplay wiring | PASSED | Phase 4A runtime harness confirms main scene instantiates the existing player, current camera, weapon manager and HUD. |
| Mission enemy isolation | PASSED | Runtime harness confirms no `EnemyController` is present in the Mission 01 scene tree. |
| Landing and street landmarks | PASSED | Harness confirms Volga, pier, ruined building and lorry nodes are built. |
| Player start and floor collision | PASSED | Player starts at `(0, 0.08, 22)` with active first-person camera; downward physics ray hit `ContinuousGround`. |
| Traversal / fall check | PASSED | Existing forward movement was simulated for 1200 physics frames; player reached past z=-70 from the z=22 landing and remained within the ground-height range, traversing the landing, transition and ruined street route. This is automated input simulation, not manual editor play. |
| Existing weapon loop | PASSED | Existing current weapon fired and ammunition decreased by one in Mission 01. Full weapon regression was not part of this check. |
| Independent F6 scene | PASSED | Enemy test range instantiated with its existing enemy and player. |
| Phase 3B combat regression | PASSED | Godot 4.7.2 combat harness printed `PHASE_03B_RUNTIME_CHECKS_PASSED=26`, including chase, damage, wall occlusion, reload and player kill. |
| Rendered startup appearance | PASSED | Non-headless 1280×720 GL Compatibility frame captured and visually inspected on Intel UHD 620. Volga water and landing label are visible beside the road; existing weapon and HUD remain visible. |
| Sustained performance, full manual playthrough, Windows export | NOT TESTED | No frame-time or memory profile, editor-driven manual walkthrough, or export build was performed. |

## Reproduction

From the project directory:

```powershell
& 'C:\Users\HP\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe' --headless --path . --editor --quit
& 'C:\Users\HP\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe' --headless --path . res://scenes/testing/phase_04a_runtime_check.tscn
& 'C:\Users\HP\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe' --headless --path . res://scenes/testing/phase_03b_runtime_check.tscn
```

The Phase 4A harness now includes the Phase 4B briefing start and prints `PHASE_04A_RUNTIME_CHECKS_PASSED=11`. F5 runs `scenes/main/main.tscn` and opens the briefing; F6 on `scenes/testing/enemy_test_range.tscn` runs the isolated combat range.
