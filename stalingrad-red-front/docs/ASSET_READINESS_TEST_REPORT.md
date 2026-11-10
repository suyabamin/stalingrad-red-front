# Asset Readiness Test Report

**Run date:** 2026-11-11  
**Engine:** Godot 4.7.2 stable  
**Renderer:** Compatibility  
**Scope:** Isolated asset preparation only.

## Test summary

| Check | Result | Detail |
|---|---|---|
| Headless editor filesystem scan/import | PASS, exit 0 | Scanned project and imported six derived Mosin texture candidates. Godot could not read the Windows root certificate store and could not save global editor settings outside the workspace. |
| Existing isolated asset import validation scene | PASS, exit 0 | `ASSET_IMPORT_VALIDATION_FAILURES=0`; soldier 49 bones, Mosin 28,041 tris and 3 loaded 4K maps, arms 62 bones, test action 2.25 s/43 tracks. Headless dummy renderer reports `Parameter "material" is null` while traversing previews. |
| New isolated readiness diagnostic, headless | PASS, exit 0 | Confirmed UV arrays, bounds, FBX root scales, bone rest differences and animation poses; headless mode skips image captures. Same dummy-renderer material messages recorded. |
| Non-headless Compatibility rendered preview | PASS, exit 0 | 11 images saved at 1280×720 to `docs/asset_readiness_previews/`, each save returned 0. Godot emitted repeated `Condition "f.is_null()" is true` shader-cache write errors; they did not prevent saved images. Cause not established. |
| Phase 3B regression | PASS | 28 checks, exit 0; enemy firing/reload audio dispatch checks included. One resource-in-use shutdown warning. |
| Phase 4A regression | PASS | 12 checks, exit 0. |
| Phase 4B regression | PASS | 39 passed, 0 failed, exit 0. OS mouse capture is `NOT TESTED` under headless server. One resource-in-use shutdown warning. |
| Phase 4C regression | PASS | 56 passed, 0 failed, exit 0. |
| Phase 5C regression | PASS | 35 passed, 0 failed, exit 0. |
| Aggregate Phase regressions | PASS | 170 passed, 0 failed, 1 explicitly not tested (headless OS mouse capture). No expected assertions were changed. |
| CLI Main / Editor F5 / Editor F6 | NOT TESTED in this asset-readiness pass | Existing docs retain older results. This pass did not run the main scene or editor shortcuts. Do not infer F5/F6 from the isolated validation or regression scenes. |
| Owner camera/grip and gameplay listening | NOT TESTED | No owner manual gameplay/visual verification is claimed. |

## Sequential run order

1. `Godot_v4.7.2-stable_win64_console.exe --headless --editor --path . --import`
2. `--headless --path . --scene res://scenes/testing/asset_readiness_diagnostic.tscn`
3. Non-headless `--path . --scene res://scenes/testing/asset_readiness_diagnostic.tscn --quit-after 240`
4. Existing `asset_import_validation.tscn`
5. `phase_03b_runtime_check.tscn`
6. `phase_04a_runtime_check.tscn`
7. `phase_04b_runtime_check.tscn`
8. `phase_04c_runtime_check.tscn`
9. `phase_05c_runtime_check.tscn`

Each test was completed before starting the next. Console logs are retained under ignored `.godot/tmp/` for this workspace session.

## Preview artifacts

The final preview paths are listed in [ASSET_READINESS_AND_ANIMATION_PREPARATION_REPORT.md](ASSET_READINESS_AND_ANIMATION_PREPARATION_REPORT.md). They cover the soldier front and diagnostic pose, arms base, five sampled moments of the arms action, and Mosin original/2K/1K side views. The arms action is generic hand-to-hand motion; the soldier cloth appears very dark; and no combined arms+weapon view is included because a valid grip is not established.

## Performance and disk space

No runtime FPS, GPU time, draw-call delta, system memory or integrated-GPU memory benchmark was performed for the incoming assets. The measurable optimization is imported texture cache size only: 58,311,424 bytes (4K) versus 11,391,910 bytes (2K) and 2,926,498 bytes (1K).

D: free space was 8,747,835,392 bytes (8.15 GiB) at initial inspection, 3,599,327,232 bytes (3.35 GiB) before candidate texture import, and 3,584,954,368 bytes (3.34 GiB) after. The 6-map candidate import itself consumed about 14.4 MB of additional free space. The earlier multi-gigabyte free-space change accumulated during the broader import/render work; this pass did not isolate its cause. `assets/all_assets/` currently remains at 166 files and 68 `.import` sidecars, matching the pre-existing inventory report.

## Warnings and interpretation

- Godot logged failures to write `user://logs/godot.log`, read the Windows root certificate store, and save user editor settings outside the workspace. These appeared as environment-level messages and the tested scenes exited 0.
- Non-headless shader-cache output included `Condition "f.is_null()" is true`. Root cause was not established. The model screenshots were still saved and visually inspectable.
- Headless dummy renderer emitted null-material diagnostics. These are logged as observed; no cause is assigned.
- Automated checks establish resource structure, import success, pose changes and regression assertions. They cannot establish that audio is heard, the assets look historically acceptable, hands align to weapons, Editor F5/F6 work, or owner gameplay acceptance.
