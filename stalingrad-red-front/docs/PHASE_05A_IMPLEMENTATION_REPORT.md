# Phase 5A — Visual Foundation Correction Report

**Status:** Phase 5A — Mission 01 Visual Foundation: **COMPLETE**. Owner visual review: **APPROVED**. Owner manual gameplay verification: **APPROVED**. Phase 5B is planning complete; implementation has not started.  
**Date:** 2026-11-09  
**Engine/renderer:** Godot 4.7.2, GL Compatibility, Intel UHD 620.

## Why the first pass failed visual acceptance

The prior resources loaded and were assigned, but loading was mistaken for visible improvement. The five 512×512 maps were almost uniform grayscale noise. Their variation disappeared after mipmapping at normal viewing distance. Both brick and concrete shared the same subtle map, and metal used flat albedo. UV scales were low for large surfaces and normalized box UVs stretched the ground texture along the long road axis. The sky and light color edits were also small. This explains why the battlefield still read as flat-colored boxes despite passing import and logic tests.

## Corrections made

- Regenerated all five seamless maps as 256×256 repeatable surfaces with distinct frequency and pattern: compacted earth, damp mud, brick courses/mortar, directional timber grain, and broad irregular river variation. Mipmaps remain enabled. The textures are procedural, original, and contain no external assets.
- Matched UV repetition to each large surface's dimensions. Earth and road no longer stretch along the long axes; road repetition is adjusted to avoid long streaks. Brick has readable course joints at gameplay distance. Water uses broad variation that survives distance filtering.
- Kept a compact shared texture/material set and used surface color/roughness to distinguish families. No custom shader or renderer feature was added.
- Kept the revised subdued blue-gray sky and neutral ambient contribution; the single directional light remains unshadowed. The rendered result has a cool, muted sky against earth/brown masonry and gray concrete.
- No battlefield geometry, project renderer settings, gameplay scripts/logic, dimensions, coordinates, collisions, navigation, spawn positions, triggers, weapons, AI, HUD, or restart behavior were changed.

## Material audit: all 12 shared materials are used

The battlefield builder's `_box()` assigns `material_override` from `EnvironmentMaterialLibrary`; no later procedural assignment overwrites those visible surface materials.

| Shared material | Visible battlefield use | Surface map |
|---|---|---|
| earth | Continuous ground slab | earth_surface.png |
| mud | Landing mud and river shore | mud_surface.png |
| road | Central road slab | earth_surface.png |
| brick | Ruined building shells | masonry_surface.png |
| brick_dark | Dark building shells and roadside masonry | masonry_surface.png |
| concrete | Broken upper walls and cover | earth_surface.png |
| dark_concrete | Building shells and lorry cab | earth_surface.png |
| wood | Pier, supports, beams, street cover, lorry bed, poles | timber_surface.png |
| weathered_wood | Supply crates | timber_surface.png |
| metal | Lorry wheels | Flat dull-metal StandardMaterial3D |
| rusted_metal | Lorry chassis | mud_surface.png |
| water | Volga water slab | water_surface.png |

All five PNGs are referenced by these resources, import successfully with mipmaps, and are sampled by visible surfaces. Metal's flat finish is intentional for the small dull wheel pieces; the rusted chassis uses the mud map and a warmer brown, rough material response. Box meshes use opaque `StandardMaterial3D`, albedo textures, roughness and UV scaling supported by the project's Compatibility renderer. No advanced renderer-only material features are used.

## Render evidence

Captured the actual Mission 01 main scene using the non-headless Godot 4.7.2 GL Compatibility renderer on the Intel UHD 620. The capture helper places the existing first-person camera at the listed route positions and saves the rendered viewport at 1280×720. The images were opened and visually inspected.

| View | Capture |
|---|---|
| Volga landing | [phase5a_volga_landing.png](phase5a_volga_landing.png) |
| Battlefield transition | [phase5a_battlefield_transition.png](phase5a_battlefield_transition.png) |
| Ruined street | [phase5a_ruined_street.png](phase5a_ruined_street.png) |
| Close-up: ground, road and building detail | [phase5a_closeup_ground_road_building.png](phase5a_closeup_ground_road_building.png) |

The captures show mottled earth/mud, a weathered mottled road without the earlier stretched longitudinal streaking, visible brick/mortar courses, rough neutral concrete, and broad muted water variation. These are rendered views, not synthetic previews. No original baseline screenshots were present in the project, so a side-by-side baseline comparison was unavailable.

## Verification and owner review

The final verification rerun is recorded in `PHASE_05A_TEST_REPORT.md`: all four runtime harnesses passed with their expected counts and exit code 0. Five current PNG source hashes match Godot's imported cache metadata; mipmaps are enabled. Both F5 Mission 01 and F6 Enemy Test Range launched non-headlessly with exit code 0 on the Compatibility renderer, with no missing-resource or project-script errors observed. The visual captures were opened and inspected by the coding agent. Owner visual review and manual gameplay verification are APPROVED. These approvals are owner-reported; no additional tests are claimed.

Godot reports inability to read the Windows root certificate store and inability to write its default `user://logs` / editor settings outside the workspace. Those environment warnings did not prevent imports, rendered capture, startup, or harness completion. Phase 4B reports one OS mouse-capture check as NOT TESTED under headless execution; it is not a failed assertion. No target-hardware frame-time, GPU, or memory profile was measured.

## Phase boundary

Phase 5A — Mission 01 Visual Foundation is **COMPLETE**. Phase 5B planning is **COMPLETE**; implementation is **NOT STARTED**. Proceed with Phase 5B only after separate owner authorization.
