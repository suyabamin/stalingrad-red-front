# Mosin-Nagant Viewmodel Preparation Report

**Status: CONDITIONAL PASS as a static textured candidate; NOT TESTED as a production viewmodel.**

## Asset inspection

The original GLB imports as one static 28,041-triangle mesh and one material. It has no skeleton or animation, and bolt/magazine/trigger geometry is not independently articulated in its one mesh node. Imported bounds are approximately `(0.079878, 0.376333, 1.290656)` with the long axis along Z. All three original 4096×4096 maps load in the source material. The source creator/license remain unresolved.

## Texture candidates

Untouched source maps were resized into isolated 2K and 1K candidates. Complete imported cache totals: 4K source set **58,311,424 B**, 2K **11,391,910 B**, 1K **2,926,498 B**. These figures are cache size only. The rendered comparison captures in `asset_readiness_previews/phase2/` use resized albedo with original normal and metallic-roughness maps retained; therefore they do not visually compare complete all-map candidate sets. At full-weapon scale, the albedo previews show no obvious large silhouette/material change. Close-up texel quality and runtime FPS/GPU memory were not benchmarked.

## Readiness limits

No player-camera attachment, clipping, hand placement, shoulder alignment, sight alignment, muzzle orientation, bolt operation, reload or switching pose was tested. There are no separate bolt or magazine nodes. A future non-destructive solution could use a derived scene with a separately modeled bolt/magazine mechanism, but that requires authored geometry and pose validation; it must not imply existing articulation. No weapon scripts or mechanics were changed.

Keep the original GLB and three source maps. The 2K set is the best candidate for a later matched visual/performance comparison, not an accepted runtime replacement.
