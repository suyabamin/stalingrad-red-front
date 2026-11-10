# 3D Asset Import Validation Report

**Project:** `D:\Stalingrad Red Front\stalingrad-red-front`
**Validation date:** 2026-11-11
**Godot:** 4.7.2, Compatibility renderer (Intel UHD Graphics 620 during rendered preview)
**Scope:** Approved import validation only. No gameplay integration was started.

## Executive summary

Godot successfully imported the incoming German soldier FBX, Mosin GLB, first-person arms base/test FBX, and their available PNGs. The imported soldier has a usable 49-bone skin; the arms have a 62-bone skin and one working generic animation clip. Mosin’s three material maps load and render. The incoming PPSH folder is empty; the existing static PPSH pack was inspected without copying or replacing it.

Important integration blockers remain: licenses are unresolved for every incoming asset; soldier and arms FBX materials do not bind their separate color textures; no German soldier animation clips are supplied; the arms test FBX is scaled 10× larger than the base FBX; Blender variants could not be imported; and there is no incoming PPSH model. This report does not authorize or begin integration.

The detailed manifest, bone results, material maps, sizes and existing-asset comparison are in [DOWNLOADED_3D_ASSET_INVENTORY.md](DOWNLOADED_3D_ASSET_INVENTORY.md).

## Import status by asset

| Asset | Import result | Inspection outcome |
|---|---|---|
| `german_soldie/LowpolySoldier/LowpolySoldier.fbx` | **Success** | 2 skinned meshes, 5,075 triangles, 49-bone `Skeleton3D`; no `AnimationPlayer`/clips. Meshes render. FBX StandardMaterial3D surfaces have no texture maps bound. |
| `LowpolySoldier_Texture.png` | **Success** | 1710×2048. In an isolated test-only override it maps plausibly to soldier skin/uniform; actual FBX surfaces do not reference it. |
| `mosin_nagant_lowpoly.glb` | **Success** | 1 static mesh, 28,041 triangles, one material, no skeleton/animation. Imported bounds `(0.079878, 0.376333, 1.290656)`; length lies along Z. |
| Mosin embedded map 0 | **Success** | Extracted as 4096×4096 PNG and loaded as albedo/base color. |
| Mosin embedded map 1 | **Success** | Extracted as 4096×4096 PNG and loaded as normal map. |
| Mosin embedded map 2 | **Success** | Extracted as 4096×4096 PNG and loaded as metallic-roughness map for metallic and roughness channels. |
| `FPS ARMS RIG 1.fbx` | **Success** | One skinned 8,152-triangle mesh; 62-bone skeleton; no animation player/clips. Imported bounds `(1.15898, 0.45736, 0.45635)`. Material has no map bound. |
| `FPS ARMS RIG 1 test.fbx` | **Success** | Same named 62-bone hierarchy and mesh; exact clip below. Imported bounds `(11.5898, 4.573602, 4.5635)`, 10× the base FBX. Material has no map bound. |
| `new_diff.png` | **Success** | 1024×1024. A diagnostic-only override visibly applies it to the arms and hands; actual FBX material is untextured. |
| `FPS ARMS RIG 1.blend` | **Not imported / blocked** | Blender v273 header. Godot project has `filesystem/import/blender/enabled=false`; no Blender executable was found. File contents and links were not independently validated. |
| `FPS ARMS RIG 1 test anim.blend` | **Not imported / blocked** | Blender v273 header. Same blocker. Static strings are not a substitute for opening the scene in Blender. |
| Incoming `ppsh_41/` | **No asset** | Directory contains zero files. |
| Existing Soviet WW2 weapon pack PPSH | **Loaded for inspection** | Existing static body/magazine selection: 3 mesh pieces, 3,544 triangles, `Wood_Parts` and `BlackMetalParts`, bounds `(1.205566, 0.462338, 0.222118)`. No copy or replacement made. |

All new asset license/attribution status is **unresolved**. No incoming license/readme/credit files were found. The existing weapon pack has a separate CC BY 4.0 license for J.AkioHonda; it does not cover the incoming assets.

## Skeleton, skinning, and animation

### German soldier FBX

Godot reports a `Skeleton3D` with 49 bones. The central hierarchy is `Hips → Spine → Spine1 → Spine2 → Neck → Head`; branches include shoulders, arms, forearms, hands, legs, feet and toes. Both hands include thumb, index and middle-finger chains; ring and pinky bones are absent. `Soldier_1` (4,829 triangles) and `Helmet` (246 triangles) both have a `Skin` and point to the imported skeleton.

The imported soldier displays in a static T-pose and has no animation player or clips. A test-only 35-degree `LeftArm` bone rotation changed the skeleton’s global pose and visibly moved the rendered arm, confirming the skin-deformation path. This is a one-off diagnostic pose, not a created animation clip. The skeleton could support future authored/retargeted aim/fire/death work, but no such clips are included or validated.

### First-person arms FBX

The base FBX contains 62 bones: right and left clavicle/deltoid/upper-arm/forearm chains, hand controls and hand roots, plus thumb, index, middle, ring and pinky chains on each hand. Its single mesh has a `Skin` bound to that skeleton. The base FBX has no clips.

The test FBX exposes exactly one clip: **`caucasian_male_1|caucasian_male_1Action`**, **2.250000 seconds**, 43 tracks, non-looping. The isolated test played/seeks it and observed a changed skeleton pose (`pose_changed=true`). The clip is generic and does not establish a firing, reload, or weapon-grip animation. Its scene dimensions are 10× the base FBX dimensions, so these exports are not drop-in interchangeable without resolving scale and confirming root transforms.

### Mosin and PPSH

Neither weapon model has a skeleton or animation. Mosin geometry is static; bolt, magazine, recoil, and reload motion are not present. The existing PPSH body and magazine are static meshes.

### License status

| Asset | License status |
|---|---|
| German soldier FBX + PNG | Unresolved; no license/attribution file supplied |
| Mosin-Nagant GLB and embedded maps | Unresolved; no license/attribution file or GLB copyright metadata |
| First-person arms FBX/Blend variants + PNG | Unresolved; no license/attribution file supplied |
| PPSH-41 incoming asset | No file present; no license to assess |
| Existing static PPSH pack (separate asset) | CC BY 4.0, J.AkioHonda, per its existing `license.txt` |

## Texture, material, scale, and rendering checks

- The Mosin `Mosin` StandardMaterial3D references all three loaded 4096×4096 maps. The isolated Compatibility-renderer preview shows the weapon and its wood/metal surface. Its imported bounds are about 1.291 m long, 0.376 m high and 0.080 m deep, with the long axis along Z. It appears to be a plausible static viewmodel-sized asset, but player-camera placement, clipping, grip, muzzle location, and switching were not tested.
- The soldier’s source texture is 1710×2048 and visibly maps in a diagnostic material override. The source FBX import created StandardMaterial3D materials with no maps assigned. The overridden preview shows an upright T-pose model; this is diagnostic only and does not change the imported source material.
- The arms texture is 1024×1024 and visibly maps in a diagnostic override. Source FBX material has no assigned maps. The base mesh has plausible viewmodel-sized bounds; no attachment to the existing `Camera3D`, clipping test, or weapon grip was performed.
- The existing PPSH model renders in isolation. The separate magazine/body remain static; its approximately 1.206 m long bound needs scale/fit confirmation if later used as a viewmodel.
- The imported soldier is 5,075 triangles; arms are 8,152; Mosin is 28,041. Mosin has three 4K textures. Their source payload totals 54,746,735 bytes; Godot’s generated `.ctex` files total 58,311,424 bytes, have mipmaps enabled, and report `vram_texture=false`. UHD 620 shared-memory use may be high. No runtime FPS or GPU-memory benchmark was performed. A downscaled derivative should be evaluated only in a separately approved implementation stage, keeping originals intact.

Rendered previews and 512×512 texture review images are in ignored `.godot/tmp/asset_previews/`. The isolated diagnostic texture overrides are applied only to temporary scene instances. The runtime asset files themselves were not altered.

## Isolated validation setup and results

Created `scenes/testing/asset_import_validation.tscn` and `scripts/testing/asset_import_validation.gd`. The helper loads each imported `PackedScene`, counts meshes/triangles/surfaces, inspects `Skeleton3D`/bone parent links and animation names/durations, checks material texture slots, tests soldier skin deformation with a temporary bone pose, tests the arms clip’s pose change, and creates rendered/texture previews. It also inspects and renders only the existing PPSH/magazine nodes from the existing pack.

Commands used:

```text
Godot_v4.7.2-stable_win64.exe --headless --editor --path . --import
Godot_v4.7.2-stable_win64.exe --headless --path . --scene res://scenes/testing/asset_import_validation.tscn
Godot_v4.7.2-stable_win64.exe --path . --scene res://scenes/testing/asset_import_validation.tscn
```

The import scan processed the incoming FBX/GLB/PNG sources. Validation scene exited **0** with `ASSET_IMPORT_VALIDATION_FAILURES=0`. The normal Compatibility-renderer run visibly rendered the soldier, Mosin, arms, and selected PPSH. Headless mode skips image capture because it has no render viewport; it still inspects scene data and animation state.

Observed environment/debugger output: Godot could not write `user://logs` and could not read the Windows root certificate store. The non-headless renderer also reported `Condition "f.is_null()" is true` from `drivers/gles3/shader_gles3.cpp:648` during shader-cache writes while displaying 4K assets; the models/textures still rendered. The headless dummy renderer logged a null-material diagnostic while processing preview nodes. These errors are documented; their root cause was not established. No FBX/GLB import failure or GDScript error remained in the successful validation run.

Before import, `assets/all_assets/` contained 166 files and 68 `.import` sidecars; those counts were unchanged after the scan. No source asset was moved, renamed, or overwritten. Godot added import sidecars and extracted Mosin image dependencies under the incoming folder, and imported cache data under `.godot/imported`.

## Missing items and next steps

1. Obtain license/attribution terms for the soldier, Mosin, and arms assets before any redistribution or integration decision.
2. For the soldier, decide whether to source suitable idle/walk/run/aim/fire/reload/death animations or commission/author them for this 49-bone rig. Preserve the existing enemy visual until separately approved.
3. Bind and validate the soldier albedo PNG to both imported materials in a future approved integration step.
4. For arms, inspect both `.blend` files in a compatible Blender installation, document their actual actions and materials, and resolve the 10× FBX variant scale mismatch. Confirm hand poses match each intended weapon.
5. Bind and validate the arms texture. Test camera position, clipping and visibility only after a separate integration approval.
6. For Mosin, review 4K cost and benchmark a derived lower-resolution texture set before any gameplay use; verify muzzle, grip and camera fit later without changing weapon mechanics.
7. Provide the missing PPSH source folder if a new PPSH model is intended. Otherwise review the existing static licensed pack asset separately; do not duplicate it.
8. Only after reviewing this report, provide explicit approval for any game-scene or weapon/enemy integration.

## Scope boundary

This work stopped after import validation. Mission 01, Enemy Test Range, player/weapon/enemy scripts, objectives, navigation and existing models were not modified. No owner F5/F6 gameplay or manual acceptance test was claimed. No files were staged or committed, and the parent README conflict was not changed.
