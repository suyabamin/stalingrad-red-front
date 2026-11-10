# Stalingrad: Red Front — Comprehensive Asset Inventory

**Project Directory:** `D:\Stalingrad Red Front\stalingrad-red-front`  
**Master Asset Source:** `D:\Stalingrad Red Front\stalingrad-red-front\assets\all_assets`  
**Audit Date:** 2026-11-10  
**Target Engine & Renderer:** Godot 4.7.2 stable, GL Compatibility (OpenGL 3.3.0)  
**Target Hardware Baseline:** Intel(R) UHD Graphics 620, 16 GB RAM, 1280×720  

---

## 1. Executive Summary

A complete recursive audit was performed on every file and directory in `assets/all_assets`. 

The source directory contains:
- **12 Subdirectories** containing 3D models, PBR textures, materials, and licenses.
- **11 Root Files** including 6 audio recordings, 1 GLB model pack, and 4 incomplete browser downloads (`.crdownload`).
- **Total Physical Footprint:** ~201.2 MB across 58 files.

---

## 2. 3D Model & Environment Asset Inventory

| Asset Name / Path | Format | Vertices | Triangles | Meshes | Mats | Total Size | Rig / Skeleton | WWII 1942 Relevance | UHD 620 Suitability | Status / Recommendation |
|---|---|---:|---:|---:|---:|---:|---|---|---|---|
| **`ww2_german_wehrmacht_soldier`** | glTF 2.0 (Embedded/Bin) | 21,788 | 38,689 | 4 | 4 | 1.85 MB | Static mesh (No rig in glTF) | **Direct Fit** (WWII German M40/M36 uniform, helmet, webbing, boots) | **Excellent** (~38k tris) | **INTEGRATE** as high-fidelity German infantry visual representation. |
| **`ww2_german_wehrmacht_soldier (1)`** | glTF 2.0 | 21,788 | 38,689 | 4 | 4 | 1.85 MB | Static mesh | Direct Fit | Excellent | **DUPLICATE** of above. Keep in source, do not duplicate in library. |
| **`ww2_low_poly_weapons_pack`** | glTF 2.0 | 42,571 | 21,679 | 62 | 29 | 1.66 MB | Static props | **Direct Fit** (Includes PPSH-41, Stielhandgranate, STG-44, Mauser C96, TT-33, M1 Garand, knives, ammo) | **Excellent** (<22k tris for 12+ weapons) | **INTEGRATE** weapons, magazines, and stick grenades into game props & visual models. |
| **`german_stick_grenades_pack.glb`** | GLB (Binary glTF) | 5,911 | 6,888 | 16 | 3 | 11.08 MB | Static props | **Direct Fit** (Model 24 Stielhandgranate bundles & single sticks) | **Excellent** (<7k tris) | **INTEGRATE** as battlefield shoulder debris & defensive props. |
| **`low-poly_pz.kpfw._i_ausf._a`** | glTF 2.0 | 105,383 | 36,280 | 7 | 2 | 3.65 MB | Static / modular turret | **Direct Fit** (German Panzer I Ausf. A light tank, operational in Eastern Front) | **Excellent** (~36k tris) | **INTEGRATE** as destroyed/knocked-out tank landmark on street/transition. |
| **`low-poly_pz.kpfw._i_ausf._a (1)`** | glTF 2.0 | 105,383 | 36,280 | 7 | 2 | 3.65 MB | Static / modular turret | Direct Fit | Excellent | **DUPLICATE** of above. Keep in source, do not duplicate in library. |
| **`low_poly_hs-129`** | glTF 2.0 | 19,018 | 10,516 | 18 | 12 | 0.73 MB | Static aircraft | **Direct Fit** (Luftwaffe Henschel Hs 129 ground attack plane used at Stalingrad) | **Excellent** (10.5k tris) | **INTEGRATE** as crashed aircraft scenery on Volga bank / transition shoulder. |
| **`city_ruins_environment`** | glTF 2.0 + PNGs | 128,197 | 55,992 | 10 | 2 | 6.53 MB | Static modular | **High Fit** (Destroyed urban concrete walls, rebar, shattered facades) | **Good** (~11k tris per ruin piece) | **INTEGRATE** modular ruined street walls & masonry piles into Area B and C. |
| **`rock_09_2k.gltf`** | glTF 2.0 + 2K maps | 6,628 | 12,416 | 1 | 1 | 0.28 MB | Static rock | **Neutral Fit** (Natural riverbank rock formation) | **Excellent** | **INTEGRATE** into Volga River Landing embankment. |
| **`Sign003_1K-JPG`** | 1K PBR Maps + Blend | N/A | N/A | N/A | 1 | 3.79 MB | PBR Material | **High Fit** (Weathered painted metal enamel sign) | **Excellent** | **INTEGRATE** as authentic wartime warning/shoulder signage material. |
| **`aleppo_destroyed_building_front (1)`** | glTF 2.0 | 1,295,449 | 431,816 | 20 | 1 | 49.45 MB | Static mesh | **Anachronistic** (Modern Syrian Middle-Eastern architecture) | **Unfavorable** (431k tris for one facade; CC-BY-NC-SA) | **EXCLUDE from game**. Archive under `_review_required`. |
| **`destroyed_buildings_after_russian_attack`** | glTF 2.0 | 1,849,624 | 657,064 | 32 | 4 | 64.02 MB | Static photogrammetry | **Anachronistic** (Modern 2022 Ukraine photogrammetry) | **Unfavorable** (657k tris exceeds frame budget for mobile GPU) | **EXCLUDE from game**. Archive under `_review_required`. |
| **`low_poly_colt_m4a1`** | glTF 2.0 | 8,834 | 7,807 | 5 | 4 | 0.37 MB | Static weapon | **Completely Anachronistic** (Modern 1990s US Colt M4A1 assault rifle) | N/A | **EXCLUDE from game**. Archive under `_review_required`. |

---

## 3. Audio Asset Inventory

| File Name | Format | Channels / Rate | Bit Depth | Size | Audio Content / Role | Recommendation |
|---|---|---|---|---|---|---|
| **`579531__coolabc__ppsh-shooting.wav`** | RIFF WAV | 2 Ch (Stereo), 44.1 kHz | 16-bit PCM | 97.6 KiB | Authentic rapid automatic PPSH-41 submachine gun fire burst. | **INTEGRATE** as primary PPSH-41 firing audio stream. |
| **`370345__zott820__mosin-nagant-bolt-action-cycle.wav`** | RIFF WAV | 2 Ch (Stereo), 48.0 kHz | 16-bit PCM | 2.60 MiB | Authentic Mosin-Nagant 91/30 bolt lift, pull, chamber, and lock cycle. | **INTEGRATE** as primary Mosin-Nagant reload audio stream. |
| **`338240__lubini__battle-in-the-forest-mosin-vs-mauser-ww2.wav`** | RIFF WAV | 2 Ch (Stereo), 48.0 kHz | 24-bit PCM | 3.65 MiB | Authentic WWII Mosin-Nagant rifle gunshot reports with forest reverberation. | **INTEGRATE** (converted to 16-bit standard PCM) as Mosin-Nagant fire sound. |
| **`232644__mensageirocs__environment-war-4.wav`** | RIFF WAV | 1 Ch (Mono), 22.05 kHz | 16-bit PCM | 606.6 KiB | Muffled distant battlefield artillery, rolling explosions, and distant conflict. | **INTEGRATE** as 3D spatial distant artillery / battlefield sound. |
| **`sfxmint-impact-gunshot-10.mp3`** | MP3 | 2 Ch (Stereo), 44.1 kHz | VBR MP3 | 32.3 KiB | Sharp bullet impact / penetration on masonry and soil. | **INTEGRATE** as hitscan bullet impact sound. |
| **`182790__qubodup__sniper-fire.flac`** | FLAC | 2 Ch (Stereo), 44.1 kHz | 24-bit FLAC | 321.5 KiB | High-caliber sniper rifle shot with acoustic crack and tail. | Convert / supplement sniper sound library. |

---

## 4. Incomplete / Corrupted Files Identified

| File Name | Size | Magic Bytes | Identified Status | Action |
|---|---|---|---|---|
| `Unconfirmed 106174.crdownload` | 1,009,134 bytes | `glTF` | Incomplete Google Chrome download of a binary glTF file. | Quarantine in `_review_required`. |
| `Unconfirmed 490019.crdownload` | 35,361,457 bytes | `PK` (ZIP) | Incomplete Chrome download of a ZIP archive. Missing End of Central Directory record. | Quarantine in `_review_required`. |
| `Unconfirmed 765005.crdownload` | 2,575,883 bytes | `PK` (ZIP) | Incomplete Chrome download of a ZIP archive. Missing End of Central Directory record. | Quarantine in `_review_required`. |
| `Unconfirmed 869664.crdownload` | 28,688,195 bytes | `PK` (ZIP) | Incomplete Chrome download of a ZIP archive. Missing End of Central Directory record. | Quarantine in `_review_required`. |

---

## 5. Duplicate Assets Identified

1. `low-poly_pz.kpfw._i_ausf._a (1)` is byte-for-byte identical to `low-poly_pz.kpfw._i_ausf._a`.
2. `ww2_german_wehrmacht_soldier (1)` is byte-for-byte identical to `ww2_german_wehrmacht_soldier`.

---

## 6. Compatibility & Rendering Budget Assessment

The Intel UHD 620 GL Compatibility target renderer requires low draw calls, modest texture memory, and opaque forward shading:
- **Geometry Budget:** The 5 approved visual models (Panzer I tank, Hs-129 plane, Wehrmacht soldier, City ruins pieces, Stick grenades) add ~140k total triangles combined across the entire 120-meter route. When placed selectively and instanced, they fit cleanly within the 200k triangle budget.
- **Excluded Assets:** Aleppo building front (431k tris) and Russian attack buildings (657k tris) exceed total scene budget on their own and are historically anachronistic; they must NOT be integrated into the active scene.
