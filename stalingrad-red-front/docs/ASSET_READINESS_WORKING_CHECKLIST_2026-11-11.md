# Asset Readiness Working Checklist — 2026-11-11

## Authorization and boundaries

- [x] Asset preparation, provenance research, isolated technical inspection and genuine PPSH acquisition where the license and access criteria are met.
- [ ] Gameplay integration, model replacement, edits to player/enemy/weapon systems, Mission 01, or Enemy Test Range gameplay setup — prohibited for this milestone.
- [ ] Never modify `assets/all_assets/`, parent `README.md`, original downloaded assets, or stage/commit changes.

## Initial project state

- Project: `D:\Stalingrad Red Front\stalingrad-red-front`
- Godot target: 4.7.2, Compatibility renderer; target Intel UHD 620 / 16 GB RAM.
- Date: 2026-11-11
- Git branch: `main`
- Initial HEAD: `62decf0a195c9aff1e2060df1fad3a4ae20cf55c`
- Initial D: free space: **8747835392 bytes (8.15 GiB)**
- Initial incoming files:
- `assets\library\incoming_downloads\first_person_arms\fps arms\FPS ARMS RIG 1 test anim.blend` — 1745864 bytes
- `assets\library\incoming_downloads\first_person_arms\fps arms\FPS ARMS RIG 1 test.fbx` — 743452 bytes
- `assets\library\incoming_downloads\first_person_arms\fps arms\FPS ARMS RIG 1 test.fbx.import` — 1259 bytes
- `assets\library\incoming_downloads\first_person_arms\fps arms\FPS ARMS RIG 1.blend` — 1634996 bytes
- `assets\library\incoming_downloads\first_person_arms\fps arms\FPS ARMS RIG 1.fbx` — 434092 bytes
- `assets\library\incoming_downloads\first_person_arms\fps arms\FPS ARMS RIG 1.fbx.import` — 1244 bytes
- `assets\library\incoming_downloads\first_person_arms\fps arms\new_diff.png` — 686627 bytes
- `assets\library\incoming_downloads\first_person_arms\fps arms\new_diff.png.import` — 989 bytes
- `assets\library\incoming_downloads\german_soldie\LowpolySoldier\LowpolySoldier.fbx` — 319440 bytes
- `assets\library\incoming_downloads\german_soldie\LowpolySoldier\LowpolySoldier.fbx.import` — 1246 bytes
- `assets\library\incoming_downloads\german_soldie\LowpolySoldier\LowpolySoldier_Texture.png` — 165399 bytes
- `assets\library\incoming_downloads\german_soldie\LowpolySoldier\LowpolySoldier_Texture.png.import` — 1033 bytes
- `assets\library\incoming_downloads\mosin_nagant\mosin_nagant_lowpoly.glb` — 56169068 bytes
- `assets\library\incoming_downloads\mosin_nagant\mosin_nagant_lowpoly.glb.import` — 1222 bytes
- `assets\library\incoming_downloads\mosin_nagant\mosin_nagant_lowpoly_0.png` — 20233949 bytes
- `assets\library\incoming_downloads\mosin_nagant\mosin_nagant_lowpoly_0.png.import` — 1083 bytes
- `assets\library\incoming_downloads\mosin_nagant\mosin_nagant_lowpoly_1.png` — 19770817 bytes
- `assets\library\incoming_downloads\mosin_nagant\mosin_nagant_lowpoly_1.png.import` — 1083 bytes
- `assets\library\incoming_downloads\mosin_nagant\mosin_nagant_lowpoly_2.png` — 14741969 bytes
- `assets\library\incoming_downloads\mosin_nagant\mosin_nagant_lowpoly_2.png.import` — 1083 bytes

### Pre-existing working tree state (captured before this milestone)

The parent `README.md` was already conflicted (`UU`). Numerous tracked and untracked changes were already present across docs, scenes, scripts, resources, and assets. They are the owner's existing work and are out of scope. The initial status was:

```text
UU ../README.md
MM docs/DEVELOPMENT_ROADMAP.md
MM docs/MISSION_01_CURRENT_STATUS.md
M  docs/MISSION_01_DEVELOPMENT_PLAN.md
M  docs/PHASE_04A_TEST_REPORT.md
M  docs/PHASE_04B_TEST_REPORT.md
MM docs/PROJECT_ARCHITECTURE.md
 M project.godot
M  resources/missions/mission_01.tres
 M resources/weapons/mosin_nagant.tres
 M resources/weapons/ppsh_41.tres
MM scenes/main/main.tscn
 M scenes/player/player.tscn
 M scripts/enemies/enemy_controller.gd
MM scripts/environment/battlefield.gd
M  scripts/missions/mission_manager.gd
M  scripts/missions/objective_definition.gd
M  scripts/missions/objective_trigger.gd
 M scripts/testing/phase_03b_runtime_check.gd
M  scripts/testing/phase_04a_runtime_check.gd
MM scripts/testing/phase_04b_runtime_check.gd
?? assets/
?? default_bus_layout.tres
?? docs/3D_ASSET_IMPORT_VALIDATION_REPORT.md
?? docs/ASSET_INTEGRATION_REPORT.md
?? docs/ASSET_INVENTORY.md
?? docs/ASSET_LICENSE_REGISTER.md
?? docs/ASSET_ORGANIZATION_FINAL_REPORT.md
?? docs/ASSET_PERFORMANCE_REPORT.md
?? docs/AUDIO_RESTORATION_FIX_2_REPORT.md
?? docs/AUDIO_RESTORATION_REPORT.md
?? docs/COMPLETE_3D_ASSET_SETUP_REPORT.md
?? docs/DOWNLOADED_3D_ASSET_INVENTORY.md
?? docs/PHASE_04C_ARCHITECTURE_PLAN.md
?? docs/PHASE_04C_IMPLEMENTATION_REPORT.md
?? docs/PHASE_04C_TEST_REPORT.md
?? docs/PHASE_05A_IMPLEMENTATION_REPORT.md
?? docs/PHASE_05A_TEST_REPORT.md
?? docs/PHASE_05B1_IMPLEMENTATION_REPORT.md
?? docs/PHASE_05B1_STARTUP_ISSUE_REPORT.md
?? docs/PHASE_05B1_TEST_REPORT.md
?? docs/PHASE_05B_ARCHITECTURE_PLAN.md
?? docs/PHASE_05B_FINAL_VISUAL_AUDIT.md
?? docs/PHASE_05B_IMPLEMENTATION_REPORT.md
?? docs/PHASE_05B_TEST_REPORT.md
?? docs/PHASE_05C_ARCHITECTURE_PLAN.md
?? docs/PHASE_05C_ASSET_CREDITS.md
?? docs/PHASE_05C_FINAL_ACCEPTANCE_REPORT.md
?? docs/PHASE_05C_IMPLEMENTATION_REPORT.md
?? docs/PHASE_05C_TEST_REPORT.md
?? docs/PHASE_05_ARCHITECTURE_PLAN.md
?? docs/phase5a_battlefield_transition.png
?? docs/phase5a_battlefield_transition.png.import
?? docs/phase5a_closeup_ground_road_building.png
?? docs/phase5a_closeup_ground_road_building.png.import
?? docs/phase5a_ruined_street.png
?? docs/phase5a_ruined_street.png.import
?? docs/phase5a_volga_landing.png
?? docs/phase5a_volga_landing.png.import
?? docs/phase5b1_approach.png
?? docs/phase5b1_approach.png.import
?? docs/phase5b1_facade.png
?? docs/phase5b1_facade.png.import
?? docs/phase5b1_props.png
?? docs/phase5b1_props.png.import
?? docs/phase5b_battlefield_transition.png
?? docs/phase5b_battlefield_transition.png.import
?? docs/phase5b_building_closeup.png
?? docs/phase5b_building_closeup.png.import
?? docs/phase5b_military_defensive_position.png
?? docs/phase5b_military_defensive_position.png.import
?? docs/phase5b_player_level_gameplay.png
?? docs/phase5b_player_level_gameplay.png.import
?? docs/phase5b_ruined_stalingrad_street.png
?? docs/phase5b_ruined_stalingrad_street.png.import
?? docs/phase5b_volga_landing.png
?? docs/phase5b_volga_landing.png.import
?? docs/phase5c_battlefield_transition.png
?? docs/phase5c_battlefield_transition.png.import
?? docs/phase5c_building_closeup.png
?? docs/phase5c_building_closeup.png.import
?? docs/phase5c_combat_sightline_landing.png
?? docs/phase5c_combat_sightline_landing.png.import
?? docs/phase5c_combat_sightline_street.png
?? docs/phase5c_combat_sightline_street.png.import
?? docs/phase5c_combat_sightline_transition.png
?? docs/phase5c_combat_sightline_transition.png.import
?? docs/phase5c_military_defensive_position.png
?? docs/phase5c_military_defensive_position.png.import
?? docs/phase5c_player_level_gameplay.png
?? docs/phase5c_player_level_gameplay.png.import
?? docs/phase5c_ruined_stalingrad_street.png
?? docs/phase5c_ruined_stalingrad_street.png.import
?? docs/phase5c_volga_landing.png
?? docs/phase5c_volga_landing.png.import
?? resources/environment/
?? resources/missions/encounters/
?? scenes/environment/
?? scenes/testing/asset_import_validation.tscn
?? scenes/testing/asset_test_range.tscn
?? scenes/testing/phase_04c_runtime_check.tscn
?? scenes/testing/phase_05c_runtime_check.tscn
?? scenes/testing/test_audio_playback.tscn
?? scripts/core/gltf_asset_loader.gd
?? scripts/core/gltf_asset_loader.gd.uid
?? scripts/environment/environment_material_library.gd
?? scripts/environment/environment_material_library.gd.uid
?? scripts/environment/phase_5c_atmosphere.gd
?? scripts/environment/phase_5c_atmosphere.gd.uid
?? scripts/environment/phase_5c_soundscape.gd
?? scripts/environment/phase_5c_soundscape.gd.uid
?? scripts/missions/encounter_definition.gd
?? scripts/missions/encounter_definition.gd.uid
?? scripts/missions/mission_encounter_manager.gd
?? scripts/missions/mission_encounter_manager.gd.uid
?? scripts/testing/asset_import_validation.gd
?? scripts/testing/asset_integration_performance.gd
?? scripts/testing/asset_integration_performance.gd.uid
?? scripts/testing/asset_test_range.gd
?? scripts/testing/asset_test_range.gd.uid
?? scripts/testing/audit_all_assets.gd
?? scripts/testing/audit_all_assets.gd.uid
?? scripts/testing/capture_phase5a_views.gd
?? scripts/testing/capture_phase5a_views.gd.uid
?? scripts/testing/capture_phase5b_views.gd
?? scripts/testing/capture_phase5b_views.gd.uid
?? scripts/testing/capture_phase5c_views.gd
?? scripts/testing/capture_phase5c_views.gd.uid
?? scripts/testing/convert_audio_to_tres.gd
?? scripts/testing/convert_audio_to_tres.gd.uid
?? scripts/testing/convert_models_to_scenes.gd
?? scripts/testing/convert_models_to_scenes.gd.uid
?? scripts/testing/diagnose_audio.gd
?? scripts/testing/diagnose_audio.gd.uid
?? scripts/testing/gen_supp_audio.gd
?? scripts/testing/gen_supp_audio.gd.uid
?? scripts/testing/generate_phase5a_textures.gd
?? scripts/testing/generate_phase5a_textures.gd.uid
?? scripts/testing/generate_phase5c_assets.gd
?? scripts/testing/generate_phase5c_assets.gd.uid
?? scripts/testing/inspect_shots.gd
?? scripts/testing/inspect_shots.gd.uid
?? scripts/testing/phase5b_performance_sample.gd
?? scripts/testing/phase5b_performance_sample.gd.uid
?? scripts/testing/phase5c_full_benchmark.gd
?? scripts/testing/phase5c_full_benchmark.gd.uid
?? scripts/testing/phase5c_performance_sample.gd
?? scripts/testing/phase5c_performance_sample.gd.uid
?? scripts/testing/phase_04c_runtime_check.gd
?? scripts/testing/phase_04c_runtime_check.gd.uid
?? scripts/testing/phase_05c_runtime_check.gd
?? scripts/testing/phase_05c_runtime_check.gd.uid
?? scripts/testing/run_all_regressions.bat
?? scripts/testing/test_audio_playback.gd
?? scripts/testing/test_audio_playback.gd.uid
?? scripts/testing/test_gltf_models.gd
?? scripts/testing/test_gltf_models.gd.uid
```

No pre-existing state is being cleaned, staged, committed, or rewritten.

## Work checklist

- [x] Capture initial Git state, D: free space and incoming directory listing.
- [x] Read required Phase 5, asset, audio, import validation and architecture documentation.
- [x] Inspect incoming source metadata, FBX/GLB scene structure and import configuration.
- [x] Research asset provenance and license terms; record unresolved cases honestly.
- [x] Re-inspect soldier skeleton hierarchy and orientation/weapon pose readiness.
- [x] Inspect arms scale transforms, material/UV binding, and exact generic action.
- [x] Build isolated non-destructive arms/camera and Mosin texture comparisons; D: space checked before candidate import.
- [x] Investigate PPSH candidate pages and licenses. No candidate met the authenticated binary-access gate; none was downloaded.
- [x] PPSH import check was not created because no lawfully accessible candidate file was acquired; the incoming folder remains empty.
- [x] Run requested validations sequentially and record all untested/owner-only items.
- [x] Update required inventory/license documents and create the four readiness reports.
- [x] Confirm `assets/all_assets/` counts, README conflict and unstaged state; initial dirty tree was preserved.
- [x] Stop before gameplay integration; owner review is pending.
