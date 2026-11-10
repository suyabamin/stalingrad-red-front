# Phase 2 — Asset Acquisition & Animation Development Report

**Date:** 2026-11-11  
**Project:** `D:\Stalingrad Red Front\stalingrad-red-front`  
**Engine/renderer:** Godot 4.7.2 / Compatibility  
**Target:** Intel UHD 620, 1280×720  
**Scope:** Verified licensing, acquisition research, isolated asset preparation and tests. Gameplay integration was not authorized and was not performed.

## Executive summary

**Overall: BLOCKED for production-ready asset clearance; CONDITIONAL PASS for technical preparation and isolated checks.** The current incoming soldier, Mosin and arms files still have no verified creator/source match or local license. No new model or animation package was acquired. The incoming PPSH folder remains empty. Official listings identify Quaternius's Universal Animation Library as CC0 and Mixamo's official FAQ permits its characters/animations in commercial games, but no animation files were downloaded, so no specific clip names, rig mapping, duration, looping or weapon poses were tested.

I re-ran the existing isolated asset diagnostic and captured a refreshed 1280×720 preview set in `docs/asset_readiness_previews/phase2/`. The soldier is now fully framed in front and side views. Its temporary arm-deformation capture is diagnostic only. The arms clip remains a generic clasp/reach motion, not a weapon animation. Mosin 2K/1K source derivatives remain available; the comparison captures resize only the albedo for visual display and do not test complete 2K/1K PBR sets side by side.

## Work package results

| Work package | Result |
|---|---|
| A — Licenses | **UNRESOLVED** for incoming soldier, Mosin and arms. Official animation-library terms have been researched; no clips acquired. |
| B — German soldier | **BLOCKED** for the eight requested rifle animations. 49-bone weighted rig verified, but no clips, weapon mount, two-handed grip, or licensed source package. |
| C — Arms | **CONDITIONAL PASS** for isolated rig/material inspection. The test FBX scale discrepancy traces to the imported character child transform; different control-bone rest poses prevent treating 0.1 normalization as an interchangeable correction. No weapon poses or real-player-camera fit verified. |
| D — Mosin | **CONDITIONAL PASS** as static asset and derivative texture candidates. Original GLB/maps preserved. No bolt articulation or actual camera/grip fit. |
| E — PPSH | **BLOCKED**. No model acquired. Public candidate listings do not satisfy the task's actual-file/license/geometry verification gate. |
| F — Compatibility | **NOT TESTED** for soldier+rifle, arms+Mosin and arms+PPSH. No hand-fit or combined weapon preview was fabricated. |
| G — Visuals | **CONDITIONAL PASS** for revised diagnostic captures: full-body front/side and sample asset views saved. No aiming/firing/weapon grip/PPSH images exist because no compatible clips or PPSH file were validated. |
| H — Performance | **PARTIAL**. Triangle counts and imported texture cache sizes recorded; no matched runtime FPS, GPU-time or VRAM benchmark. |

## Project asset architecture audit

The project selects the Mission 01 main scene and Compatibility renderer in `project.godot`; Blender import remains disabled. Existing organized 3D assets include a separate Wehrmacht GLTF under `assets/library/characters/german/wehrmacht_soldier/`, Soviet weapon assets under `assets/library/weapons/soviet/`, and the Phase 5B environment assets under `assets/models/phase_5b/`. The existing Wehrmacht asset has its own local CC BY 4.0 `license.txt`; it is not the incoming FBX and does not establish that FBX's provenance. The existing GLTF source scan found no `skins` or `animations` declarations, so it is not a source of existing humanoid animation clips. An `assets/library` scan found no standalone `.anim`/`.animation` resources. Existing player and enemy animation/gameplay files were left untouched. `assets/all_assets/` remained 166 files and 68 import sidecars after testing.

## Acquisition and license findings

- No new model or animation file was acquired. The source identity and usage rights for the local soldier FBX/texture, Mosin GLB/maps, and arms files remain **UNRESOLVED**; filenames, imported node names and similar listings do not establish provenance.
- Quaternius's [Universal Animation Library listing](https://quaternius.itch.io/universal-animation-library) identifies 120+ retargetable animations, including combat/gun categories, a free 15 MB Standard ZIP, and CC0 terms. This is a **verified listing and candidate only**; the package was not downloaded or inspected.
- Adobe's [official Mixamo FAQ](https://helpx.adobe.com/creative-cloud/faq/mixamo-faq.html) says characters and animations may be used in personal, commercial and non-profit projects including video games. The page was last updated 2021; no specific Mixamo clip was acquired or evaluated.
- No free PPSH file met the task's verified asset gate. See [PPSH_41_ACQUISITION_REPORT.md](PPSH_41_ACQUISITION_REPORT.md) for candidate listing evidence and access limitations.
- `ASSET_LICENSE_REGISTER.md` was updated with the Quaternius candidate and its acquisition status.

## Visuals and measurements

The corrected captures are in [asset_readiness_previews/phase2](asset_readiness_previews/phase2/). All non-headless images were saved at 1280×720. The front/side soldier views are full-body. The supplied uniform texture still appears very dark. The five arms frames show one 2.25-second generic hand-to-hand action; the hands close together without a rifle. The Mosin comparison has 4K, 2K-albedo-preview and 1K-albedo-preview views; source normal and metallic-roughness maps remain from the original material in those comparison renders.

The original Mosin material cache was measured at 58,311,424 bytes. The complete three-map 2K and 1K candidate cache totals were measured at 11,391,910 and 2,926,498 bytes. This is an imported-cache comparison only, not proof of equal GPU residency or frame-rate gain. No performance benchmark was run.

Disk space was 3,564,634,112 bytes free at the pre-import check and 3,563,896,832 bytes free after the Phase 2 diagnostic/import/tests (approximately 3.32 GiB). `assets/all_assets/` was re-counted at 166 files and 68 `.import` sidecars after the checks.

## Validation and preservation

The isolated readiness diagnostic, existing import-validation scene, and headless editor import completed with exit code 0. Re-run regressions passed sequentially: Phase 3B 28, Phase 4A 12, Phase 4B 39, Phase 4C 56, Phase 5C 35 (**170 passed, zero reported failures**). Automated scene assertions do not establish manual game acceptance or native OS mouse capture. Godot logged its existing user-log/certificate/editor-settings write issues and headless dummy-renderer null-material diagnostics; no project-level root cause was established.

At the final scope check, `assets/all_assets/` remained at 166 files and 68 `.import` sidecars. No original incoming model/texture was edited, no gameplay file was edited for this task, the parent `README.md` conflict remains unresolved, and no new stage/commit operation was made. The working tree already had staged changes before this work; the initial staged state was preserved.

## Remaining blockers and next step

1. Obtain original download URLs/creator records/licenses for the three incoming categories; retain license files with the assets.
2. Download a verified, rights-cleared animation package through its official public route (without bypassing authentication), then inspect exact clip names and export format.
3. Retarget and render genuine idle/walk/run/aim/fire/reload/hit/death clips against the soldier skeleton; verify two-handed rifle contact and muzzle alignment before calling them compatible.
4. Resolve arms base/test hierarchy/rest-pose differences, then fit each weapon in a separate camera scene and inspect clipping.
5. Acquire a genuine PPSH file with verified terms and inspect its downloaded geometry and parts.
6. Benchmark matched 4K/2K/1K material sets and record actual frame/GPU data if tooling allows.

No gameplay integration is approved by this report. See the per-package reports for detail. The next milestone should remain isolated asset validation until the rights and actual-file blockers are resolved.
