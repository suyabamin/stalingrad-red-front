# Phase 5B.1 — Asset Import & Pilot Test Report

**Date:** 2026-11-09  
**Godot:** 4.7.2 stable  
**Renderer:** GL Compatibility on Intel UHD Graphics 620; captures at 1280×720.

## Import validation

- Headless Godot editor import completed. All four source models loaded as PackedScenes: three glTF scenes and one GLB 2.0 scene.
- Godot reported material coverage on all imported surfaces: house 4/4, rubble 1/1, sandbag 63/63, crate 10/10. No imported surface lacked a material.
- All external texture URIs in the three glTF scenes were present. The sandbag GLB contains its two images; Godot extracted two PNGs on import.
- Godot's non-headless GL Compatibility renderer launched on Intel UHD Graphics 620. The three real 1280×720 captures completed with image-save result 0.
- Imported converted bounds, mesh/triangle counts, source sizes, and licenses are listed in `PHASE_05B1_IMPLEMENTATION_REPORT.md`.

## Pilot preservation checks

- Runtime inspection found all four named pilot roots at their documented positions and scales.
- The facade and rubble slot meshes are hidden. Their original collision shapes remain present at the original world transforms and sizes: `(12, 8, 13)` and `(2.8, 1.15, 4)`. No new imported collider or navigation object was added.
- The sandbag and crate sit on the east shoulder, outside the navigation corridor and enemy lanes. The pilot geometry does not extend into `x=±4.2`.
- The automated regressions below passed, including corridor/spawn projections, weapons, objective progression, restart, HUD, enemy combat, and F6 scene availability.

## Automated regression results

| Existing harness | Result |
|---|---:|
| Phase 3B | **PASS — 26 checks** |
| Phase 4A | **PASS — 12 checks** |
| Phase 4B | **PASS — 36 checks, 0 failed** |
| Phase 4C | **PASS — 56 checks, 0 failed** |

Phase 4B reports OS mouse capture as **NOT TESTED** because the harness is headless; this is not a failed assertion. No additional automated tests are claimed.

## Render-time sample

A brief same-session sample used the non-headless Compatibility renderer at the pilot route. Each state recorded 30 frame intervals after scene load; for the comparison, the four imported roots were hidden and the original two box meshes were shown again. Results:

| State | Median frame time | 95th percentile |
|---|---:|---:|
| Pilot visible | 9.85 ms | 10.99 ms |
| Pilot visuals toggled off | 9.97 ms | 11.08 ms |

This short sample did not show a measurable pilot frame-time regression. It is not a sustained performance, memory, draw-call, or thermal profile. Measurement variance is larger than the observed difference.

## Manual verification and limits

The coding agent did not perform interactive gameplay. Collision preservation is supported by runtime inspection and the passing automated harnesses; live player traversal, enemy sightline appearance, and gameplay feel still require owner review. No F5/F6 interactive session or manual verification is claimed. Phase 5B.2 has **NOT STARTED**.
