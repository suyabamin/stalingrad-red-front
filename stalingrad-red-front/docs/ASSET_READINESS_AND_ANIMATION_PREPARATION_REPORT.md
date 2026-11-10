# Asset Readiness & Animation Preparation Report

**Project:** `D:\Stalingrad Red Front\stalingrad-red-front`  
**Review date:** 2026-11-11  
**Engine / renderer:** Godot 4.7.2, Compatibility  
**Target:** Intel UHD 620, 16 GB RAM  
**Authorization:** Asset preparation, research and isolated inspection only. No gameplay integration or replacement was performed.

## Executive summary

The incoming soldier, Mosin and arms assets still import and render in isolated checks. The soldier FBX has a 49-bone skin but no clips, and its supplied texture is not bound in the imported material. The Mosin is a static 28,041-triangle mesh with visible UVs and three 4K maps. The arms FBXs share a 62-bone hierarchy; the test FBX contains one 2.25-second generic action. The test FBX's embedded character root is ten times larger than the base file's root. An isolated outer scale of 0.1 matches the base bounds, but the test variant also differs in a small set of control-bone rest poses, so that normalization alone does not establish interchangeability.

I generated and imported untouched-source 2K and 1K Mosin texture sets. Their Godot cache totals are 11,391,910 and 2,926,498 bytes respectively, compared with the previously measured 58,311,424-byte 4K cache. The rendered full-weapon views look similar at this scale; this does not establish close-up quality or runtime performance. Candidate files are isolated under `assets/library/readiness_candidates/` and are not referenced by gameplay.

The source/provenance for all incoming soldier, Mosin and arms files remains unresolved. No PPSH was acquired: candidate pages are discoverable, but binary downloads require platform authentication that was unavailable in this workspace. The best current lead is the MaX3Dd Sketchfab PPSH listing (4.2k triangles, 2K PBR set, CC Attribution shown, NoAI tag); its actual file, exact license-version link, geometry and suitability were not inspected.

**Readiness recommendation: CONDITIONAL PASS for isolated technical preparation; BLOCKED for integration clearance.** Rights, animation acquisition, camera/grip fit and a downloaded PPSH remain open.

## Current architecture assessment

- `project.godot` selects `scenes/main/main.tscn`, Godot 4.7.2 and the Compatibility renderer. No Blender importer is enabled and no Blender executable was found in the available command paths or standard installation folders checked.
- Mission 01 is assembled from `scenes/main/main.tscn`, the existing player/HUD, `scripts/environment/battlefield.gd`, the mission manager and encounter resources. Player, weapons, enemy, objectives, navigation and mission logic remain outside this work.
- The existing player weapons are procedural views. `weapon_manager.gd` and the weapon resources own firing, reload, ammo, recoil and selection. No new asset was attached to the player or weapon scenes.
- The existing enemy visual is still the integrated Phase 5 asset. The incoming soldier remains an isolated candidate; `enemy_controller.gd` and Enemy Test Range setup were not changed for this milestone.
- Phase 5B/5C documentation and audio restoration documentation were reviewed. Existing reports record pending owner F5/F6 and visual/audio acceptance items. Those pending items are not evidence that this asset-preparation work changes or resolves them.

## Incoming asset readiness

| Category | Current contents / technical result | Readiness |
|---|---|---|
| German Wehrmacht soldier | `LowpolySoldier.fbx`: 2 skinned meshes, 5,075 triangles, 49-bone Skeleton3D, no animation clips. Supplied 1710×2048 texture imports but is not bound to the FBX material. Temporary override visibly uses the UVs, but the rendered uniform is very dark and needs material review. | CONDITIONAL PASS technically; rights and animation unresolved |
| Mosin-Nagant | One static 28,041-triangle mesh, one material, no skeleton/clips. Long axis Z; rendered bound about 1.291 m. Three 4096×4096 maps load as albedo, normal and metallic-roughness. UV array contains 22,570 entries; no UV2. Mesh hierarchy has one model mesh node, so bolt, trigger, magazine and stock are not independently articulated parts. | CONDITIONAL PASS as a static candidate; rights and viewmodel fit unresolved |
| First-person arms | Base and test FBXs each have one 8,152-triangle skinned mesh and 62 bones. One 1024×1024 color texture; it is not bound in source FBX material. Diagnostic override maps it to the hands/arms. No real-player-camera attachment was made. | CONDITIONAL PASS as a rigged candidate; rights, grip and camera fit unresolved |
| PPSH-41 incoming folder | Empty; zero downloaded files. Existing licensed static weapon-pack PPSH was inspected by the earlier import-validation pass and was not copied or altered. | BLOCKED: no incoming candidate file |

### German soldier bone hierarchy and pose readiness

The imported 49-bone hierarchy is rooted at `Hips` (parent `-1`; rest origin approximately `(0.000001, 1.015162, -0.014145)`, near-zero rest rotation). Main torso chain: `Hips → Spine → Spine1 → Spine2 → Neck → Head → HeadTop_End`. Shoulder/arm branches are `Spine2 → LeftShoulder → LeftArm → LeftForeArm → LeftHand` and `Spine2 → RightShoulder → RightArm → RightForeArm → RightHand`. Leg branches are `Hips → LeftUpLeg → LeftLeg → LeftFoot → LeftToeBase → LeftToe_End` and the corresponding right-side chain.

Each hand has thumb, index and middle finger chains (`*1 → *2 → *3 → *4`); ring- and pinky-finger bones are absent. The skeleton has no rifle grip pose or weapon attachment point demonstrated. Both `Soldier_1` (4,829 triangles) and `Helmet` (246 triangles) have skin data referencing the same Skeleton3D. A temporary 35° rotation of `LeftArm` visibly deformed the skinned mesh in the isolated preview. That proves a deformation path, not useful combat animation.

The shoulder rest axes are strongly rotated relative to a simple world-axis arm pose (left/right shoulder rest rotations are approximately `(70.9, -90.9, 180)` and `(70.9, 90.7, -180)` degrees). The rendered rest pose is T-shaped. A two-handed rifle pose may be authored or retargeted, but was not created or validated. The missing ring/pinky chains limit detailed weapon wrapping; suitability for an actual grip remains unverified.

### Soldier animation acquisition plan

No licensed soldier animation file was obtained for this pass. Adobe's official Mixamo FAQ says Mixamo characters and animations may be used in personal, commercial and non-profit projects, including video games, and that its auto-rigger/animation library targets biped humanoids ([Adobe Mixamo FAQ](https://helpx.adobe.com/sg/creative-cloud/faq/mixamo-faq.html)). This supports Mixamo as a candidate source, not as proof that a particular rifle clip exists or retargets correctly to this skeleton.

Next acquisition should first test one unarmed idle/walk/run cycle on a duplicated soldier in an isolated scene, then evaluate rifle-ready/aim/fire/reload/hit/death motions individually. Capture each source URL, creator/source, exact clip name, duration, loop mode, download format and license at acquisition time. Inspect arm/palm pose and pelvis/root motion. If rifle interactions are unavailable or unusable, author a minimal original rifle set against this skeleton. Do not describe an animation as firing or reloading based only on its name.

### First-person arms scale, rig, texture and action

Both FBX import sidecars use the same Godot settings (`nodes/apply_root_scale=true`, `nodes/root_scale=1.0`, `animation/import=true`). The imported character node is rotated `-90°` about X in both files. The base FBX character node has local scale `(0.1,0.1,0.1)` and Z offset `-0.015254`; the test FBX character node has scale `(1,1,1)` and Z offset `-0.152545`. Their mesh-local AABBs are the same `(11.5898, 4.5635, 4.5736)`; world bounds therefore differ by exactly 10×. The mismatch is in the FBX scene transforms, not the Godot sidecar settings.

Both rigs have the same 62 bone names and parent indices, including clavicle/deltoid/upper-arm/forearm/hand-control chains and thumb, index, middle, ring and pinky chains. Their rest poses are almost identical for most joints, but four controls have materially different rest transforms: `clavicle.L` (~9.37° max rotation delta), `clavicle.R` (~13.18°), `hand.L.control` (~63.86° and 3.83-unit positional difference), and `hand.R.control` (~60.11° and 3.06-unit positional difference). A temporary outer `0.1` scale on the test scene produces the base bounds and still allows the clip to change pose; the changed control-bone rest poses mean it is not a complete correction or proof of animation compatibility.

The exact test clip is **`caucasian_male_1|caucasian_male_1Action`**, **2.250000 s**, **43 tracks**, non-looping. Seeking to 0.563, 1.125, 1.688 and 2.240 s changed the skeleton pose compared with the 0 s pose. Rendered keyframes show the hands moving together into a clasping/reaching motion. No weapon is present, and the action does not read as a safe rifle grip, aim, fire or reload. Start/end poses are not the same, so seamless looping was not established. It should not be used as a combat clip without separate animation editing and review.

The open-hand base pose renders against the isolated camera, but wrists/hands are not aligned to either weapon. The camera view is a diagnostic framing exercise only: no first-person near plane, real-player camera transform, arm clipping or weapon attachment has been tested. The Blender variants remain uninspected internally because Blender was unavailable; header checks identify Blender v273 as already recorded in the import-validation report.

### Mosin mesh, maps and optimization

The imported node path contains a single mesh node `MosinNagant_Mosin_0` below the Sketchfab/FBX/root nodes. The source exposes a 22,570-entry UV array and one StandardMaterial3D surface with its 3 texture maps. There are no separate animated nodes for bolt, magazine, trigger, stock or barrel. The stock, trigger/magazine area, sights, barrel and muzzle are visible in the side render, but their exact grip coordinates and muzzle offset from a future camera were not measured. With one combined mesh, later bolt/reload motion would require mesh editing or a newly authored split model.

Original GLB and extracted images remain unchanged. Six derived Lanczos-resized PNGs are in `assets/library/readiness_candidates/mosin_nagant/`. Godot import/cache sizes:

| Set | PNG source bytes (3 maps) | `.ctex` cache bytes | Compared with original cache |
|---|---:|---:|---:|
| Original 4K | 54,746,735 | 58,311,424 | baseline |
| 2K | 14,455,106 | 11,391,910 | 80.5% smaller cache |
| 1K | 3,740,345 | 2,926,498 | 95.0% smaller cache |

The 1280×720 side previews show no obvious difference at full-weapon scale between original and the downscaled albedo override. For that controlled render comparison the 2K/1K preview changes the albedo only; original 4K normal and metallic-roughness maps remain on the diagnostic material. The candidate PNG sets were fully imported and their cache sizes measured, but a full all-maps-downscaled close-up comparison and an in-game runtime memory/FPS benchmark were not done. Prefer the 2K candidate for future integration evaluation; 1K is a smaller fallback. Do not claim an FPS gain from cache size alone.

### Preview evidence

Rendered on the Compatibility renderer at **1280×720** into `docs/asset_readiness_previews/`:

- `german_soldier_front.png`, `german_soldier_pose_diagnostic.png`
- `first_person_arms_base_camera.png`
- `arms_action_0000ms.png`, `arms_action_0563ms.png`, `arms_action_1125ms.png`, `arms_action_1688ms.png`, `arms_action_2240ms.png`
- `mosin_original_4k.png`, `mosin_2048_preview.png`, `mosin_1024_preview.png`

These are isolated diagnostic renders. The soldier cloth renders very dark with the supplied texture; its binding/UV alignment is plausible but the visible material result needs work. The `german_soldier_pose_diagnostic.png` capture is misframed and shows only the lower body, so it is not visual evidence of the temporary arm pose; the pose-change finding comes from the isolated skeleton/skin diagnostic, not that image. The soldier front capture also crops the helmet top slightly and leaves substantial unused frame space. The arms render open-handed, and the test action brings the hands together without a weapon. No combined arms+weapon preview is supplied because the hands do not establish a valid grip; placing the gun by eye would falsely imply fit.

## Compatibility matrix

| Asset pair / system | Status | Evidence and required work |
|---|---|---|
| German soldier + rifle animations | CONDITIONAL | 49-bone skinned humanoid deforms; no clips. Source/license and actual rifle retargets are unresolved. Acquire and pose-review clips, including fingers/weapon contact. |
| Arms + Mosin | NOT READY | Arms are open-handed; Mosin is static and combined in one mesh. Align both in a temporary first-person camera, resolve grip and hand pose, then test clipping/near plane in an isolated camera scene. |
| Arms + PPSH | BLOCKED | No incoming PPSH file and no hand pose fit. Acquire an eligible model, inspect mesh parts, then fit both hands in an isolated camera preview. |
| Mosin + existing weapon logic | NOT TESTED | Static model not attached to the existing system. Future separate authorization required for any gameplay scene/weapon wiring. |
| PPSH + existing weapon logic | NOT TESTED | No incoming file. Existing weapon system and static PPSH pack were left unchanged. |
| Candidate assets + Compatibility/UHD 620 | CONDITIONAL | Compatibility renderer loads the meshes/materials. 4K Mosin maps create a 58.3 MB cache; derived 2K/1K caches are smaller. No runtime GPU memory/FPS benchmark was run for these candidates. |

## License and provenance

No local license/credit/readme file was found for the incoming soldier, Mosin or arms set. The exact original download source for those files could not be identified. A Meshy page named “FPS ARMS RIG 1” by alpbeop displays CC0, but the local file's hash, rig and texture could not be linked to that listing; it is not accepted as provenance. All three incoming categories are therefore **Missing source / Unresolved**. See [ASSET_LICENSE_REGISTER.md](ASSET_LICENSE_REGISTER.md) and [PPSH_41_ACQUISITION_REPORT.md](PPSH_41_ACQUISITION_REPORT.md).

For animations, Mixamo is a license-compatible candidate source for game use per Adobe's FAQ, but no clip has been downloaded, so there are no candidate clip names, durations, formats or retarget results to report. No game-ripped clips were sought or used.

## Project integrity, tests and limits

No gameplay code, Mission 01, Enemy Test Range, weapon/enemy system, player camera, collision, navigation, objective, mission progression or source asset was modified. `assets/all_assets/` was not written by this work; its current counts remain 166 files and 68 `.import` sidecars, matching the prior inventory. Existing parent `README.md` merge conflict remains untouched. Nothing was staged or committed.

The separate test report records the sequential import scan, isolated validation, render capture and regression results. The phase regression suite passed **170 automated checks** across 3B, 4A, 4B, 4C and 5C; Phase 4B mouse capture remains headless `NOT TESTED`. These checks do not prove visual acceptance, license provenance, game-ready animation or owner gameplay behavior.

The non-headless render completed and saved every preview with error code 0. Godot also emitted repeated `Condition "f.is_null()" is true` shader-cache write errors while drawing the imported assets; their cause is unconfirmed. Headless scene processing also emitted `Parameter "material" is null` from the dummy renderer while traversing previews. These diagnostics did not prevent scene-data checks or the saved non-headless images, but they remain recorded rather than attributed to a proven cause.

## Remaining owner decisions and next milestone

1. Provide original source URLs or license files/creator information for the soldier, Mosin and arms downloads. Until then, do not recommend them for redistribution or commercial release.
2. Review the isolated images, the dark soldier texture result, the generic arms action and the 2K/1K cache comparison.
3. If a PPSH is still wanted, retrieve a candidate through an authenticated account from the cited source page and provide the original archive, license/attribution record and source URL in the incoming folder. The current best lead is listed in the acquisition report.
4. After asset and animation readiness review, define a separate approval milestone for isolated weapon/arms and soldier-animation proofs if needed.
5. Do not integrate any model, animation or weapon into gameplay until the owner explicitly approves that next stage.
