# Phase 5B — Battlefield Realism Implementation Report

**Date:** 2026-11-10  
**Engine / renderer:** Godot 4.7.2, GL Compatibility  
**Target observed during capture:** Intel UHD Graphics 620, 1280×720  
**Scope:** Mission 01 environment presentation only. Phase 5C and Mission 02 were not started.

## Baseline project inventory

- **Scenes:** startup `scenes/main/main.tscn`; player and HUD; Mission 01 objective trigger; Mosin-Nagant and PPSH-41; infantry enemy; combat and enemy test ranges; Phase 3B/4A/4B/4C runtime harness scenes.
- **Scripts:** core lifecycle/settings/input; player health/controller; weapon manager/base/data; enemy controller/health; objective and mission managers/definitions; environment builder/material library; HUD; testing and capture helpers.
- **Resources:** Mission 01 definition plus four encounter definitions; weapon tuning resources; twelve shared environment materials; five 256×256 tiling surface maps; imported model resources and source textures under `assets/models/phase_5b/`.
- **Collision/navigation:** player and enemy character colliders; existing static battlefield body/collision boxes; nonblocking objective Areas; one hand-authored connected navigation corridor spanning approximately x=-4.2…4.2 and z=-94…44. Phase 5B adds no collision or navigation geometry.
- **Mission flow:** five ordered objectives at z=14, -8, -42, -75 and -90. Objectives 1–4 each use their existing encounter definitions; objective 5 remains location-only. Enemy spawn data remains in the four existing encounter resources.
- **Existing local changes:** the project already had staged/uncommitted Phase 4C/5A/5B.1 work and an unresolved parent `README.md` merge conflict when this milestone began. These were preserved; the README conflict was not modified.

## Delivered

The existing Mission 01 route now uses the approved ruined house, rubble, sandbag wall, and old military crate assets in all three connected areas. Five house instances and four rubble instances reuse the same imported scenes; rotations and slight scale changes reduce direct repetition. The matching facade and rubble box meshes are hidden at those visual slots. Their original static bodies and collision shapes remain, and no imported model adds collision or navigation geometry.

- **Area A — Volga landing:** ruined facade at the west shoulder, damaged river direction sign, scattered timber, supply crates, and reused rubble at the transition-side shoulder.
- **Area B — battlefield transition:** two varied ruined facades, existing sandbag defense and military crate, reused rubble, a rusty fuel barrel, and broken timber.
- **Area C — ruined street:** two varied facades, rubble at the street and forward shoulders, a rusty barrel, and broken fence remnants. The existing lorry and its gameplay geometry are unchanged.
- **Shared look:** raised ambient energy from 0.55 to 0.68 and directional energy from 0.8 to 0.95 to improve surface readability. Directional shadows remain disabled; no expensive renderer features or shader effects were added. Existing shared opaque textured materials remain in use.

The route width, player start, objective positions and logic, encounter/spawn data, navigation region, collision sizes, weapons, enemies, mission progression, and F6 scene were not changed.

## Asset record

Original downloaded sources remain under `assets/models/phase_5b/`. The existing Phase 5B.1 report contains the full original archive/file inventory. These assets were reused without changing the downloaded source files.

| Asset | Credit and license | Source geometry / maps |
|---|---|---|
| Ruined House Low Poly | ribot02, “ruined house low poly,” Sketchfab; CC BY 4.0. [Source](https://sketchfab.com/3d-models/ruined-house-low-poly-9fdc8d1f23a249768c377db0dfcaf42c), [license](https://creativecommons.org/licenses/by/4.0/). | 1,776 triangles, 4 materials, converted bounds 10.0 × 7.97 × 6.0 m; source directory 2,353,987 bytes. |
| Rubble Pile (Game Ready / 2K PBR) | Meerschaum Digital; underlying scan “Rubble material pile” by matousekfoto; CC BY 4.0. [Source](https://sketchfab.com/3d-models/rubble-pile-game-ready-2k-pbr-0e6f85da3433468db226866bd43a43e7), [license](https://creativecommons.org/licenses/by/4.0/). | 1,536 triangles, 1 material, 1.57 × 0.37 × 1.17 m; source directory 7,676,995 bytes; 2K PBR set. |
| Sandbag Wall Segment | Innerscene; CC0. [Asset listing](https://www.innerscene.com/tools/library/3d-parts/sandbag-wall-segment-1017f5ee). | 13,356 triangles, 2 materials, 1.89 × 1.00 × 0.59 m; GLB 1,892,900 bytes. |
| Old Military Crate | Jack Mava; CC0. [Source](https://polyhaven.com/a/old_military_crate), [license](https://polyhaven.com/license). | 20,952 triangles, 1 material, 1.82 × 0.36 × 0.98 m; source directory 9,301,193 bytes; 2K maps. |

Approximate total imported geometry visible in the scene is 49,332 triangles across the reused instances. The crate is the heaviest individual prop and remains a single instance. Existing 256×256 environment maps and shared materials were retained.

### Vehicle search

The [Innerscene Generic 1940s 2.5 t Cargo Truck](https://www.innerscene.com/tools/library/3d-parts/generic-1940s-2-5-t-cargo-truck-6e78cb4a) listing identifies a 6.6 MB, real-scale, unbranded GLB with CC0 terms and dimensions of 2.32 × 6.424 × 2.754 m. It is an intact generic truck, so it does not satisfy the requested destroyed-vehicle treatment. It was not downloaded or integrated. The existing procedural lorry remains. No ripped game model was used.

## Screenshot evidence

Captured from the actual non-headless GL Compatibility renderer at 1280×720 and visually inspected:

- [Volga River Landing](phase5b_volga_landing.png)
- [Battlefield Transition](phase5b_battlefield_transition.png)
- [Ruined Stalingrad Street](phase5b_ruined_stalingrad_street.png)
- [Building close-up](phase5b_building_closeup.png)
- [Military defensive position](phase5b_military_defensive_position.png)
- [Player-level gameplay](phase5b_player_level_gameplay.png)

The gameplay image begins the mission and shows the objective HUD. The capture helper is `scripts/testing/capture_phase5b_views.gd`.

## Startup diagnosis

The reported Editor F5 close was not reproduced, so its exact root cause remains unconfirmed and no speculative startup repair was made. `project.godot` still selects `res://scenes/main/main.tscn`. Godot 4.7.2 loaded this main scene and the F6 Enemy Test Range on the Compatibility renderer; both unbounded command-line launches remained alive for 20 seconds before being interrupted. Timed 600-frame launch checks exited with code 0. An automated F5 key-send attempt in a fresh Editor session produced no separately observable game process, and this environment did not provide a reliable view of the Editor/game windows; the Editor F5 path therefore remains unverified. These checks do not establish that the owner-reported problem is fixed. The only console errors observed were Windows certificate-store and inaccessible `user://logs` messages, also present in earlier reports.

## Known limits

- Editor-driven F5/F6 interaction and live keyboard/mouse gameplay still need owner verification.
- The editor-only F5 close has no confirmed cause or fix because it could not be reproduced here.
- Vehicle dressing is deferred until a destroyed, period-suitable model with verified terms is selected.
- No sustained thermal, memory, export, or draw-call profile was available. The render-time sample is documented in the test report.
- Existing primitive building shells, lorry, and combat character visuals remain part of the prototype style. The reused facade model is a visual overlay; existing solid collision still blocks windows and openings.

