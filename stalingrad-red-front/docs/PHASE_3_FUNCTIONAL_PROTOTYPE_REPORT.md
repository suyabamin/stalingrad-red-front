# Phase 3 Functional Prototype Report

**Status: PARTIAL / BLOCKED — no gameplay integration.** Work stayed in the isolated diagnostic scene and script: `scenes/testing/phase3_functional_prototypes.tscn` and `scripts/testing/phase3_functional_prototype.gd`.

## Verified

- Loaded the incoming German soldier FBX and inspected its skeleton; expected bilateral arm/forearm/hand bones exist. The Phase 2 import report records 49 bones, two skinned meshes, and no supplied animation clips.
- Loaded the incoming arms FBX and inspected the 62-bone hierarchy. The base variant has no clips. A separate test variant has one generic 2.25 second action, not a validated weapon animation.
- Loaded the existing J.AkioHonda WW2 Low Poly Weapons Pack and isolated its named PPSH body/magazine content. Three mesh surfaces render, count 3,544 triangles, and use `Wood_Parts` and `BlackMetalParts`. Its local license file identifies CC BY 4.0 with attribution.
- Confirmed Godot 4.7.2 exposes `SkeletonIK3D`.
- Sequential automated regression scenes passed: Phase 3B 28, Phase 4A 12, Phase 4B 39 (0 failed), Phase 4C 56 (0 failed), Phase 5C 35 (0 failed). See [PHASE_3_TEST_REPORT.md](PHASE_3_TEST_REPORT.md).

## Acceptance gaps

The PPSH capture at `docs/asset_readiness_previews/phase3/ppsh_41_existing_pack.png` was opened and visually inspected; it is invalid (cropped/off-center in one capture and blank after a framing adjustment). It is not acceptance evidence.

No soldier rifle hold, aim, integrated fire, first-person two-hand grip, or reload sequence was completed or captured. No downloaded animation was acquired. No source license was established for the incoming soldier, Mosin or arms. The incoming PPSH folder is empty, although an existing licensed static-pack candidate is available.

Therefore the milestone does not meet functional or visual acceptance. No regression result substitutes for the missing rendered sequences or owner review.

## Preservation / boundary

The diagnostic scene is not referenced by Mission 01 or live player/enemy scenes. No gameplay systems or `assets/all_assets/` content were intentionally modified. The parent `README.md` merge conflict was left untouched. No staging or commit was performed. The pre-existing staged state was not altered. Stop here; wait for owner review before any gameplay integration.
