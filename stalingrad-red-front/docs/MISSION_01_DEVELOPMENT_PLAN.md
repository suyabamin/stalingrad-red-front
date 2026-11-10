# Mission 01: Across the Volga â€” Development Plan

This plan extends the current prototype incrementally. Keep the existing startup scene playable at each phase; avoid broad manager rewrites. The plan describes future work and does not indicate that features are implemented.

## Phase 1: FPS Player Controller and Player Health

**Status (2026-11-08): Implemented in source; Phase 1 checks remain project-owner-reported and were not rerun in this audit.** See `PHASE_01_TEST_REPORT.md` for attributed results and limits.

- **Objectives:** Verify and harden movement; add health, damage and death contracts.
- **Features:** Existing movement retained; separate health component/data, damage/death signals, death overlay and current-scene restart foundation.
- **Existing files to modify:** `scenes/player/player.tscn`, `scripts/player/player_controller.gd`, `scripts/core/game_manager.gd`, `project.godot` only if input actions are needed.
- **New files required:** `scripts/player/player_health.gd`; `docs/PHASE_01_TEST_REPORT.md`.
- **Dependencies:** Current player scene and manager; no combat required for isolated damage tests.
- **Implementation steps:** Establish collision layers; verify floor spawn/movement; separate health from locomotion; expose max/current health and damage/heal; emit health/death signals; define reset behavior.
- **Test cases:** Walk/sprint/jump/look; wall/floor collision; sensitivity changes; damage clamps at zero; repeated damage after death ignored; reset restores configured state.
- **Acceptance criteria:** Player controls are stable and health/death transitions are deterministic with no movement regression.
- **Potential risks:** Controller and health becoming tightly coupled; mouse capture edge cases; spawn floor snap.

## Phase 2: Weapon, Shooting, Ammunition and Reloading

**Status (2026-11-08): Source-audited; partially verified by project-owner report.** The owner reports Mosin firing, PPSH automatic firing, reloading, and stationary-target damage working, with no observed Godot errors. The audit did not independently reproduce these results; see `PHASE_02_TEST_REPORT.md` for explicit limits and unreported cases.

- **Objectives:** Deliver one complete weapon loop with observable feedback.
- **Features:** Mosin-Nagant and PPSH-41 scenes, hitscan/damage interface, fire cadence, ammo/reserve, reload, weapon switching, ADS, sway/recoil, impact marker, HUD and isolated target range.
- **Existing files modified:** `scenes/player/player.tscn`, `scripts/core/input_setup.gd`, `scripts/ui/prototype_hud.gd`, `docs/CONTROLS.md`, architecture/status docs.
- **New files:** `scenes/weapons/mosin_nagant.tscn`, `scenes/weapons/ppsh_41.tscn`, `scripts/weapons/weapon_base.gd`, `scripts/weapons/weapon_manager.gd`, `scripts/weapons/weapon_data.gd`, Resources under `resources/weapons/`, and an isolated test range/target under `scenes/testing/`.
- **Dependencies:** Phase 1 health/damage contract; collision layer plan.
- **Implementation steps:** Add fire/reload actions; create reusable weapon state; cast aim ray from camera; exclude shooter; apply damage via common contract; implement ammo transfer/reload state; provide empty-fire and hit feedback hooks.
- **Test cases:** Hit/miss/world occlusion; fire cooldown; ammo decrement; empty magazine; partial/full reload; reload with no reserve; no damage after player death.
- **Acceptance criteria:** One weapon can reliably fire, hit valid targets, consume ammo and reload without bypassing collision.
- **Known content gaps:** Weapon audio streams are unassigned; current weapon models are procedural graybox placeholders.
- **Potential risks:** Camera ray vs weapon muzzle discrepancy; duplicate hitboxes; input edge cases during reload.

## Phase 3A: Enemy Foundation

**Status (2026-11-08): Implemented in source; runtime validation not performed.** See `PHASE_03A_IMPLEMENTATION_REPORT.md` and `PHASE_03A_TEST_REPORT.md`.

- **Objectives:** Add a reusable enemy actor foundation without combat AI.
- **Features:** CharacterBody3D soldier placeholder, separate health receiver using `apply_damage(amount)`, NavigationAgent3D target following and avoidance, animation state hooks, and isolated obstacle test range.
- **New files:** `scenes/enemies/infantry_enemy.tscn`, `scripts/enemies/enemy_controller.gd`, `scripts/enemies/enemy_health.gd`, `scenes/testing/enemy_test_range.tscn`, and its builder script.
- **Acceptance status:** Implemented by source inspection only. Map readiness, path following, obstacle avoidance, damage, and death require Godot runtime validation.
- **Known limits:** Placeholder low-poly visuals and procedural placeholder animations; no detection, attacks, tactical behavior, main-mission enemy placement, or measured performance.

## Phase 3B: Enemy AI, Detection and Combat

**Status (2026-11-09): Implemented; headless runtime checks passed for state transitions, navigation pursuit, wall occlusion, damage, reload/exhaustion and terminal death.** See `PHASE_03B_IMPLEMENTATION_REPORT.md` and `PHASE_03B_TEST_REPORT.md`. Interactive visual review remains outstanding.

- **Objectives:** Add a small, readable opposing force with detection, combat and reliable pathing.
- **Features:** Reusable enemy scene, health, navigation, detection, investigate/chase/attack/reload/dead states, spread hitscan fire and test-range combat readout.
- **Existing files modified:** `scripts/enemies/enemy_controller.gd`, `scripts/testing/enemy_test_range.gd`, architecture, status and phase documents.
- **New files:** `scenes/testing/phase_03b_runtime_check.tscn`, `scripts/testing/phase_03b_runtime_check.gd`, and Phase 3B reports.
- **Dependencies:** Phases 1â€“2 damage/weapon contracts; Phase 4 navigation-ready geometry can be developed alongside this phase but bake validation is required.
- **Implementation steps:** Define collision layers; build enemy body and hit area; bake navigation; implement state machine; add line-of-sight and range checks; add bounded enemy attack cadence; stop navigation and combat on death.
- **Test cases:** Detect inside/outside range and FOV; wall blocks sight; chase around obstacle; unreachable path recovery; damage/death once; enemies do not fire through cover.
- **Acceptance criteria:** Enemies detect, approach/engage, take damage and die consistently without navigation traps or excessive frame cost.
- **Potential risks:** Navigation bake errors, agent jitter, too much per-enemy polling, difficulty/readability balance.

## Phase 4: Battlefield Environment and Level Design

**Phase 4A status (2026-11-09): Implemented and runtime/render checked as a low-poly graybox.** The route runs from the Volga landing into the ruined street; see the Phase 4A reports for test limits.

**Phase 4B status (2026-11-09):** Its original 33-check runtime suite and owner-reported manual results are preserved in `PHASE_04B_TEST_REPORT.md`. After Phase 4C integration, the updated 36-check regression suite passes with encounter-aware objective progression. The owner's prior manual results predate combat integration and do not represent Phase 4C manual verification.

- **Objectives:** Turn the existing graybox into a complete, navigable mission route.
- **Features:** Start approach, combat lanes, intentional cover, boundaries, navigation, rally point, lighting/audio landmarks.
- **Existing files to modify:** `scripts/environment/battlefield.gd`, `scenes/main/main.tscn`, possibly `docs/PROJECT_ARCHITECTURE.md`.
- **New files required:** `scenes/environment/mission_01.tscn` or modular environment scenes; shared environment materials/resources; navigation region data.
- **Dependencies:** Existing player collision; enemy navigation needs; asset acquisition is separate and must preserve licensing.
- **Implementation steps:** Draw route and sightlines; replace repetitive wall blocks with reusable pieces; ensure cover dimensions; add boundary collision; bake/test navigation; share materials and merge static geometry only where measured beneficial.
- **Test cases:** Traverse route without gaps; test cover from player/enemy heights; verify navigation connections; inspect spawn and objective visibility; test on Compatibility renderer.
- **Acceptance criteria:** Continuous readable route from spawn to extraction with stable collision and valid enemy navigation.
- **Potential risks:** Level scope creep, invisible blockers, navmesh overhead, excessive draw calls.

**Phase 4C status (2026-11-09): COMPLETE.** Automated regressions passed, and the project owner reports manual gameplay verification passed. See `PHASE_04C_IMPLEMENTATION_REPORT.md` and `PHASE_04C_TEST_REPORT.md`; manual results are separately attributed and item-level details were not supplied. Phase 5 planning is complete; Phase 5A's foundation is implemented, while rendered review remains pending.

### Phase 4C — Mission 01 Combat Integration

- **Goal:** Integrate the existing infantry AI into Mission 01 while preserving the player, weapons, health/death/restart, HUD, mission UI, and separate F6 test range.
- **Proposed objectives:** Secure the Landing (one threat); Clear the Battlefield (two); Advance Through the Street (two); Secure the Position (three staged with at most two alive at once); Complete the Mission (reach the existing final rally marker, no additional enemy).
- **Architecture:** Add optional encounter data to objectives and a Mission 01-local encounter manager beneath Battlefield. MissionManager remains the sole objective completion authority and gates progress on location plus encounter-clear conditions. Reuse `infantry_enemy.tscn`, `EnemyHealth.died`, and existing `EnemyController`; do not add global encounter state.
- **Navigation result:** A hand-authored central corridor is built by `battlefield.gd`. The Phase 4C harness confirms synchronization and projection of all eight configured spawn positions. The project owner reports Phase 4C manual gameplay verification passed; item-level observations were not supplied.
- **Scope boundary:** Phase 4C implementation and verification are complete. Phase 5A is implemented; Phase 5B has not started and requires owner review and separate authorization.
- **Plan:** See `PHASE_04C_ARCHITECTURE_PLAN.md` for current architecture findings, exact expected files, signal flow, lifecycle, risks, staged implementation, regression strategy and acceptance criteria.

## Phase 5: Mission 01 Visual Overhaul

**Status (2026-11-09): Architecture planning COMPLETE; Phase 5A foundation IMPLEMENTED; rendered visual review and owner gameplay verification PENDING; Phase 5B NOT STARTED.** See `PHASE_05_ARCHITECTURE_PLAN.md` and the Phase 5A implementation and test reports.

- **Objective:** Replace the flat graybox presentation with a cohesive, historically inspired and performance-conscious visual treatment while preserving completed Phase 4C gameplay.
- **Stages:** 5A visual/material foundation implemented; 5B area geometry and architecture; 5C lighting/atmosphere; 5D environmental storytelling and visual consistency; 5E optimization and final verification.
- **Constraints:** Do not alter player, weapons, enemy AI, mission objectives, encounter logic, navigation, trigger/spawn coordinates, HUD behavior or F6 range. Prefer native resources and small, legally usable assets. Measure performance on Intel UHD 620; do not promise an FPS target.
- **Approval boundary:** Stop after Phase 5A. The owner must review the rendered result and manually verify gameplay before Phase 5B is authorized.

## Phase 6: HUD, UI, Sound and Animation

- **Objectives:** Communicate player and mission state and provide feedback for actions.
- **Features:** Health/ammo/objective HUD, pause/death/success panels, interaction prompt, SFX/ambience, animation state hooks.
- **Existing files to modify:** `scripts/ui/prototype_hud.gd`, `scenes/main/main.tscn`, `scenes/animation_tree.tscn`, `scripts/core/settings_manager.gd`, `scripts/core/input_setup.gd`.
- **New files required:** `scenes/ui/` HUD/pause/result scenes and UI scripts; `assets/audio/` original/licensed audio; animation libraries and character/weapon animation resources.
- **Dependencies:** Signals from phases 1, 2, 3 and 5; approved asset sources.
- **Implementation steps:** Replace generated hint with state-driven widgets; implement pause and result flow; wire input/mouse visibility; add audio buses and cues; configure AnimationTree only with real animation resources; repair text encoding.
- **Test cases:** HUD updates on damage/ammo/objective change; pause/resume mouse behavior; failure/success panel actions; audio levels and missing-asset fallback; 1280Ã—720 readability.
- **Acceptance criteria:** All critical gameplay state is readable and feedback plays without breaking input or flow.
- **Potential risks:** UI polling, overcomplicated animation graph, unlicensed assets, overlapping UI input.

## Phase 7: Save System, Checkpoints and Mission Completion

- **Objectives:** Persist checkpoint progression and support restart/recovery.
- **Features:** Versioned save, checkpoint activation, load validation, checkpoint respawn, completion record.
- **Existing files to modify:** `scripts/core/game_manager.gd`, `scripts/missions/mission_manager.gd`, `scenes/main/main.tscn`.
- **New files required:** `scripts/core/save_manager.gd`; save schema/resource; checkpoint scene/script.
- **Dependencies:** Stable mission/objective state (Phase 5), player reset, HUD and result flow (Phase 6).
- **Implementation steps:** Define schema/version; serialize only required durable state; write atomically where practical; handle missing/corrupt/old saves; restore objective/enemy/player state coherently; connect completion record.
- **Test cases:** First-run default; save/load each checkpoint; application restart; corrupt/missing/older version; repeated checkpoint reload; permission/write failure handling.
- **Acceptance criteria:** Checkpoint state survives restart and safely falls back to mission start when data cannot be used.
- **Potential risks:** Stale references during scene reconstruction; partial writes; ambiguous enemy reset policy; Windows path permissions.

## Phase 8: Optimization, Testing and Final Polish

- **Objectives:** Verify complete mission and meet target performance/readability.
- **Features:** Regression checklist, profiling, collision/nav validation, build/export checks, polish pass.
- **Existing files to modify:** Any gameplay/docs files based on measured findings; `docs/BUILD_AND_RUN.md`, `docs/CONTROLS.md`, architecture docs.
- **New files required:** Automated tests where useful; profiling results and release checklist documentation.
- **Dependencies:** Phases 1â€“7 complete; Godot 4.7.2 on Windows and Intel UHD 620 target access.
- **Implementation steps:** Run editor import/headless checks; play all paths; profile worst-case combat; reduce measured bottlenecks; validate Windows export; record hardware/settings/results; fix issues and rerun regression.
- **Test cases:** Fresh launch, full mission, death/retry, checkpoint restart, save corruption, all controls, mission completion, missing optional audio, performance under combat load.
- **Acceptance criteria:** No blocking defects; all mission paths pass; import/export clean; measured frame-time meets target; docs reflect tested build.
- **Potential risks:** Performance variance across UHD 620 systems; shader warmup stutter; last-minute content regressions.


