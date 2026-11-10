# Development roadmap

## Phase 01 — playable foundation

- Godot project configuration and reusable FPS controller.
- Graybox Stalingrad street with collision, cover and lighting.
- Mission, settings and game lifecycle foundations.
- Launch and verify the project on the target Windows setup.

## Next steps

Phase 4A, 4B, and 4C implementation milestones are recorded below. Phase 4C and Phase 5A are complete. Phase 5B visual implementation, automated regressions, rendering, and CLI startup checks are complete; Editor F5 remains unverified and owner visual/gameplay review is outstanding. See the Phase 5B implementation and test reports.

Campaign missions beyond the first prototype are out of scope for this phase.

## Phase 04A — Mission 01 battlefield

- **Status (2026-11-09):** Implemented and runtime/render checked as a low-poly graybox. F5 retains the existing player, weapons and HUD; F6 remains the isolated enemy range. Full manual walkthrough and performance profiling are outstanding. See `PHASE_04A_IMPLEMENTATION_REPORT.md` and `PHASE_04A_TEST_REPORT.md`.
- **Scope boundary at delivery:** Mission enemies, checkpoints and save system remain unimplemented.

## Phase 04B — Mission 01 objectives and progression

- **Status (2026-11-09):** Implemented and verified with 33 runtime assertions plus non-headless GL Compatibility inspection of briefing, objective HUD and completion screens. User-driven manual traversal remains outstanding. See the Phase 4B reports.
- **Scope boundary:** No enemies were added to Mission 01; no next mission, campaign selector or Phase 4C work was started.

## Phase 04C — Mission 01 combat integration

- **Status: COMPLETE.** The 56-check Phase 4C automated suite and updated Phase 4B/4A plus Phase 3B regressions passed. The project owner reports successful manual gameplay verification; that result is documented separately from automated evidence in `PHASE_04C_TEST_REPORT.md`.
- **Delivered:** Mission-local encounters on objectives 1–4, paired location/combat completion gates, a connected navigation corridor, staged reinforcements capped at two living enemies, and location-only objective 5. Existing player, weapons, HUD, enemy AI and F6 test range were retained.
- **Remaining outside this milestone:** Intel UHD 620 performance profiling and export validation. Phase 5A — Mission 01 Visual Foundation is complete; owner visual review and manual gameplay verification are approved.

## Phase 05 — Mission 01 visual overhaul

- **Phase 5A:** COMPLETE; owner visual and manual gameplay approval recorded in its historical report.
- **Phase 5B:** VISUAL IMPLEMENTATION COMPLETE; automated regressions, rendering and CLI startup checks pass. Editor F5 remains unverified. Shared ruined-house/rubble assets, the uploaded sandbag wall and crate, shoulder props, modest lighting adjustments, and Area A/B/C dressing are recorded in `PHASE_05B_IMPLEMENTATION_REPORT.md`.
- **Phase 5C — Advanced Battlefield Atmosphere & Environmental Storytelling:** IMPLEMENTATION COMPLETE; automated regressions (Phase 3B: 26, 4A: 12, 4B: 36, 4C: 56, 5C: 29) passed. Delivered shared external Environment resource with subtle Compatibility depth fog, 4 CPUParticles3D dust/smoke emitters (<= 120 particles) with quality fallback, 12 render-only storytelling props, and dedicated -10 dB Environment soundscape bus with wind and distant 3D artillery/combat audio. Nine 1280×720 GL Compatibility captures and a 3-run 3,600-frame benchmark on Intel UHD 620 recorded in `PHASE_05C_TEST_REPORT.md`.
- **Asset Organization, Integration & Audio Restoration:** COMPLETE; full audit of `assets/all_assets`, structured library under `assets/library/`, full audio restoration (Mosin fire/reload, PPSH fire/reload, dry fire click, bullet impact, camera AudioListener3D, environment soundscape balancing), 3D model validation in `asset_test_range.tscn`, Wehrmacht soldier model integrated onto enemy infantry, knocked-out Panzer I tank, crashed Hs 129 aircraft, city ruins, and stick grenade props integrated into Mission 01. Complete regression suite passed (Phase 3B: 26, Phase 4A: 12, Phase 4B: 36, Phase 4C: 56, Phase 5C: 29). See `ASSET_INVENTORY.md`, `ASSET_LICENSE_REGISTER.md`, `AUDIO_RESTORATION_REPORT.md`, `ASSET_INTEGRATION_REPORT.md`, and `ASSET_PERFORMANCE_REPORT.md`.
- **Verification & Open Gates:** Editor F5 and F6, owner manual gameplay traversal, and audio listening approval remain explicitly tracked as unresolved / pending owner verification.
