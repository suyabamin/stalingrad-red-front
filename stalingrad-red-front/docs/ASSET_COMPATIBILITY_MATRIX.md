# Asset Compatibility Matrix

**Date:** 2026-11-11  
**Scope:** Isolated technical readiness only; no gameplay integration.

| Asset pair / target | Status | Evidence | Required next work |
|---|---|---|---|
| German soldier + humanoid animations | CONDITIONAL | 49-bone weighted humanoid skin; temporary arm rotation deforms both body and helmet correctly. No soldier clips. Adobe states Mixamo animation can be used in video games, but no specific clip was acquired or tested. | Find an item-level licensed rifle set; inspect root motion, arm/hand pose, loop, names and durations. Retarget in an isolated scene; verify rifle contact and movement. |
| German soldier + two-handed rifle | NOT TESTED | Hands have thumb/index/middle chains only; ring/pinky absent. No weapon held in a validated pose. | Author/retarget an aim pose and check both hands, shoulder deformation, muzzle direction and weapon attachment in isolation. |
| First-person arms + Mosin | NOT READY | 62-bone hands but open base pose; generic clip closes hands together. Mosin is one static mesh node with no independently movable parts. | Use a separate camera, establish rifle and hands transforms from grip geometry, evaluate clipping/near plane and visibility. Do not attach to real player. |
| First-person arms + PPSH-41 | BLOCKED | Incoming folder empty; no incoming model or verified part layout. | Acquire a source through its official authenticated page with license/archive, then inspect parts and fit in a temporary camera scene. |
| Arms base FBX + arms test FBX | CONDITIONAL / SCALE MISMATCH | Same 62 names/parents, but embedded root scale is 0.1 vs 1.0; child rest transforms differ on four hand-control/clavicle bones. Temporary external 0.1 scaling normalizes bounds but does not fix/validate rest-pose differences. | Ask source creator for corrected consistent export or normalize/retarget in a separately reviewed isolated derivative, preserving source files. Test all animation after any correction. |
| Mosin + existing weapon logic | NOT TESTED | Static model inspected only; not attached to weapon scenes or scripts. Geometry has no distinct bolt/magazine animation nodes. | Separate owner authorization required before weapon presentation integration; keep existing ammo/firing/reload behavior. |
| PPSH + existing weapon logic | NOT TESTED | No incoming file. Existing licensed static weapon pack remains unchanged. | First acquire and inspect an eligible candidate; gameplay integration requires separate approval. |
| Incoming assets + Godot Compatibility renderer | CONDITIONAL PASS | Soldier, arms FBXs and Mosin GLB loaded/rendered in Godot 4.7.2 Compatibility. Mosin PBR maps appear in the rendered view. | Recheck import and visual/material results on owner's target hardware after licensing and material issues are cleared. |
| Mosin 4K / 2K / 1K textures + UHD 620 memory | 2K RECOMMENDED FOR FUTURE EVALUATION | Measured imported cache totals: 4K 58,311,424 B; 2K 11,391,910 B; 1K 2,926,498 B. | Compare all three reduced map sets at close view and measure runtime memory/FPS before choosing production resolution. No FPS gain is claimed. |

## Compatibility limits

- All incoming model licenses remain unresolved because the original download sources were not identified.
- Compatibility here means scene import, visible rendering, hierarchy/UV availability and measured texture cache. It does not imply commercial-use clearance, gameplay fit, correct animations, stable runtime performance or owner acceptance.
- No combined arms+weapon render was produced because the hands do not currently demonstrate a supported grip; an arbitrary overlay would be misleading.
- Mission 01, Enemy Test Range, collision, navigation, player, weapon and enemy systems were not modified.
