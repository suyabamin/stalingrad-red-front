# PPSH-41 Acquisition Report

**Research date:** 2026-11-11  
**Project:** Stalingrad: Red Front  
**Incoming folder:** `assets/library/incoming_downloads/ppsh_41/`

## Result

The incoming `ppsh_41/` directory remains empty. No model was downloaded, copied, imported or substituted. The existing static PPSH inside the WW2 weapons pack remains untouched. I did not download through an authentication barrier or treat a search result as proof of file access.

## Owner-specified candidates

| Candidate | Listing evidence | Format / geometry / license | Acquisition result |
|---|---|---|---|
| BlendSwap — PPSH-41 by mattface | Current BlendSwap category pages list the item as “PPSH-41,” Blender 2.6x, and `cc0`. The exact item page/asset ID and archive were not reached. BlendSwap says licenses are uploader-declared and are not independently verified. | Blender source only is indicated; geometry, textures, model authenticity, item-level terms and binary availability were not verified. Blender is not installed and the project Blender importer is disabled. | **NOT VERIFIED / NOT DOWNLOADED.** A CC0 category listing alone does not satisfy the task's item-level license and file-access gate. [BlendSwap listing](https://blendswap.com/3d/submachine), [BlendSwap licensing/download notes](https://blendswap.com/3d-mcp-api). |
| Sketchfab — PPSh-41 by Artem Goyko | Item result describes a PPSH-41 and shows a Download control; 13.5k triangles; “CC Attribution.” No model description is present in the fetched listing result. | Exact license version and file format were not confirmed; no archive or 3D mesh was inspected. Sketchfab's Download API documentation says downloads require an authenticated account. | **LISTING FOUND; FILE ACCESS NOT VERIFIED.** [Artem Goyko listing](https://sketchfab.com/3d-models/ppsh-41-089bdfb09ada407da3e75cfcbe2180fe). |
| Sketchfab — PPSh-41 by Zillious | Item result says game-engine optimized, with separate magazine and trigger; 12.4k triangles; 4096×4096 PBR PNG set; “CC Attribution.” | Exact license-version link, package contents and separable-part hierarchy were not validated from a downloaded file. 4K maps are a concern for the UHD 620 target. | **LISTING FOUND; FILE ACCESS NOT VERIFIED.** [Zillious listing](https://sketchfab.com/3d-models/ppsh-41-5c8a64490fa747389e9cfcaecc69c88a). |

## Alternative lead

The current best technical lead is [PPSH 41 Low-poly by MaX3Dd](https://sketchfab.com/3d-models/ppsh-41-low-poly-d9ee1742732c4aec9c98aeddfb93071c). Its listing says 4.2k triangles, game-ready low-poly geometry and one 2048×2048 PBR texture set; it shows CC Attribution and a NoAI label. Standard CC BY supports commercial use with required attribution, but the exact version/link should be confirmed from the item page/archive before relying on it. The NoAI label must be respected for AI training/data uses; no such use is planned here. A Download control is shown, but Sketchfab documents that model download requests need an authenticated account. I had no authenticated download route, so actual file access, archive contents, silhouette, magazine separation, importability, scale and license file remain unverified.

Other alternatives surfaced in research but were not selected: a 10-year-old Sketchfab model by Thomas with 6.4k triangles but no visible license in the result; and paid ArtStation models. Neither meets the verified-license/no-cost download gate based on the available evidence.

## Why no download occurred

The platform's own [Sketchfab Download API guidelines](https://sketchfab.com/developers/download-api/guidelines) state that downloads require user authentication. The inspected results exposed the listing and license label, not an accessible model archive. No credentials, session cookie or platform account were available. BlendSwap's current website/API likewise uses account-authenticated download access, and the mattface item-level page was not identified. No login or access controls were bypassed.

The task permits acquisition only after the source file is legitimately accessible and the item-level license and contents can be recorded. That threshold was not met, so the responsible outcome is to stop at the leads above. To continue, the owner can download the preferred candidate through the official site and place the original archive/model, texture/material files, license/attribution record and exact source URL in a dedicated child folder of `assets/library/incoming_downloads/ppsh_41/`. The next pass can then validate it in an isolated scene without replacing the existing asset or touching weapon gameplay.

## PPSH-41 comparison

| Lead | Model listing claims | Texture / poly consideration | Confidence today |
|---|---|---|---|
| MaX3Dd (preferred lead) | PPSH 41, low-poly, game-ready | 4.2k triangles; one 2K PBR set | Best stated target fit; actual archive not inspected |
| Artem Goyko | PPSH-41, no description | 13.5k triangles; maps/parts unknown | Listing/license label only |
| Zillious | Game-engine optimized, magazine/trigger separated per listing | 12.4k triangles; 4K PBR maps | More geometry/texture cost; part separation unverified |
| mattface / BlendSwap | PPSH-41 listing; Blender 2.6x; CC0 shown in category | Geometry, textures and materials unknown; Blender unavailable | Lowest item-level verification |

No candidate has passed the requested “genuine model” visual check because none of the actual meshes or archived source files was accessible in this environment. No candidate is included in gameplay or marked as an acquired project asset.

## Phase 2 recheck — 2026-11-11

The incoming folder was re-scanned and remains empty. D: reported 3,564,634,112 bytes free via `cmd /c dir D:\` before further asset work. The MaX3Dd candidate remains an unverified listing: its direct page claims low-poly/4.2k triangles, a 2K PBR set and CC Attribution, with a NoAI label; no archive, exact license version, or mesh was downloaded or inspected. The public listing does not establish the source package contents. Other candidate pages and their limitations are unchanged from this report. No PPSH preview can be produced without an actual candidate file. No authentication barrier was bypassed.
