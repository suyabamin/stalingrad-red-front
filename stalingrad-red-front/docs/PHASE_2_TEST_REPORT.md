# Phase 2 Test Report

**Godot:** 4.7.2 stable  
**Renderer:** Compatibility (Intel UHD Graphics 620)  
**Run date:** 2026-11-11

## Results

| Check | Result |
|---|---|
| Headless editor import scan | PASS, exit 0. Existing import sidecars/caches refreshed as needed. Root certificate and user editor-settings writes logged environment errors. |
| Existing isolated asset import validation scene | PASS, exit 0; `ASSET_IMPORT_VALIDATION_FAILURES=0`. Headless dummy renderer logged null material diagnostics. |
| Asset readiness diagnostic, headless | PASS, exit 0. Rechecked soldier/arms/Mosin structure, texture derivatives, skeleton and animation poses. Headless skips image output. |
| Updated non-headless diagnostic | PASS, exit 0. Saved phase 2 captures at 1280×720; visually inspected full-body soldier front/side, temporary arm pose and existing asset images. Godot logged certificate/log output errors and shader cache messages without an established root cause. |
| Phase 3B | PASS, 28 checks, exit 0 |
| Phase 4A | PASS, 12 checks, exit 0 |
| Phase 4B | PASS, 39 passed / 0 reported failures, exit 0; native OS mouse capture is not established by headless execution |
| Phase 4C | PASS, 56 passed / 0 reported failures, exit 0 |
| Phase 5C | PASS, 35 passed / 0 reported failures, exit 0 |
| Total regressions | **170 passed, 0 reported failures**, sequential execution |
| PPSH import test | NOT TESTED — no candidate file |
| Genuine soldier animation retarget test | NOT TESTED — no animation package acquired |
| Weapon grip/camera fit | NOT TESTED — no verified pose pairing |
| CLI main / Editor F5 / Editor F6 / owner gameplay check | NOT TESTED in this phase |
| Runtime frame/GPU/VRAM benchmark | NOT TESTED |

## Diagnostics and interpretation

Godot reports failure to write user logs and editor settings outside the workspace, inability to read the Windows root certificate store, headless `Parameter "material" is null` messages, and non-headless shader-cache `Condition "f.is_null()" is true` messages. These were recorded as observed; their root cause was not established. Successful exit and automated assertions prove import/scene checks, not owner visual acceptance, audible playback, production animation quality, or performance improvement.

Sequential logs are retained in ignored `.godot/tmp/phase2/` for this run. The regression tests were not run concurrently, and no expectations were changed.
