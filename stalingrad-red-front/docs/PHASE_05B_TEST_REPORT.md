# Phase 5B — Battlefield Realism Test Report

**Date:** 2026-11-10  
**Godot:** 4.7.2 stable  
**Renderer:** GL Compatibility, Intel UHD Graphics 620  
**Capture resolution:** 1280×720

## Automated regressions

All four existing harnesses were rerun after the battlefield changes:

| Harness | Result |
|---|---:|
| Phase 3B | **PASS — 26 checks** |
| Phase 4A | **PASS — 12 checks** |
| Phase 4B | **PASS — 36 checks, 0 failed** |
| Phase 4C | **PASS — 56 checks, 0 failed** |

These cover the existing player/weapon/enemy behaviors, Mission 01 navigation and spawn projections, objective progression, completion, death/restart, and test-range behavior. Phase 4B still reports OS mouse capture as not tested under headless execution.

The first final batch ran all harnesses concurrently and produced one Phase 4C timing failure (the enemy did not damage the player before the assertion deadline); the other 55 assertions passed. An isolated sequential Phase 4C rerun passed all 56 checks with exit code 0. This timing-sensitive event was not reproducible in the isolated run; no gameplay code was changed to mask it.

## Import and render checks

- Godot headless editor filesystem scan/import completed with exit code 0. The GLB/glTF assets, materials, scripts, and six new screenshots were discovered. The editor reported it could not save per-user editor settings; no project import or script errors were reported.
- The six screenshots listed in `PHASE_05B_IMPLEMENTATION_REPORT.md` were saved by the real Compatibility renderer. Each returned save error `0` and size `(1280, 720)`.
- The non-headless captures were visually inspected. No missing model texture or script error appeared. The imported scene roots are render-only; the existing collision and navigation stay in place.

## Startup checks and F5 finding

| Check | Result |
|---|---|
| Mission 01 timed non-headless Compatibility startup, 600 frames | **PASS**, exit 0; no project script/resource errors. The process closes by the explicit frame limit. |
| Mission 01 unbounded non-headless command-line startup | **Stayed running for 20 seconds**, then was interrupted. |
| F6 Enemy Test Range timed startup, 600 frames | **PASS**, exit 0; no project script/resource errors. |
| F6 Enemy Test Range unbounded command-line startup | **Stayed running for 20 seconds**, then was interrupted. |
| Godot Editor F5 key-path reproduction | **UNVERIFIED**; an automated key-send attempt in a fresh Editor session produced no separately observable game process, and the Editor/game windows could not be reliably inspected here. The original report remains unresolved. |
| Manual traversal, keyboard/mouse, and combat acceptance | **OWNER VERIFICATION REQUIRED**. |

The startup output contained the known environment errors `Failed to read the root certificate store` and inability to write `user://logs/godot.log`. The game continued running despite those messages. No game-side startup error was captured, so the exact root cause of the reported Editor F5 behavior cannot be claimed.

Full timed-launch console transcripts are retained in `phase5b_f5_startup.log` (main scene CLI launch; not the Editor F5 key path) and `phase5b_f6_startup.log`.

## Performance sample

`scripts/testing/phase5b_performance_sample.gd` sampled 1,200 frame intervals during a non-headless active Mission 01 Compatibility session at 1280×720 on the reported Intel UHD Graphics 620:

| Sample | Time |
|---|---:|
| Median | 10.014 ms |
| 95th percentile | 11.013 ms |
| 99th percentile | 12.048 ms |
| Maximum | 14.433 ms |

This is one short scene session; it is not a thermal soak or memory, export, or draw-call profile. No FPS or performance guarantee is inferred from it.

## Final status

Automated regressions, import, Compatibility rendering, screenshot generation, and CLI startup checks passed. The reported editor-only F5 close remains an open owner-verification issue because it was not reproduced and has no confirmed root cause. The new visuals have not received owner review. Do not begin Phase 5C until owner review and manual F5/F6 gameplay verification are complete.

