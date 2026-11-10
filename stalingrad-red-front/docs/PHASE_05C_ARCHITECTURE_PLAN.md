# Phase 5C — Advanced Battlefield Atmosphere & Environmental Storytelling

**Status:** Planning proposal only — implementation has not started  
**Planning date:** 2026-11-10  
**Target:** Godot 4.7.2, GL Compatibility, 1280 × 720, Intel UHD 620-class modest hardware

## 1. Purpose and boundaries

Phase 5C is one presentation milestone with four coordinated work packages: atmospheric environment, environmental storytelling, lighting, and environmental sound. Its purpose is to make the existing Mission 01 battlefield feel more inhabited by recent combat while retaining the clear route and readable enemy combat from Phase 5B.

The implementation boundary is the presentation layer. No player, weapon, enemy, objective, mission, navigation, or gameplay logic should be changed. New environmental objects must be render-only and audio emitters must not use collision. The existing Phase 5B assets, placements, materials, and lighting work remain the starting point and are not removed or replaced wholesale.

## 2. Current architecture assessment

- `project.godot` selects `scenes/main/main.tscn`, Godot 4.7 / GL Compatibility, and the existing Settings, Game, and Mission autoloads.
- `scenes/main/main.tscn` owns the current `WorldEnvironment`, procedural sky, ambient light and single directional light. Directional real-time shadows are disabled. The player, HUD, battlefield builder, and encounter manager are composed here.
- `scripts/environment/battlefield.gd` procedurally builds the continuous ground, road, shore, facades, debris, props, existing Phase 5B asset instances, navigation region, and objective trigger nodes. It is also the likely placement layer for static shoulder dressing, but its route and gameplay geometry must remain unchanged.
- `scripts/environment/environment_material_library.gd` exposes shared opaque environment materials. Tiling surface images are under `assets/textures/environment/`; Phase 5B models and their source files/licenses are under `assets/models/phase_5b/`.
- `resources/missions/mission_01.tres` and `resources/missions/encounters/*.tres` own ordered objective and encounter data. The connected navigation corridor is hand-authored in the battlefield builder. The 3B and 4A–4C test scenes cover combat, movement/integration, objectives, death/restart and encounter navigation.
- `scripts/weapons/weapon_base.gd` already creates `AudioStreamPlayer3D` children for weapon fire, reload, empty, and impact sounds. `resources/weapons/*.tres` expose optional streams, but the project has no bundled environmental sound library or ambient audio scene. Weapon playback currently uses the default bus.
- The Phase 5B reference sample reports 1,200 frames at 1280 × 720 on Intel UHD 620: median 10.014 ms, P95 11.013 ms, P99 12.048 ms, maximum 14.433 ms. This is a short reference sample, not a guaranteed frame rate or a long thermal test. Draw-call and audio-memory baselines were not recorded; collect them before choosing final effects.

Godot 4.7 documents depth/height fog as supported by Compatibility, while volumetric fog and FogVolume are Forward+ only. Therefore this plan uses Environment depth/height fog and excludes volumetric fog. Compatibility targets older hardware and real-time shadowed lights can add rendering passes, supporting the existing no-real-time-shadow choice. [Godot 4.7 Environment feature support](https://docs.godotengine.org/en/4.7/tutorials/rendering/renderers.html), [Godot rendering architecture](https://docs.godotengine.org/en/4.7/engine_details/architecture/internal_rendering_architecture.html)

## 3. Proposed project changes (for a later authorized implementation)

These are proposed paths, not files created by this planning task:

| Area | Proposed files / integration |
|---|---|
| Environment | Externalize the current environment settings into `resources/environment/phase_5c_environment.tres`; reference it from `scenes/main/main.tscn`. Preserve the current procedural sky, ambient color, and light direction as the baseline, tuning them only after screenshot comparison. |
| Atmosphere | Add `scenes/environment/phase_5c_atmosphere.tscn` with a small number of `CPUParticles3D` dust emitters and fixed, subtle smoke plumes. Add shared process/material resources in `resources/environment/atmosphere/`. Parent this presentation-only scene under the existing world/battlefield. No per-frame particle-spawn script. |
| Story props | Add a small number of render-only static GLB scenes under `assets/models/phase_5c/` only where existing Phase 5B props cannot meet the visual goal. Place visual instances at reviewed roadside shoulder slots via a dedicated `scenes/environment/phase_5c_story_dressing.tscn` or a presentation-only section in the battlefield builder. Do not move or replace Phase 5B assets. Do not add collision, navigation obstacles, triggers, or script behavior. |
| Audio | Add compressed, loop-edited audio sources under `assets/audio/environment/`, an `Environment` bus in `default_bus_layout.tres`, and `scenes/environment/phase_5c_soundscape.tscn`. Use a low-level non-positional wind bed and a few fixed `AudioStreamPlayer3D` distant combat/artillery sources with explicit max distance and attenuation. Audio players attach to presentation nodes only. |
| Optional audio controller | Prefer static loops and authored stream resources. Add `scripts/environment/phase_5c_soundscape.gd` only if randomized timing or per-area fades prove necessary. It may manage presentation audio only; it must not inspect mission state, change player state, or alter weapon playback. |
| Verification | Add an isolated `scenes/testing/phase_05c_presentation_check.tscn` and `scripts/testing/phase_05c_presentation_check.gd` only if scene/resource checks cannot be covered by existing harnesses. Add a performance sampler under `scripts/testing/` that measures and reports, never modifies gameplay. |

Avoid modifying `scripts/player/`, `scripts/weapons/`, `scripts/enemies/`, `scripts/missions/`, mission/encounter resources, objective triggers, or the route/collision/navigation builder logic. The only existing-scene integrations should be adding presentation child scenes and assigning the extracted Environment resource. New detail is static and render-only. Keep one DirectionalLight3D and no real-time shadows.

## 4. Work packages

### Work package 1 — Atmospheric environment

1. Create a before baseline using identical player-height camera views in the landing, transition, and street. Record the current environment values and frame-time counters before tuning.
2. Use a subtle depth/height fog tint matched to the existing sky and ground. Tune start/end distances so it gives distant facades separation without veiling close enemies, the reticle, HUD, or objective markers. Avoid a full-screen gray wash.
3. Add wind-driven dust as low-opacity, small `CPUParticles3D` sprites with slow lateral drift. Use a few fixed emitters behind/alongside the route, not a dense cloud in the player camera. Particles have no collision, physics, or damage behavior.
4. Add no more than three small, distant smoke plumes with slow motion and low opacity. Keep them behind building silhouettes; do not use dense particle collisions, trails, subemitters, or complex custom shaders.
5. Add a quality fallback that disables smoke and lowers dust count while keeping the depth fog and baseline lighting. The fallback should be a presentation setting, not a new gameplay option.

Compatibility supports depth/height fog but not volumetric fog; `CPUParticles3D` motion is CPU-simulated, so active particle count must remain small and measured. [Godot 4.7 renderer feature comparison](https://docs.godotengine.org/en/4.7/tutorials/rendering/renderers.html), [Godot 4.7 CPU particle behavior](https://docs.godotengine.org/en/4.7/tutorials/shaders/shader_reference/particle_shader.html)

### Work package 2 — Environmental storytelling

1. Add focused evidence of recent fighting: a few damaged supply items, a spent ammunition box, a torn tarp, a broken field telephone/cable, a damaged cart or equipment fragment, and localized shell-scuffed ground/wall treatments. Reuse existing crates, sandbags, rubble, and materials when plausible.
2. Distribute props across the Volga landing, transition shoulder, and street shoulder so each area has its own readable landmark while sharing a consistent material and damage language.
3. Keep silhouettes and world detail legible from player height. Props remain outside the central route, objective trigger approach space, enemy spawn positions, and principal firing lanes. Do not imply a walkable opening through a wall when existing collision blocks it.
4. Use small groups and varied rotations/heights rather than repeated identical rows. No new object is a pickup, cover mechanic, objective, or AI stimulus; it is visual only.
5. Historical markings must be supported by a reference and be appropriate to the period, place, and fictional mission context. Avoid readable unit numbers, national symbols, casualty depiction, or specific combat claims unless source and placement are reviewed. The visual intent is evidence of recent battle, not invented documentary detail.

### Work package 3 — Lighting and atmosphere

1. Preserve the existing cold gray-blue sky, muted earth palette, and warm directional key light. Tune ambient/key balance to brighten dark facade interiors and debris while retaining contrast and daylight readability.
2. Keep `shadow_enabled = false` for the directional light and do not add shadow-casting point or spot lights. Use material roughness/base color and the current sky/ambient setup to improve consistency.
3. Prefer one shared external Environment resource. Only add a second world environment if distinct area needs are clearly demonstrated and transition behavior remains smooth.
4. Test at player eye height and with the Mosin/PPSH silhouettes in view. Bright dust/smoke must not wash over target silhouettes; no eye adaptation or flashing light behavior.

### Work package 4 — Environmental soundscape

1. Add a low, steady, non-positional wind bed at a subdued level. Avoid sharp tonal loops and obvious short repetition.
2. Add sparse distant artillery and battle ambience from fixed 3D emitters placed beyond the visible route, with long max distance and distance attenuation. The mix should convey scale without suggesting an immediately hittable threat.
3. Use the dedicated `Environment` bus at a deliberately low starting gain (proposal: −12 dB relative to Master), while weapon SFX remain on the existing default bus. Measure and tune by listening in a live playthrough; do not duck, delay, or reroute weapon playback.
4. Compress ambient assets as OGG/Vorbis, mono for spatial sources and stereo only for the global wind bed. Trim loops cleanly, remove unintended peaks, and avoid excessive low-frequency rumble. Do not add voice/dialogue or combat-call logic.
5. Check several minutes of continuous play and menu/briefing/restart transitions. Soundscape nodes must stop or persist according to scene ownership without accumulating duplicate emitters on restart.

Godot's `AudioStreamPlayer3D` supports distance attenuation, directionality, and a low-pass filter for distant sounds, making it suitable for fixed artillery sources. [Godot 4.7 AudioStreamPlayer3D](https://docs.godotengine.org/en/4.7/classes/class_audiostreamplayer3d.html)

## 5. Asset and licensing requirements

- Prefer reusing the Phase 5B models/materials and creating small original variations from already licensed assets. Any new downloaded mesh, texture, or sound needs its own recorded source page, creator, exact license/version, download date, source archive, included third-party components, modifications, and intended commercial-use status.
- CC0 and CC BY are preferred where terms fit. CC BY requires creator attribution and license/source information; preserve the title, author, source link, license, and changes in an asset inventory. CC0 does not require attribution under its terms, though retaining provenance is good practice. [Creative Commons reuse and attribution guidance](https://creativecommons.org/reusing-cc-licensed-content/)
- Do not assume that a sound-library search result grants redistribution rights. Review the individual recording license and any restrictions on recognizable voices, performances, or third-party content. Avoid noncommercial-only, no-derivatives, unclear, or untraceable content unless separately approved and compatible with the intended distribution.
- Do not use copyrighted archival battlefield recordings, modern game audio, unlicensed film sounds, or recordings with unclear provenance. Commission/originally record the sounds or select individual items with explicit compatible terms.
- Keep `docs/PHASE_05C_ASSET_CREDITS.md` as a proposed implementation deliverable if any new third-party asset is added; if all assets are original/reused, document that fact and point to existing Phase 5B credits. Do not relicense or overwrite Phase 5B license files.
- Keep imported audio compact: target mono 44.1 kHz sources, OGG at a listening-tested bitrate; do not bundle uncompressed long ambient WAV files. Visual additions should use existing shared materials or 1K maps at most unless a measured close-up justifies more.

## 6. Performance budgets and measurement

These are proposed acceptance limits to validate on the actual Intel UHD 620 system; if its current baseline changes materially, record both measurements and obtain owner approval before relaxing a limit.

| Metric | Proposed budget |
|---|---|
| Active particles | At most 120 total (dust plus smoke), from at most 4 emitters; no collision, trails, subemitters, or runtime particle instantiation. |
| Effects coverage | Low-opacity sprites; dust/smoke should not collectively cover more than roughly 15% of the view in the busiest approved camera angle and should not obscure combat silhouettes. |
| Static additions | At most 12 new small prop instances across the route unless instancing/shared meshes keep draw calls effectively flat. All use shared materials where possible. |
| Lights | One existing DirectionalLight3D, no real-time shadows, and no added local lights for atmosphere. |
| Audio concurrency | One wind bed and no more than 3 concurrently audible distant battlefield sources; all ambience uses the low-level Environment bus. |
| Frame time | At the same 1280 × 720 Compatibility route and scene state: P95 increase ≤20% over a fresh baseline; P99 ≤16.7 ms; fewer than 0.1% of sampled frames over 33.3 ms. Record median/P95/P99/max and CPU/GPU bottleneck evidence. |
| Memory | Added imported resources should remain below 48 MiB estimated resident memory; record actual project/OS/GPU data where available and list estimation limits. |

Measurement method:

1. Capture a new baseline in a fresh non-editor game process on the target machine at 1280 × 720, GL Compatibility, same window mode, same route, and same enemy/mission state. Warm the scene for 30 seconds, then sample at least 120 seconds. Repeat three times and report median of the three P95 values plus the worst P99/max.
2. Use the same capture path, route camera positions, resolution, driver, and build for after measurements. Include landing, transition, street, active combat, and the heaviest particle view. Do not compare headless timing with rendered timing.
3. Use Godot's profiler/RenderingServer statistics where supported to record object count, draw calls, primitive count, and memory; record OS process memory as supplemental evidence. If a metric cannot be obtained reliably, mark it unavailable rather than infer it.
4. Compare 5C against that same-day baseline, and retain logs/screenshots. Existing Phase 5B values are a useful reference only; they are not a substitute for remeasuring.
5. Run a 10-minute warmed session and inspect for stutter, memory growth, repeated sound artifacts, or quality drift. A passing short average does not override visible hitching.

## 7. Risks and mitigations

| Risk | Mitigation |
|---|---|
| Fog flattens contrast and hides enemies or routes | Tune from player height, cap fog density, test all three areas and combat silhouettes, and use a clear fallback. |
| Particle overdraw or CPU simulation harms UHD 620 performance | Small CPU particle caps, few emitters, low coverage, no collisions/trails, and measured fallback toggle. Avoid assuming GPU particles work in Compatibility. |
| Smoke/dust intersects the reticle or obscures objective markers | Place emitters off-axis/behind scenery and validate the six existing framing views plus gameplay. |
| New props obstruct collision, nav, objective approach, or fire lanes | Render-only meshes with no physics; reserve existing route, spawn, trigger, and LOS zones; inspect full transforms/bounds before acceptance. |
| Added detail conflicts with Phase 5B composition or assets | Retain existing instances/materials, add only small complementary groups, compare before/after views, and remove any proposed item that duplicates a landmark. |
| Incorrect historical visual language or unsupported insignia | Use period references, document source and rationale, and omit uncertain markings. |
| Audio masks weapons, becomes fatiguing, or repeats obviously | Separate low-level bus, test against both weapons and combat, keep source count low, tune loop lengths/crossfades, and let owner approve listening mix. |
| Asset license or attribution is incomplete | Require per-asset provenance/rights check before download/import and complete credits inventory before milestone acceptance. |
| Editor F5/F6 issue remains unresolved while the scene changes | Keep the failure open, make a known-good baseline before implementation, apply changes incrementally, and do not describe CLI smoke checks as editor verification. |

## 8. Regression and verification strategy

All tests should be run sequentially to avoid the prior timing-sensitive concurrent Phase 4C failure. Keep existing test scenes unchanged unless a separate presentation-only check is necessary.

1. Before integration, rerun existing Phase 3B, 4A, 4B, and 4C headless suites and record exact counts. Verify current Phase 5B main scene still opens in rendered CLI and the F6 range CLI smoke launch remains independent.
2. Add presentation-only automated checks for environment resource loading, particle maxima/emitters, absence of new collision/navigation/objective nodes, soundscape resource assignments, bus assignment, and absence of null streams. Do not encode subjective visual/audio acceptance as a test assertion.
3. Rerun Phase 3B and Phase 4A–4C sequentially after each final integration. Confirm controls, weapon behavior/audio hooks, combat, navigation, objective progression, HUD, death/restart, and encounter cleanup are unchanged.
4. Confirm the full Mission 01 route and F6 test range in Editor F5/F6 manually. If the F5 issue persists, preserve its exact output and report it; do not change startup settings speculatively.
5. Generate identical 1280 × 720 screenshots for the six Phase 5B views, plus one combat sightline through each area. Inspect for readability, clipping, floating props, fog banding, repeated particles, route obstruction, and inconsistent colors. Also perform an audio listening pass with both weapons and during pause/briefing/restart.
6. Run the performance protocol in §6 and retain raw sample outputs and the machine/driver/renderer details. No visual or acoustic quality claim passes without the corresponding rendered/manual review.

## 9. Visual and audio acceptance criteria

- Landing, transition, and street retain their Phase 5B identities and share consistent fog color, light direction, material response, and environmental palette.
- Distance haze adds depth, but near props, enemy silhouettes, objective markers, reticle, and HUD stay clear at player height, including during aiming.
- Dust and smoke are subtle, have natural slow movement, show no obvious loop/pop/flicker/clipping, and remain within the particle and coverage budgets.
- Added props read as damaged, abandoned WWII-era battlefield supplies/equipment; forms and materials fit existing scale and the asset placement does not look duplicated or staged in a repeated pattern.
- Central walk route, player start, objective approaches, enemy paths and firing lanes remain visually open. New visuals create no misleading opening or artificial cover expectation.
- Lighting preserves detail in dark facade recesses and does not wash out the gray-brown terrain or weapon/enemy contrast. No expensive real-time shadows are introduced.
- Wind is present but unobtrusive. Distant artillery/combat is spatially believable and low in the mix; weapon fire, reload/empty cues, enemy awareness and player feedback remain easy to hear.
- Compatibility renderer produces the same required visuals/audio behavior without project errors on the target system; performance budgets in §6 pass.

## 10. Manual verification checklist

- [ ] Before implementation, owner manually verifies Editor F5 and records whether the game window stays open; captures exact error/output if it closes.
- [ ] Before implementation, owner manually verifies Editor F6 launches the enemy test range; confirms the CLI F6 result is not being substituted for this check.
- [ ] Owner completes pending Phase 5B manual traversal from Volga landing through the street, confirms route/collision and that existing props do not block play.
- [ ] Owner exercises movement, mouse capture, Mosin/PPSH switching, firing, ADS, reload, HUD, enemy combat, objective order, death, and restart before Phase 5C integration.
- [ ] After Phase 5C integration, owner repeats the same checks and compares six matching screenshots in Compatibility at 1280 × 720.
- [ ] Owner listens for at least 10 minutes with weapons and combat active; checks wind/artillery levels, positional impression, loop quality, restart behavior, and any hearing discomfort.
- [ ] Owner reviews period-specific props/markings and approves asset credits/licensing record.
- [ ] Owner reviews the performance report and approves the resulting visual/audio trade-offs.

Owner verification items are human acceptance tasks; automated tests do not satisfy them.

## 11. Implementation order and completion criteria

Implement this as one Phase 5C milestone in the following internal order:

1. **Preflight:** owner completes outstanding Phase 5B Editor F5/F6 and manual gameplay checks, or explicitly documents any unresolved editor issue and authorizes proceeding with it tracked. Capture fresh visual, audio, and performance baselines. Confirm no unrelated worktree changes will be overwritten.
2. **Environment and lighting foundation:** externalize/configure the Environment resource with subtle compatibility depth fog and balanced lighting. Capture/test before adding moving effects.
3. **Atmosphere pilot:** add capped dust and distant smoke to one representative transition/street view; measure and inspect on UHD 620. Tune or remove until thresholds pass.
4. **Storytelling assets:** document rights first, add small render-only shoulder groupings across the three areas, verify bounds and firing sightlines, and keep all Phase 5B assets intact.
5. **Soundscape:** add the Environment bus and ambient loops/emitters; check resource ownership across briefing, gameplay, and restart, then tune with both weapons in an interactive session.
6. **Integrated verification:** run automated regressions sequentially, presentation checks, rendered screenshots, F5/F6/manual checks, listening review, and the full performance protocol. Record exact results, limitations, and licenses in the Phase 5C implementation/test report and any credits inventory.

Phase 5C is complete only when all four work packages meet their acceptance criteria on Godot 4.7.2 GL Compatibility; existing Phase 3B and 4A–4C regressions pass; no route, collision, navigation, objective, weapon, enemy, HUD, or restart regression is found; asset provenance is documented; target hardware performance budgets pass; and the owner accepts visual, audio, manual F5/F6, and gameplay verification. Any remaining F5 issue must be reported accurately and explicitly accepted by the owner before the milestone can be called complete.

## 12. Coexistence with Phase 5B verification items

Phase 5B's CONDITIONAL PASS, existing six screenshot review, regression results, and CLI smoke checks remain valid evidence within their scope. They do not settle Editor F5, Editor F6, or owner-led gameplay acceptance. Phase 5C planning is independent of those unresolved checks; the Phase 5C implementation preflight should resolve or explicitly carry them with owner authorization, and both editor paths plus gameplay must be rechecked after presentation changes. Keep the F5 root cause marked **unconfirmed** until reproduced with an exact error. Do not alter startup settings to try to silence it. Keep the parent `README.md` merge conflict untouched throughout.

This document is a plan only. No Phase 5C implementation, asset import, game setting change, gameplay code change, staging, or commit is authorized or performed by this planning deliverable.
