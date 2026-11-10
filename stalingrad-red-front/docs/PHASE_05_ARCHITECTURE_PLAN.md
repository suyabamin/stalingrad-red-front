# Phase 5 — Mission 01 Visual Overhaul Architecture Plan

**Planning status: COMPLETE (2026-11-09). Phase 5A visual foundation and technical verification: COMPLETE; owner review pending.**  
**Phase 4C remains COMPLETE. Phase 5A rendered review and owner gameplay verification are pending. A Phase 5B asset-integration plan is available; implementation has not started and no assets have been downloaded.**

This plan follows an inspection of the current Godot project and its visual/gameplay resources. It proposes changes only. No scene, gameplay script, resource, asset, or project setting was changed for this plan.

## 1. Scope and visual direction

Develop the current Mission 01 graybox into a cohesive, historically inspired Stalingrad battlefield while preserving all Phase 4C combat and mission behavior. The desired look is subdued and readable: weathered brick, gray concrete, dusty earth, dark timber, dull metal, and muted river water. Use localized detail and atmosphere to support scale and environmental storytelling rather than adding dense decoration everywhere.

Keep the historical setting and fictional mission orders distinct. The visual work should not imply a specific documented event, unit, date, weather condition, or building history unless supported by reviewed references.

## 2. Baseline visual audit (before Phase 5A)

| System | Inspected current state | Strengths | Weaknesses / opportunity |
|---|---|---|---|
| Project/rendering | Godot 4.7.2, GL Compatibility renderer, 1280×720 viewport. No custom render pipeline or add-on dependency. | Appropriate low-cost renderer and existing startup path. | No recorded Phase 5 visual performance baseline, texture budget, or export test. |
| Main world | `scenes/main/main.tscn` has one `WorldEnvironment`, a single DirectionalLight3D, Battlefield, Player and HUD. Environment uses a ProceduralSkyMaterial; ambient light is enabled. Directional shadows are disabled. No fog or post-processing is configured. | Simple, predictable setup; no expensive volumetric effects. | Light and sky produce a clean prototype look with limited depth, time-of-day character, and shadow definition. |
| Battlefield geometry | `scripts/environment/battlefield.gd` constructs a 74×142 m continuous ground slab, a 10 m road, a broad mud slab, a flat blue water slab, a raised shore, timber pier, crates, 28 repeated roadside masonry pieces, box facade shells, upper-wall blocks, beams, cover piles, utility poles and a lorry assembled from boxes. | Readable linear route, recognizable landmarks and a broad central street. Primitive geometry keeps assets light. | Ground, water, masonry and buildings are mostly flat colored boxes. Facades have no window depth, floor structure, rubble variation or material breakup. Repetition is visible. The river has a hard rectangular boundary. |
| Materials/textures | Battlefield caches a small set of rough StandardMaterial3D solid colors. `assets/` contains no current environment texture library; the inspected scenes/resources do not use imported environment textures. | Shared materials limit material duplication and avoid texture-memory cost. | Surfaces lack texture scale, roughness variation, edge wear and color variation. A wholly textureless look emphasizes the blockout. |
| Lighting/atmosphere | Warm directional light at energy 0.8, ambient energy 0.55, procedural sky. No real-time shadows, smoke, dust, fog, decals or particle systems. | Low GPU load and no overdraw from alpha effects. | Flat light reduces form/readability; horizon and area transitions have little atmospheric depth. |
| Objective markers | `ObjectiveTrigger` builds box-frame arches and Label3D text above the route. Trigger volume is a 10×4×6 m Area3D. Markers are easy to see. | Clear wayfinding and nonblocking collision behavior. | The arches and repeated labels look like debug/blockout markers. Visual update must not move or resize their Area3D collision. |
| Player/weapons | Player is a first-person CharacterBody3D with an active camera; weapon scenes create low-poly models procedurally from primitive meshes and StandardMaterial3D. HUD is generated from Controls in `prototype_hud.gd`. | Small, readable silhouettes and no large imported model cost. | Soldier/weapon surfaces lack authored detail and material variation; weapon presentation remains prototype quality. HUD is functional but visually generic. |
| Enemy | `infantry_enemy.tscn` is a CharacterBody3D with capsule collision, NavigationAgent3D, a primitive torso/head/helmet/limbs/rifle, muted flat materials and procedural placeholder animations. | Lightweight and recognizable at gameplay scale; existing collision, navigation, health and animation hooks are separated. | Shape and animation are visibly blocky; current materials and geometry do not match a detailed battlefield treatment. |
| Performance evidence | Compatibility renderer and primitive geometry suit modest hardware, but there is no measured Phase 5 draw-call, frame-time, memory, shader-compilation or export baseline. | Low polygon count and disabled real-time shadows are a safe starting point. | Each colliding `_box()` creates a StaticBody3D, CollisionShape3D and mesh node; repeated small props may cost CPU/draw calls despite simple geometry. Integrated graphics share system memory. |

### Area boundaries observed

- **Area A — Volga River Landing:** the shore, water, pier, crates, landing label and first route section near z≈46 to the landing objective at z=14. Water is a flat box centered near x=32, the ground extends to x=37, and the shore/pier props occupy the east side of the landing.
- **Area B — Battlefield Transition:** the route from the landing toward the first ruined street, roughly between the z=14 and z=-42 objectives. It uses alternating roadside rubble, timber cover and the first facade sections. It should read as an exposed transition into denser urban terrain.
- **Area C — Ruined Stalingrad Street:** the street and forward position from about z=-42 to z=-90. It includes more facade shells, rubble cover, utility poles, the wrecked lorry near `(-6.7, 0.9, -46)`, and the final rally marker.

These are visual planning regions based on current object placement, not new mission boundaries.

## 3. Existing visual strengths and weaknesses

**Strengths to preserve:** coherent route composition; strong landing and street labels; a road that gives the player an obvious forward direction; cover already placed along both sides; one shared rough material per color family; procedural sky; a no-shadow directional light; existing trigger arches; low-cost player/enemy silhouettes; no paid dependencies.

**Main weaknesses to address:** uniform surfaces, hard rectangular water and terrain edges, repeated box-like rubble, shallow facade silhouettes, lack of visible building interiors/floor edges, little material distinction between brick/concrete/earth, no visual transition between open landing and dense street, and flat lighting without ground contact or directional shadow cues. Existing player/enemy primitives need more coherent surface treatment and silhouette refinement without changing their gameplay roots.

## 4. Proposed visual improvement program

The table defines the proposed changes and their likely impact. Every change needs the stated verification before it is retained.

| Change | Why / area | Candidate files/resources | Risk and verification |
|---|---|---|---|
| Create a shared restrained material library and color reference | Unify earth, mud, brick, concrete, dark masonry, timber, water and metal across Areas A–C. Add controlled color/roughness variation and, only where useful, texture detail. | New `resources/environment/materials/` resources; `assets/textures/environment/`; possibly `scripts/environment/battlefield.gd` to consume shared resources. | Materials may become too dark, noisy, tiled or expensive. Inspect at gameplay distance and 1280×720; check import sizes, compatibility rendering and that albedo values preserve enemy/marker contrast. |
| Rework landing shoreline and water presentation | Replace the obvious rectangular water edge with a shaped shoreline, shallow bank layers and restrained surface variation. Improve pier silhouette with plank/beam detail and a small number of shoreline props. | `scripts/environment/battlefield.gd` or a new `scenes/environment/area_a_landing.tscn`; shared environment materials/meshes. | Shore geometry may create gaps or obstruct the player. Preserve the continuous ground and player start; run floor/collision and route traversal checks. Keep any water shader or transparency minimal; inspect overdraw and UHD 620 performance. |
| Add transition-area terrain and prop variation | Make the open approach transition gradually into an urban street. Vary rubble scale/rotation/material, add a few large readable landmark pieces and nonblocking ground breakup. | Battlefield builder or a new Area B scene; environment meshes/material resources. | Random-looking clutter can block visibility, nav or spawn positions. Prefer authored deterministic placement; compare every collision footprint against current corridor, cover and encounter points; rerun Phase 4A and Phase 4C checks. |
| Give ruined street facades architectural depth | Replace or layer selected box facades with modular wall sections, window/door voids, exposed floor slabs, broken rooflines and rubble piles. Detail the lorry and utility poles selectively. Preserve a clear 10 m road impression and enemy sightlines. | New modular scenes under `scenes/environment/`; `scripts/environment/battlefield.gd` or a Battlefield scene composition; reusable mesh/material resources. | Building meshes and collisions can block the player, navigation or sightlines, or add many draw calls. Keep decorative surfaces non-colliding; explicitly author only necessary collision; validate all spawn/nav projections, triggers, cover rays and pathing in F5 and F6. |
| Add terrain surface texture and restrained decals | Give road, mud, earth and masonry scale and breakup without a large texture set. Use tiling textures or a small shared atlas; consider a few baked/static decals for impact/scorch/stain variation. | `assets/textures/environment/`; material resources; optional decal nodes in area scenes. | Excessive resolution, repetition, alpha overdraw or texture memory can hurt integrated graphics. Start with small tiling assets/atlas; inspect mipmaps, distance tiling and memory; avoid many overlapping transparent decals. |
| Refine light, sky and distance atmosphere | Establish a subdued daylight palette and use a small amount of non-volumetric depth fog if useful. Test one shadowed key light at conservative settings; retain an unshadowed fallback if cost/artifacts are unacceptable. | `scenes/main/main.tscn` environment/light resources; optional `.tres` environment resource. | Shadows/fog may reduce frame rate, obscure targets or make textures unreadable. Compare identical views, weapon sightlines and enemy readability on Compatibility renderer at the target resolution; measure before keeping shadows. |
| Add local smoke/dust only as placed accents | Give a few damaged structures scale and atmosphere using low-count, localized effects. Avoid a full-screen haze or continuous dense particles. | New lightweight particle scenes under `scenes/environment/effects/`; area scene placements. | Particle fill-rate/overdraw, transparent sorting, noise and distraction can be costly. Bound emission/count/lifetime, keep away from critical combat lanes, test worst-case overlap and provide a clear low-effects option only if required. |
| Improve environmental storytelling | Add carefully chosen silhouettes such as broken masonry thresholds, damaged signage, abandoned supply/transport props and building-specific debris groupings. Keep the fictional order context clear. | Area scenes/Battlefield composition, small prop scenes, shared materials. | Unsupported historical dressing or visual clutter can mislead and reduce combat readability. Review references and labels; avoid asserting a specific documented incident; keep route, cover and objective markers clear. |
| Refine player/enemy and weapon appearance | Add material breakup and silhouette details to the existing low-poly soldier and weapon placeholders. Prefer mesh/material improvements that leave root transforms, collision capsules, sockets and scripts intact. | `scenes/enemies/infantry_enemy.tscn`; weapon scenes or their procedural model builders; optional new lightweight mesh assets/resources. Player scene only if a visible mesh is actually present or added. | Mesh scaling can misalign weapon hits, animation, camera, muzzle orientation or enemy collision. Keep visuals on render-only layers where possible; verify hitboxes, weapon rays, F6 visibility, mission spawn visibility and silhouette against each background. |
| Tune trigger marker and HUD presentation | Replace debug-like marker treatment with a consistent restrained visual language and improve readability of existing HUD panels. Keep objective marker text legible and all five sequence states obvious. | `scripts/missions/objective_trigger.gd` marker-only section; `scripts/ui/prototype_hud.gd`; optional theme resource. | UI/marker changes can obscure targets, reduce contrast, alter input hit areas or accidentally change trigger geometry. Do not alter Area3D shape, position, collision mask or signals; test briefing, gameplay, death and completion screens at 1280×720. |
| Reduce measured static-scene overhead | Reuse meshes/materials, group decorative non-collision geometry, and use MultiMesh for repeated decorative pieces only where profiling supports it. Keep collision simple and separate from render detail. | Battlefield builder/scenes and reusable mesh resources; no project setting change without a measured need. | Combining nodes can complicate culling, collision authoring, scene editing and navigation. Profile first; compare draw calls/frame-time and rerun all gameplay collision/nav tests before adopting. |

## 5. Building and environmental asset strategy

### Essential

1. Prefer native low-poly modular meshes and Godot resources for core level geometry. This avoids dependence on paid assets and keeps collision/navigation under project control.
2. Use a small kit of brick wall, concrete wall, floor slab, beam, window recess, doorway, rubble cluster, timber, crate, lorry and shoreline pieces. Reuse pieces with authored rotations and a few material variants instead of placing many unrelated unique meshes.
3. Keep render meshes separate from simplified gameplay collision. Decorative wall damage, rubble texture and facade detail should not add collision unless it changes traversal or cover intentionally.
4. If importing third-party/free assets, keep a source URL, author, license, modification notes and attribution in the project. Confirm commercial-use and redistribution rights before committing. Do not introduce a paid tool/service or an asset with unclear rights.

### Optional

- A small shared atlas or a limited set of seamless tile textures for brick, mud, road and concrete.
- Selective static decals and a small number of localized dust/smoke effects.
- A low-poly riverbank prop silhouette or debris clusters if the landing still reads too empty after the essential material and shoreline pass.

Do not begin by importing a large photogrammetry pack, high-resolution PBR library or rigged character. First prove the visual direction with the existing scene scale and low-cost geometry.

## 6. Material, texture and memory strategy

- Centralize reusable `StandardMaterial3D` resources instead of creating one material per mesh. Use a small palette of shared albedo/roughness variants.
- If source textures are used, begin with 512–1024 px tiling textures or small atlases for environment surfaces; use lower resolutions for small props. Mipmaps should be enabled for 3D tiling surfaces; inspect imported results for banding, blur and repetition.
- Keep texture count and total resident dimensions low. Prefer one compact set shared across the level over unique maps for every building. Avoid 4K textures for this scene unless a measured close-up proves the need.
- Normal maps are optional and should be limited to large close surfaces. Avoid shader graphs or custom screen-space effects that add per-pixel work across the whole viewport.
- Use mostly opaque materials. Restrict transparent material, decal and particle overlap to small areas to avoid fill-rate costs and sorting artifacts.
- Confirm imported texture compression and compatibility on the target renderer. Compare quality and memory behavior on the integrated GPU rather than assuming desktop discrete-GPU results transfer.

## 7. Lighting, sky, fog and effects strategy

- Keep one primary directional light and the existing ambient/world contribution as the baseline; tune color/energy together with the material palette rather than adding multiple dynamic lights.
- Test a simple gradient or revised ProceduralSkyMaterial and subtle distance fog. Favor non-volumetric depth fog if it materially improves separation. Keep critical buildings, enemy silhouettes, objective markers and far route landmarks readable.
- Try static-environment shadowing only as a measured experiment. Begin with conservative atlas/cascade settings and limited shadow distance; compare no-shadow and shadowed captures and frame time on Intel UHD 620. Keep the existing no-shadow state if cost/artifacts outweigh the visual gain.
- Do not enable volumetric fog, SDFGI, SSR, heavy SSAO or full-screen post effects as defaults for this target. Any future proposal needs a documented compatibility/performance test.
- If smoke/dust is used, place a few localized low-rate emitters behind or beside combat lanes. Bound particle count, lifetime, size, transparency and active area. Avoid smoke across nav paths, the landing view, weapon sightlines and HUD contrast.

## 8. Historical authenticity considerations

- The visual setting can be inspired by the Battle of Stalingrad in 1942, but the mission events and orders remain fictional as stated in `mission_01.tres`.
- Before adding identifiable insignia, uniforms, vehicle markings, building names or dated signs, review reliable historical references and record the source in the asset notes. Do not use unsupported labels or invent named locations/events.
- Favor broadly plausible material/architectural cues over specific claims where evidence is unavailable. Avoid implying that a generated building represents a real documented structure.
- Keep UI objective text operational and fictional; historical captions should remain separate from in-world orders.

## 9. File and scene impact analysis

The entries below describe the original anticipated impact. Phase 5A now implements the shared materials and restrained environment baseline; the remaining impacts are prospective:

| File/area | Likely Phase 5 impact | Preservation constraint |
|---|---|---|
| `scripts/environment/battlefield.gd` | Refactor generated primitive placement into area modules; assign shared material/mesh resources; add visual-only geometry and effects. | Preserve world coordinates, route boundaries, cover collision, environment collision, and all configured encounter spawn locations. Keep navigation corridor valid. |
| `scenes/main/main.tscn` | Tune the WorldEnvironment and DirectionalLight3D, or reference a shared Environment resource. | Keep startup scene, player, HUD, Battlefield and EncounterManager nodes; renderer stays Compatibility unless an approved measured change is made. |
| `scenes/missions/objective_trigger.tscn`, `scripts/missions/objective_trigger.gd` | Optional visual-only marker frame/material refresh. | Preserve Area3D transform, 10×4×6 collision shape, collision settings, objective signal connections and marker locations. |
| `resources/missions/mission_01.tres` and `resources/missions/encounters/*.tres` | Normally no visual-phase change expected; could be read-only references for area labels only. | Preserve objective order/IDs, trigger positions, encounter definitions and spawn coordinates. |
| `scenes/enemies/infantry_enemy.tscn` | Optional visual mesh/material replacement or refinement. | Preserve CharacterBody3D root, collision layer/mask, capsule, Health, NavigationAgent3D, AnimationPlayer and node paths consumed by scripts. |
| `scenes/player/player.tscn`, `scenes/weapons/*.tscn`, `scripts/weapons/*` | Optional visual-only model/material work if an actual visible defect is confirmed. | No changes to player controls, collision, camera, weapon rays, damage, ammo, switching, ADS, reload or gameplay logic. Prefer mesh/resource-only edits. |
| `scripts/ui/prototype_hud.gd` | Optional visual layout/theme polish. | Preserve signal handlers, controls, buttons, pause/capture logic, restart connections, objective text and HUD information. |
| `assets/`, `resources/environment/`, `scenes/environment/` | Add reviewed, licensed visual assets/resources during approved implementation. | Record licenses/source; keep files small, shareable and importable with Godot 4.7.2. |
| `project.godot` | No change expected. | Do not change renderer, viewport, physics or import settings without an approved measured reason and regression evidence. |

## 10. Essential and optional work

**Essential for Phase 5:** establish a cohesive material/color baseline; improve the landing/shore transition; add depth and authored variation to the transition and street facade shells; tune sky/light/atmosphere without losing readability; verify all gameplay geometry, nav, triggers, enemy silhouettes and F6 range; record a Compatibility-renderer visual/performance comparison.

**Optional if tests justify it:** detailed character meshes, animated flags, a boat silhouette, additional interior rooms, localized decals, smoke/dust emitters, custom sky textures, and visual HUD themes. Optional work must not delay or destabilize the essential route pass.

## 11. Risks and compatibility

| Risk | Mitigation / gate |
|---|---|
| Visual geometry narrows the nav lane or blocks the 8.4 m hand-authored navigation strip | Keep static collision authored separately; rerun all eight spawn projections and enemy chase tests after every geometry stage. |
| New cover changes enemy/player LOS or weapon behavior | Re-run Phase 3B occlusion checks and Phase 4C combat checks; manually inspect each encounter view. |
| Added detail hides enemies or objective arches | Review standing/crouched camera-height lines at each encounter and ensure marker contrast on every material background. |
| High draw-call count or scene-node growth | Reuse mesh/material resources; profile before MultiMesh or static batching; simplify decorative shapes first. |
| Textures exceed integrated GPU budget or cause import stalls | Maintain a texture inventory and dimensions; inspect mipmaps/compression; introduce a small batch and measure startup/memory before expanding. |
| Shadows, fog or particles harm Compatibility performance | Compare controlled captures and measured frame times on Intel UHD 620; keep effects localized and provide a low-cost fallback. |
| Imported asset licensing or attribution is unclear | Do not commit until source, license and use rights are documented and reviewed. |
| Visual additions alter collision, trigger transform or spawn data accidentally | Protect key values with regression checks and review diffs for objective/spawn/nav coordinate changes. |
| Historical dressing implies unsupported facts | Keep references and claims documented; use generic fictional dressing without source-backed specificity. |

## 12. Testing and verification plan

### Before implementation

- Record baseline screenshots from the same camera positions: start/landing, transition, street/lorry, final marker, enemy at each encounter and F6 range.
- Record the current project import/startup warnings and a repeatable performance baseline on the target Intel UHD 620 system. Do not set an FPS promise in advance.
- Preserve Phase 4C automated results and compare them after each visual stage.

### After each stage

- Run a Godot 4.7.2 project import and check for resource/parse errors.
- Run Phase 4A, 4B, 4C and 3B harnesses. They protect route traversal, mission sequence/combat gates, encounter navigation/death, weapon hitscan and F6 AI.
- Open F5 in a non-headless GL Compatibility run and review the affected area from player height and encounter sightlines. Headless results do not count as visual verification.
- Confirm Area3D markers, player start, continuous floor, cover collisions, navigation map, all spawn projections and enemy path approach remain correct.
- Test both weapons, reload, enemy attacks, death/restart, completion/restart, and F6 after relevant player/enemy visual changes.
- Measure performance using the same target hardware/resolution/settings before and after. Record frame-time method, observed range, scene location and effects state; report measured values only.
- Check texture dimensions, import settings, resource references, asset licenses, and a Windows export only in a later approved verification task.

### Visual review positions

1. Player start looking from z=22 toward the landing/first marker.
2. Objective 1 vicinity near z=14 facing both the river landing and inland route.
3. Transition cover and objective 2 near z=-8.
4. Street entrance and lorry vicinity near z=-42 to z=-50.
5. Forward position and final objective arches near z=-75 to z=-90.
6. F6 Enemy Test Range start view for enemy/player/weapon consistency.

## 13. Suggested implementation stages

Phase 5A has been implemented. Gate it on owner review before any later stage. Stages 5B–5E remain proposals pending separate authorization; gate each on gameplay regressions and rendered inspection.

| Stage | Focus | Deliverable / gate |
|---|---|---|
| 5A — Visual foundation | CORRECTED: shared materials and maps now show visible surface variation at gameplay distance. | Import and Phase 3B/4A/4B/4C regressions passed; four rendered views were captured and inspected. No original baseline screenshots were available. Owner visual/gameplay review and UHD 620 profile remain outstanding before acceptance. |
| 5B — Battlefield geometry and licensed asset pilot | Proposed in `PHASE_05B_ARCHITECTURE_PLAN.md`: verify item-level rights, pilot one street facade/rubble/props, then selectively dress Areas A–C. | Planning only. Do not download or integrate until owner accepts Phase 5A and separately authorizes the pilot. Then require clear lanes, preserved nav, unchanged gameplay collision, license records and performance evidence. |
| 5C — Lighting and atmosphere | Key/ambient balance, procedural sky refinement, conservative depth fog; optional measured shadow trial and bounded dust/smoke accents. | Readable silhouettes and depth on Compatibility; measured comparison proves any retained effect acceptable. |
| 5D — Storytelling and visual consistency | Selective period-inspired props, decals, lorry/utility detail, consistent objective markers, optional restrained character/weapon visual updates. | Cohesive surface language and environmental storytelling with references/license notes; all gameplay roots and controls unchanged. |
| 5E — Optimization and final verification | Remove waste identified by profiling, validate resource/import inventory, repeat regression and manual visual/interaction passes, measure target performance. | Phase 5 completion report with screenshots, test results, measured performance and known limits. No completion claim before evidence is recorded. |

Stages may be combined or split after 5A review. Do not commit to external assets, extensive interiors, high-cost effects or character replacement until the foundation comparison demonstrates they are needed.

## 14. Acceptance criteria

- The landing, transition and ruined street have a consistent, subdued visual identity and are visibly more detailed than the current flat-color blockout.
- Route direction, objective markers, combat lanes and enemy silhouettes stay readable from the player camera at all five objective areas.
- Riverbank and shore visually join the landing terrain without rectangular-water presentation dominating the scene.
- Building and rubble work adds architectural depth without blocking the player, enemy navigation, spawn points, triggers or intended cover lanes.
- Existing player, weapons, mission/encounter logic, HUD, briefing, completion/failure/restart flow and F6 test range remain functional.
- All Phase 3B, Phase 4A, Phase 4B and Phase 4C regressions pass after visual changes; non-headless inspection confirms the intended rendered look.
- Any third-party assets have documented legal use/attribution. Imported texture sizes and optional effects are inventoried.
- Intel UHD 620 performance is measured and reported without invented targets; retained shadows/fog/particles have a measured rationale.
- Phase 5A is not complete until the owner accepts the rendered result and manual gameplay verification. Do not begin Phase 5B until the owner has completed that review and separately authorized the next stage.

## 15. Phase 5A implementation record

The Phase 5A material and environment foundation has been corrected after the owner's visual acceptance failure. The original five maps were nearly uniform, and their low UV repetition and stretched road mapping hid detail at gameplay distance. They are now five distinct 256×256 seamless maps with mipmaps, updated UV scales, and verified visible assignments across all 12 reusable opaque StandardMaterial3D resources. No battlefield geometry, gameplay systems, mission resources, collision, navigation, triggers, or project rendering settings were changed.

Four non-headless GL Compatibility screenshots were captured from the Mission 01 viewport and visually inspected: landing, transition, ruined street, and a ground/road/building close-up. They demonstrate visible material detail after correction. Original baseline screenshots were not present, so side-by-side comparison is unavailable. The requested Phase 3B/4A/4B/4C harnesses pass. Owner review and manual F5/F6 gameplay verification, plus Intel UHD 620 performance measurement, remain pending. Phase 5A is not complete and Phase 5B has not started. See `PHASE_05A_IMPLEMENTATION_REPORT.md` and `PHASE_05A_TEST_REPORT.md` for the correction details and captures.

## 16. Phase 5B implementation status

The owner authorized the Phase 5B battlefield realism milestone on 2026-11-10. Its environment work, six 1280×720 Compatibility captures, existing regression reruns, and a 1,200-frame timing sample are complete. The reported editor-only F5 close was not reproduced, so its root cause and repair remain unconfirmed. Owner review and editor-driven F5/F6 gameplay verification remain outstanding. See `PHASE_05B_IMPLEMENTATION_REPORT.md` and `PHASE_05B_TEST_REPORT.md`. Phase 5C has not started.
