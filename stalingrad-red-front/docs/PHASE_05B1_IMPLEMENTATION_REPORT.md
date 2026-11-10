# Phase 5B.1 — Downloaded Asset Inspection & Pilot Integration Report

**Status:** Phase 5B.1 Ruined Street pilot implemented. Owner review pending. Phase 5B.2 has **NOT STARTED**.  
**Date:** 2026-11-09  
**Engine/renderer:** Godot 4.7.2, GL Compatibility, Intel UHD Graphics 620.

## Asset inspection

All four owner-uploaded sources were found under `assets/models/phase_5b/`. Original downloaded model and texture files were preserved. Godot imported the GLB/glTF files, loaded every referenced material surface, and reported no missing texture or broken material reference.

| Asset | Source files and original size | Creator / license / attribution | Imported geometry and bounds |
|---|---|---|---|
| Ruined House Low Poly | `ruined_house_low_poly/`; 7 files, 2,353,987 bytes (2.24 MiB), including four JPEG maps | ribot02; CC BY 4.0. Credit: “ruined house low poly” by ribot02, Sketchfab. [Source](https://sketchfab.com/3d-models/ruined-house-low-poly-9fdc8d1f23a249768c377db0dfcaf42c), [license](https://creativecommons.org/licenses/by/4.0/). | glTF; 4 mesh instances, 1,776 triangles, 4 materials; converted bounds 10.0 × 7.97 × 6.0 m. |
| Rubble Pile (Game Ready / 2K PBR) | `rubble_pile_game_ready__2k_pbr/`; 6 files, 7,676,995 bytes (7.32 MiB), including base-color, normal and metallic/roughness maps | Meerschaum Digital; CC BY 4.0. The source notes the underlying scan “Rubble material pile” by matousekfoto; retain both credits. [Source](https://sketchfab.com/3d-models/rubble-pile-game-ready-2k-pbr-0e6f85da3433468db226866bd43a43e7), [license](https://creativecommons.org/licenses/by/4.0/). | glTF; 1 mesh, 1,536 triangles, 1 material; converted bounds 1.57 × 0.37 × 1.17 m. |
| Sandbag Wall Segment | `sandbag-wall-segment.glb`; original GLB 1,892,900 bytes (1.80 MiB), with two embedded textures. Godot generated two extracted texture PNGs during import. | Innerscene; CC0 per the owner-provided asset approval and project plan. [Asset listing](https://www.innerscene.com/tools/library/3d-parts/sandbag-wall-segment-1017f5ee). | GLB 2.0; 63 mesh instances, 13,356 triangles, 2 materials; bounds 1.89 × 1.00 × 0.59 m. |
| Old Military Crate | `old_military_crate_2k.gltf/`; 5 files, 9,301,193 bytes (8.87 MiB), including three 2K texture maps | Jack Mava; CC0 per the selected [Poly Haven asset](https://polyhaven.com/a/old_military_crate) and [license](https://polyhaven.com/license). Attribution is optional. | glTF; 10 mesh instances, 20,952 triangles, 1 material; source bounds 1.82 × 0.36 × 0.98 m. |

Godot's glTF importer applied the up-axis conversion. The crate render scale doubles its source height to 0.72 m. The model source files and supplied textures remain unchanged; `.import` sidecars and extracted textures are Godot-generated import metadata/output.

## Pilot integration

Only the Ruined Street pilot received these four render-only models. No imported model adds collision, physics, or navigation geometry.

| Model | Transform / fit | Existing gameplay geometry |
|---|---|---|
| Ruined facade | Center `(17, 0, -28)`, yaw +90°, unit scale; inside the existing shell envelope. | Existing shell `StaticBody3D` and `(12, 8, 13)` box collision retained exactly; only that slot's old box mesh is hidden. |
| Rubble pile | `(8, 0.02, -33)`, yaw +15°, scale `(1.6, 1.6, 3.2)`; resulting bounds about 2.51 × 0.59 × 3.73 m. | Existing cover `StaticBody3D` and `(2.8, 1.15, 4)` box collision retained exactly; only that slot's old box mesh is hidden. |
| Sandbag wall | `(10.1, 0, -38)`, unit scale, east street shoulder. | Render only; no added collider or navigation object. |
| Military crate | `(9.6, 0, -23.5)`, scale `(1, 2, 1)`, off the road. | Render only; no added collider or navigation object. |

The pilot remains outside the `x=±4.2` navigation corridor. Player start, objective triggers/resources, enemy spawn coordinates, weapon and HUD scenes, and the F6 test range were not changed. The imported scene roots remain visible additions; the two selected box meshes are hidden while their original static bodies and collision shapes remain active.

## Render evidence

Actual non-headless GL Compatibility captures at 1280×720:

- [Pilot approach](phase5b1_approach.png)
- [Facade close-up](phase5b1_facade.png)
- [Shoulder props](phase5b1_props.png)

The captures were opened and inspected. Materials render on the facade, rubble, sandbags and crate. No missing-resource errors appeared during import or capture. The imported mesh surfaces are opaque; their lack of collision is intentional for this pilot.

## Boundary

The four existing regression harnesses passed, and the short render-time comparison is recorded in `PHASE_05B1_TEST_REPORT.md`. No interactive gameplay verification was performed by the coding agent. Owner visual and manual gameplay review remains pending. Stop at this pilot; Phase 5B.2 has **NOT STARTED** and requires separate owner authorization.
