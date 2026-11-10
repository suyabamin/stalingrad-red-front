# Downloaded 3D Asset Inventory

**Updated:** 2026-11-11, asset readiness and texture candidate review
**Project:** Godot 4.7.2, Compatibility renderer
**Incoming directory:** `assets/library/incoming_downloads/`

## Readiness summary

Three incoming categories were successfully imported and inspected in an isolated test scene: German soldier, Mosin-Nagant, and first-person arms FBX. The incoming `ppsh_41/` folder remains empty. The old Blender files were not imported: Godot Blender import is disabled in `project.godot`, and no Blender executable is available. No incoming asset has a license document or copyright metadata that resolves usage rights.

The German FBX contains two skinned meshes and a 49-bone humanoid skeleton, but no animation player or clips. The FBX material maps do not bind the provided texture automatically. The Mosin GLB imports and renders with base color, normal, roughness, and metallic channels loaded; it has no rig/animation and has three 4096×4096 images. The first-person arms FBX has a 62-bone rig, hands and five finger chains per side; its base material likewise does not bind the separate skin texture. The test FBX includes one working 2.25-second generic action clip, but its imported bounds are ten times larger than the base FBX variant.

No models were replaced or added to gameplay scenes. Original source files were preserved. Godot generated `.import` sidecars, imported caches under `.godot/imported`, and extracted the GLB’s three embedded images beside the GLB. The isolated test scenes and diagnostic texture overrides do not alter source model materials. `assets/all_assets/` remained at 166 files and 68 import sidecars before and after the import scan.

## Disk space

Before importing, D: reported **72,107,417,600 bytes total** and **8,920,805,376 bytes free**. The original incoming sources totaled 8 files / **61,898,938 bytes**. After import and preview generation, the latest check reported **8,803,717,120 bytes free**. Godot extracted 54,746,735 bytes of PNG image data and created 58,311,424 bytes of `.ctex` cache for the three Mosin textures. Space remains available; the source GLB and extracted files are both retained.

## Incoming file manifest

| Category | Relative path | Bytes | Imported/inspection result |
|---|---|---:|---|
| Soldier | `german_soldie/LowpolySoldier/LowpolySoldier.fbx` | 319,440 | Imported successfully; 2 skinned meshes, 5,075 triangles, Skeleton3D with 49 bones; no animation player/clips; material maps unbound |
| Soldier | `german_soldie/LowpolySoldier/LowpolySoldier_Texture.png` | 165,399 | Imported successfully; 1710×2048 PNG; shown to align in an isolated diagnostic material override |
| Mosin | `mosin_nagant/mosin_nagant_lowpoly.glb` | 56,169,068 | Imported successfully; 1 mesh, 28,041 triangles, 1 material; no skeleton/animation; imports at approximately 1.291 m along its long axis |
| PPSH | `ppsh_41/` | 0 | Empty; no incoming asset to import |
| Arms | `first_person_arms/fps arms/FPS ARMS RIG 1.fbx` | 434,092 | Imported successfully; 1 skinned mesh, 8,152 triangles, 62-bone skeleton; no clips; material map unbound |
| Arms | `first_person_arms/fps arms/FPS ARMS RIG 1.blend` | 1,634,996 | Not imported; Blender v273 file; no Blender executable, and project Blender import is disabled |
| Arms | `first_person_arms/fps arms/FPS ARMS RIG 1 test.fbx` | 743,452 | Imported successfully; same 62-bone structure and one 2.25-second clip; clip changes bone pose; imported scene is 10× the base FBX bounds |
| Arms | `first_person_arms/fps arms/FPS ARMS RIG 1 test anim.blend` | 1,745,864 | Not imported; Blender v273 file; no Blender executable, and project Blender import is disabled |
| Arms | `first_person_arms/fps arms/new_diff.png` | 686,627 | Imported successfully; 1024×1024 PNG; shown to align in an isolated diagnostic material override |

The manifest’s 8 original files total **61,898,938 bytes**. Godot’s 3 extracted Mosin texture PNGs are additional derived files, not replacements for the GLB.

## Phase 2 recheck — 2026-11-11

The eight original incoming source files and the three Godot-extracted Mosin maps remain present at the previously recorded sizes. `assets/library/incoming_downloads/ppsh_41/` remains empty. The six Mosin derivative PNGs remain under `assets/library/readiness_candidates/mosin_nagant/{1k,2k}/`; the 2K and 1K generated PNG totals are 14,455,106 and 3,740,345 bytes respectively. No original source payload was edited. A refreshed full-body front/side soldier render, temporary deformation diagnostic, arms action samples, arms view, and Mosin comparison captures are saved in `docs/asset_readiness_previews/phase2/` at 1280×720. The diagnostic scene and its script remain isolated from gameplay.

Rights status is unchanged: the incoming soldier, Mosin and arms source identities remain unresolved. A CC0 animation-library candidate is recorded in `ASSET_LICENSE_REGISTER.md`, but was not downloaded, so it has no project file manifest or compatibility result. See `PHASE_2_ASSET_ACQUISITION_REPORT.md` and the work-package reports for current technical blockers.

## Skeletons and animation

### German soldier

Godot imported `LowpolySoldier` with a `Skeleton3D` of 49 bones. The weighted `Soldier_1` mesh has 4,829 triangles; the weighted `Helmet` mesh has 246 triangles. The hierarchy includes `Hips → Spine → Spine1 → Spine2 → Neck → Head`, left and right shoulders/arms/forearms/hands, and left/right legs/feet/toes. Both hands have thumb, index, and middle-finger chains; ring and pinky chains are absent. The soldier imports in a static T-pose. No `AnimationPlayer` or clips are included.

The skin binding was exercised in the isolated test by rotating `LeftArm` 35 degrees; the skeleton global pose changed and the rendered arm followed, confirming the skin-deformation path. This is a temporary bone-pose diagnostic, not an animation clip. The rig provides a plausible base for future authored/retargeted aim, fire, and death animation, but none is available or verified. This import result does not support replacing the current enemy yet.

### First-person arms

The base FBX imports one weighted `caucasian_male_1_Body` mesh (8,152 triangles), one `Skeleton3D`, and 62 bones. It has bilateral clavicle/deltoid/upper-arm/forearm chains, separate hand roots, and thumb/index/middle/ring/pinky chains on both hands. The mesh deforms as a single skinned surface. The base FBX has no `AnimationPlayer`.

The test FBX imports the same mesh/bone names and an `AnimationPlayer`. Its exact clip is **`caucasian_male_1|caucasian_male_1Action`**, length **2.250000 seconds**, 43 tracks, non-looping. Playing/seeking it changes the skeleton pose, so skin deformation is functional. Its name and pose do not establish that it is a weapon firing or reload clip. The test-FBX imported world bounds are `(11.5898, 4.5736, 4.5635)`, while the base-FBX bounds are `(1.1590, 0.4574, 0.4564)`, a 10× scene-scale difference. Resolve that mismatch before any shared viewmodel use.

The separate `.blend` variants could only be confirmed as Blender v273 files by header inspection. Their contents, skeleton, clips, materials and texture paths remain unverified because Blender is unavailable and Blender import is disabled by project settings. No setting was changed.

## Textures and materials

- **Soldier PNG:** 1710×2048. The imported FBX creates StandardMaterial3D surfaces, but inspection found no albedo/normal/roughness/metallic texture assigned. In an isolated test-only material override, the PNG renders on both meshes with useful uniform/skin detail, confirming a plausible UV match. The actual imported source material still needs its texture bound before a production use.
- **Arms PNG:** 1024×1024. Its imported FBX StandardMaterial3D has no texture assigned. A diagnostic-only albedo override visibly maps the skin atlas onto the hands/arms. The model otherwise renders white. Actual material binding remains unresolved.
- **Mosin GLB:** three embedded 4096×4096 PNGs are extracted. The imported `Mosin` StandardMaterial3D has albedo, normal, roughness, and metallic textures loaded at 4096×4096. The roughness and metallic properties use the GLB’s metallic-roughness image. Isolated preview shows the wood/metal surface and details render.
- Godot’s generated Mosin texture import settings use mipmaps, `compress/mode=0`, and `vram_texture=false`. Cache files total 58,311,424 bytes. Three 4K maps can have a substantial shared-GPU-memory cost on Intel UHD 620. No resizing/compression changes were made; consider a preserved-source 1K/2K runtime derivative only after a separately approved integration stage and benchmark.

Texture previews and model previews were generated under the ignored `.godot/tmp/asset_previews/` cache directory for inspection. They are not production assets.

## Scale, orientation and rendered inspection

- **Soldier:** imported scene bounds approximately `(1.6583, 1.7777, 0.3468)`; rendered upright in a T-pose. This is human-scale. Mesh/material rendering works; the original imported appearance is white because the separate albedo was not linked. The isolated preview override displayed the uniform texture. No enemy scene was changed.
- **Mosin:** imported scene bounds approximately `(0.0799, 0.3763, 1.2907)`; long axis is Z. It renders horizontally when viewed from the side. Its approximate 1.29 m long dimension is viewmodel-sized, but hand grip, camera clipping, muzzle location, recoil and switching were not tested. It is static and has no moving bolt/reload animation.
- **Arms base FBX:** bounds approximately `(1.1590, 0.4574, 0.4564)`. The open-handed pose renders with the diagnostic skin atlas. Position, perspective, camera mount and weapon grip were not fitted to the existing player camera.
- **Arms test FBX:** its scene bounds are 10× the base FBX. The clip changes arm/hand pose in the isolated scene, but the pose is not proven to match any weapon or reload action.
- **Existing PPSH asset:** the incoming folder remains empty. The existing Soviet weapon pack’s named PPSH body and magazine were inspected without copying or replacing them. The isolated rendering selected 3 mesh pieces totaling 3,544 triangles, with `Wood_Parts` and `BlackMetalParts` materials; selected bounds are approximately `(1.2056, 0.4623, 0.2221)`. It is static and not attached to player hands.

## License status

No license, attribution, README, or credit files were found in any incoming folder. No licensing/copyright metadata was present in the scanned Mosin GLB metadata. **Usage rights are unresolved for the new soldier, Mosin, and arms assets; do not assume free redistribution or commercial use.** The new PPSH source is absent. The separately existing Soviet WWII weapon pack has its own `license.txt` identifying CC BY 4.0, J.AkioHonda; that license does not automatically apply to incoming files.

## Comparison with integrated assets

| Purpose | Incoming candidate | Existing integrated asset | Validation disposition |
|---|---|---|---|
| German enemy | 49-bone skinned soldier, 5,075 tris, no animations, texture unbound, license unresolved | Current Wehrmacht GLTF, 38,689 tris, static/unrigged, source license CC BY 4.0 | New rig is more animation-capable and lower polygon count, but do not replace until texture/licensing and animation work are addressed |
| Mosin | 28,041-triangle static model with three 4K maps | Current player scene uses procedural placeholder | Candidate viewmodel geometry; texture and scale import, but no rig/moving parts/license |
| PPSH | No incoming file | Existing named static PPSH in licensed WW2 pack; not integrated as player viewmodel | Do not duplicate; no incoming asset to assess |
| Arms | Rigged base FBX and test variant with one generic action clip; texture unbound, scale mismatch, license unresolved | No player arms model | Candidate only after scale, materials, animation suitability, and licensing are resolved |

**Existing soldier texture correction:** 12 existing texture files total **24,504,093 bytes** (approximately 24.5 MB); each is 2048×2048. This corrects the earlier 21.7 MB figure.

## Import validation decision

**Import validation succeeded for the German FBX, Mosin GLB, arms base/test FBX, their PNG dependencies, and the existing static PPSH pack. Blender variants remain unvalidated, no incoming PPSH exists, and all new asset licenses remain unresolved.** The assets are not approved for gameplay integration. Get rights documentation, address texture assignment and arms scale, and plan/obtain appropriate soldier animations before requesting a separate integration approval.

## Asset readiness extension — 2026-11-11

The incoming directory was rescanned. The original 8 downloaded files remain: German soldier FBX + texture; Mosin GLB; first-person arms base/test FBX, two Blender variants and texture. Godot's three extracted Mosin PNGs remain additional generated dependencies. The incoming PPSH directory still contains zero files. Original sources and `assets/all_assets/` were not edited.

### Mosin resolution candidates

Original source images and GLB are preserved. Separate Lanczos-resized PNG candidates were created under `assets/library/readiness_candidates/mosin_nagant/` and imported for measurement. These candidates are not referenced by gameplay.

| Set | Map 0 albedo PNG bytes | Map 1 normal PNG bytes | Map 2 metallic-roughness PNG bytes | Total PNG bytes | Imported `.ctex` total |
|---|---:|---:|---:|---:|---:|
| Original 4096² source set | 20,233,949 | 19,770,817 | 14,741,969 | **54,746,735** | **58,311,424** (prior source cache measurement) |
| `readiness_candidates/mosin_nagant/2k/` | 4,996,659 | 5,533,027 | 3,925,420 | **14,455,106** | **11,391,910** |
| `readiness_candidates/mosin_nagant/1k/` | 1,303,084 | 1,474,190 | 963,071 | **3,740,345** | **2,926,498** |

Godot created `.import` sidecars and `.ctex` cache files for both candidate sets. Cache size fell about **80.5%** for 2K and **95.0%** for 1K compared with the original 4K cache total. The rendered full-weapon comparison replaces only the albedo with its resized candidate and keeps the original normal/metallic-roughness maps; all three candidates in each set were imported and their cache size measured. Visual differences are subtle at full-weapon 1280×720 scale; close-up quality and runtime memory/FPS remain untested. This is a size/quality candidate comparison, not a performance claim.

### New isolated technical findings

- The test arms FBX has a character child root scale of `1.0`; the base FBX child root scale is `0.1`. Import sidecars match. Setting an *outer temporary test instance* to `0.1` gives test bounds `(1.15898, 0.45736, 0.45635)`, matching the base. Four control joints also have materially different rest transforms in the test FBX, so this alone does not make the animation export interchangeable.
- The exact animation clip remains `caucasian_male_1|caucasian_male_1Action`, 2.25 seconds, 43 tracks, non-looping. Five sampled times change the skeleton; rendered frames show clasping/reaching rather than a rifle action.
- The Mosin's one mesh surface exposes 22,570 UV entries. Its `MosinNagant_Mosin_0` node is the only model mesh; bolt, trigger and magazine are not independently animated nodes.
- The arms mesh exposes 4,600 UV entries on its one surface. Soldier and helmet continue to share the same 49-bone skin. The isolated screenshot shows the soldier texture but dark cloth; its binding/UV alignment appears plausible, but the production material result and original texture license remain unresolved.
- Rendered evidence is under `docs/asset_readiness_previews/`. The diagnostic scene/script are `scenes/testing/asset_readiness_diagnostic.tscn` and `scripts/testing/asset_readiness_diagnostic.gd`.

### License and PPSH follow-up

The exact original source and rights for incoming soldier, Mosin and arms files remain unresolved. A title-matched Meshy arms result was not linked to the local files and is not treated as provenance. PPSH listing comparisons and the unavailable authenticated download route are recorded in [PPSH_41_ACQUISITION_REPORT.md](PPSH_41_ACQUISITION_REPORT.md); no candidate was copied or downloaded.

### Preservation and disk observations

D: free space was **8,747,835,392 bytes (8.15 GiB)** at the initial audit, **3,599,327,232 bytes (3.35 GiB)** before importing the six candidate maps, and **3,584,954,368 bytes (3.34 GiB)** after. The candidate texture import itself consumed about 14.4 MB. The preceding multi-gigabyte change accrued during import/render work and was not isolated to a specific cache. Current `assets/all_assets/` counts remain **166 files and 68 `.import` sidecars**, matching the prior inventory. No runtime performance benchmark was performed.
