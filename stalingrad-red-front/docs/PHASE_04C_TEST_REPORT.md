# Phase 4C Test Report: Mission 01 Combat Integration

Verification date: 2026-11-09  
Executable: `C:\Users\HP\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe`  
Engine: Godot 4.7.2.stable.official.ed1daf0bf  
Renderer: GL Compatibility. A non-headless startup reported Intel(R) UHD Graphics 620.

## Automated test results

All tests below were run with the supplied executable using `--headless --path .` and their scene-specific runtime check scenes. These results are automated; they do not establish visual appearance or user-input behavior.

| Suite | Result | Coverage |
|---|---:|---|
| Phase 4C | `PHASE_04C_RUNTIME_CHECKS_PASSED=56 FAILED=0` | Briefing starts without spawned enemies; navigation map sync; all eight spawn projections; exact first spawn; enemy combat-state transition, path approach and player damage; real Mosin and PPSH hitscan kills; location/encounter gate in both orders; future/duplicate/stale report rejection; objective 4 staged cap; objective 5 location-only completion; clean new-run state; player-death cleanup during objectives 1–4. |
| Phase 4B | `PHASE_04B_RUNTIME_CHECKS_PASSED=36 FAILED=0` | Briefing, sequence/HUD, combat-aware objective traversal, weapon/ammo/reload/ADS checks, mission completion/restart, player death cleanup and fresh first encounter after restart. |
| Phase 4A | `PHASE_04A_RUNTIME_CHECKS_PASSED=12` | Environment/player/weapon/range regressions, no encounter actors in briefing, and one encounter after starting objective 1. |
| Phase 3B | `PHASE_03B_RUNTIME_CHECKS_PASSED=26` | Existing isolated enemy range AI, navigation, line-of-sight wall behavior, enemy damage, weapons, reload and death regression. |

The Phase 4C harness uses actual `WeaponBase.fire()` hitscan against mission-owned enemies for the Mosin and PPSH tests. It uses deterministic `EnemyHealth.apply_damage()` for the remaining staged-kill bookkeeping. The harness does not visually inspect rendered results.

Godot `--editor --quit` imported the project and registered the added global classes. It reported that Windows root certificates could not be read and that editor settings could not be saved outside the project workspace. Headless runs also reported inability to write `user://logs`; these environment warnings did not prevent the test scenes from loading and completing. No Phase 4C script/resource parse errors were reported in the successful runs.

## Non-headless startup

The supplied executable launched the startup scene non-headlessly with `--quit-after 120`, completed with exit code 0, and reported OpenGL 3.3 GL Compatibility on Intel UHD 620. This was a startup/render-device smoke check only. No captured image was reviewed, no controls were played, and this is not reported as visual verification.

## User-performed manual results

The project owner reports that Phase 4C passed manual gameplay verification. This is user-performed manual evidence and is separate from the automated harness results above. An item-by-item checklist, hardware details, and individual observations were not included with the result, so no more specific manual findings are attributed here. The earlier Phase 4B manual results remain in `PHASE_04B_TEST_REPORT.md` as historical results.

| Manual acceptance item | Status |
|---|---|
| Phase 4C manual gameplay verification | PASSED (USER-REPORTED) |
| Per-check manual observations and manual error log | Not provided; no additional details inferred |
| Intel UHD 620 performance | NOT MEASURED |

## Phase status

Phase 4C is **COMPLETE** based on the successful automated suites listed above and the project owner's report that manual gameplay verification passed. No Phase 5 work was started. Performance profiling and export validation remain outside the recorded verification results.

## Reproduction commands

```powershell
& 'C:\Users\HP\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe' --headless --path . --editor --quit
& 'C:\Users\HP\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe' --headless --path . res://scenes/testing/phase_04c_runtime_check.tscn
& 'C:\Users\HP\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe' --headless --path . res://scenes/testing/phase_04b_runtime_check.tscn
& 'C:\Users\HP\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe' --headless --path . res://scenes/testing/phase_04a_runtime_check.tscn
& 'C:\Users\HP\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe' --headless --path . res://scenes/testing/phase_03b_runtime_check.tscn
```
