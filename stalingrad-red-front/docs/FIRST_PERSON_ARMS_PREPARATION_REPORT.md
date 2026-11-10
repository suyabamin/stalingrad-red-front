# First-Person Arms Preparation Report

**Status: CONDITIONAL PASS for isolated structural inspection; BLOCKED for weapon-ready viewmodel.**

## Findings

- Base and test FBX each import one 8,152-triangle skinned mesh and a 62-bone skeleton with bilateral hand and finger chains.
- The test clip is `caucasian_male_1|caucasian_male_1Action`, 2.25 seconds, 43 tracks, non-looping. Sampled poses change over time and show the hands moving together into a clasp/reach; it is not an aiming, firing, reload, or weapon-grip animation.
- The imported child character root scale is `(0.1,0.1,0.1)` in the base FBX and `(1,1,1)` in the test FBX, accounting for the measured 10× world-bounds discrepancy. An outer diagnostic 0.1 normalization brings the test bounds into the base range, but several control-bone rest transforms differ (including clavicle and hand controls). That test is not a safe interchangeability proof and is not applied to gameplay or source import settings.
- `new_diff.png` (1024×1024) is applied only through a temporary diagnostic material override. The UV projection is visible. No original FBX/material/texture was modified; source material binding and final skin roughness remain unresolved.
- The isolated camera preview does not use or modify the player's camera. Wrist/hand visibility can be reviewed in `asset_readiness_previews/phase2/first_person_arms_base_camera.png`; there is no weapon attached. Near-plane clipping and screen coverage in the actual player camera were not tested.

## Required pose status

Neutral open hands are shown. Mosin/PPSH hold, aim, fire and reload poses are all **NOT TESTED** because no verified hand pose, compatible weapon attachment, or PPSH file is available. No generic animation is claimed to satisfy them. Combined hand/weapon captures are intentionally absent.

Original source and license are unresolved. Next work requires source/license confirmation, a per-file hierarchy/rest-transform comparison, then isolated grip alignment with actual weapon meshes and measured near-plane visibility before any integration approval.
