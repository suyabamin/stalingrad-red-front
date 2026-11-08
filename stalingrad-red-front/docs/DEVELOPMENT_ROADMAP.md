# Development roadmap

## Phase 01 — playable foundation

- Godot project configuration and reusable FPS controller.
- Graybox Stalingrad street with collision, cover and lighting.
- Mission, settings and game lifecycle foundations.
- Launch and verify the project on the target Windows setup.

## Next steps

1. Tune movement and add a small objective loop for Mission 01.
2. Add original weapon handling and a basic firing range interaction.
3. Add enemy behavior, damage and feedback before expanding the mission.
4. Replace selected graybox props with optimized original art and audio.
5. Profile the build on Intel UHD 620 and adjust visible geometry and resolution.

Campaign missions beyond the first prototype are out of scope for this phase.

## Phase 04A — Mission 01 battlefield

- **Status (2026-11-09):** Implemented and runtime/render checked as a low-poly graybox. F5 retains the existing player, weapons and HUD; F6 remains the isolated enemy range. Full manual walkthrough and performance profiling are outstanding. See `PHASE_04A_IMPLEMENTATION_REPORT.md` and `PHASE_04A_TEST_REPORT.md`.
- **Scope boundary:** Mission objectives, mission enemies, checkpoints, save system and Phase 4B work remain unimplemented.
