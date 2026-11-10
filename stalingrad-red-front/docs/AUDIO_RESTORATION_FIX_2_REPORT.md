# Audio Restoration Fix 2 Report

**Project:** Stalingrad: Red Front (Godot 4.7.2, Compatibility renderer)  
**Status:** Automated playback dispatch verified; owner listening approval remains pending.

## Findings and root causes

The owner’s pre-fix listening results were treated as authoritative. Inspection confirmed the master and environment buses were loaded and unmuted, and the player camera had the active `AudioListener3D`. The Phase 5C soundscape was instantiated in the mission. The primary faults were playback lifecycle and stream configuration, rather than a missing or muted bus.

### Player reload sounds

The Mosin reload resource pointed at a 14.20-second stereo 48 kHz recording containing several repeated action cycles. The weapon reload mechanic lasts 2.8 seconds, so the full recording continued long after the reload. Sample inspection found a natural action cycle ending around 3.35 seconds; this was not a case of removable leading silence. A derived resource uses that first natural cycle. It retains the original stream’s pitch and rate and leaves reload timing and animation unchanged. PPSH reload behavior and resource were not changed.

### Enemy fire and reload

Enemy firing performed its existing damage, ammunition, and cadence work but did not create or trigger an audio player. The enemy scene had no firing or reload player. Thus there was no enemy sound playback to route or hear. Enemy firing and reload now request spatial playback from the existing enemy combat flow. Each transient player is placed at the enemy, routed to Master, and kept alive until its stream finishes or its expiry timer elapses; it is parented to the current scene so enemy cleanup does not immediately cut it off.

### Wind

The wind stream was told to loop, but its WAV `loop_end` remained zero. Runtime inspection showed the player starting and then stopping on the following frame, effectively producing no continuing wind. The soundscape now derives the loop endpoint from the WAV’s sample data, channel count, and sample width. Mission start pauses the tree for the briefing, so the soundscape also now restarts the wind player when the existing pause signal reports that gameplay has resumed.

### Distant artillery

The existing timer did trigger artillery playback, initially after a randomized 2–5 seconds and subsequently every 16–28 seconds. However, the source is a 4.5-second mono recording with a rapid fade, and its old spatial settings (`unit_size=35`, `max_distance=350`, node volume +5 dB) made it extremely quiet at its roughly 155 m initial separation from the player. Its measured RMS falls from about -17 dBFS at onset to about -48 dBFS by two seconds. The sound therefore had a valid trigger but weak audible level after distance attenuation. The updated source settings raise its effective level modestly while retaining a distant 3D position and the existing occasional cadence.

## Changes made

- `resources/weapons/mosin_nagant.tres` now references the shortened reload resource.
- Added `assets/library/audio/weapons/soviet/mosin_reload_short.tres`, a derived 3.35-second resource. The original audio collection and source recording were not modified.
- `scripts/enemies/enemy_controller.gd` now starts spatial enemy fire and reload playback while leaving aim, AI, firing cadence, damage, and ammunition logic intact.
- `scripts/environment/phase_5c_soundscape.gd` now configures the WAV loop endpoint and restarts wind after the mission briefing pause.
- `scenes/environment/phase_5c_soundscape.tscn` adjusts only the wind and artillery player settings.
- Added playback assertions to `scripts/testing/phase_03b_runtime_check.gd`, `scripts/testing/phase_04b_runtime_check.gd`, and `scripts/testing/phase_05c_runtime_check.gd`.
- Updated `scripts/testing/test_audio_playback.gd` and added `scenes/testing/test_audio_playback.tscn` for normal project-scene execution with autoloads.

No gameplay systems, original `assets/all_assets` content, bus layout, or parent README conflict were changed. Nothing was staged or committed.

## Audio routing and settings

| Sound | Bus | Player settings |
|---|---|---|
| Master | Master | 0 dB, unmuted |
| Environment bus | Environment → Master | -10 dB, unmuted |
| Player weapons | Master | Existing weapon playback/routing retained |
| Enemy firing | Master | -2 dB; `AudioStreamPlayer3D` `unit_size=8`, `max_distance=60` m |
| Enemy reload | Master | -4 dB; `unit_size=5`, `max_distance=40` m |
| Wind bed | Environment | +10 dB node level (nominally 0 dB net with bus); continuous full-stream WAV loop |
| Distant artillery | Environment | +8 dB node level (-2 dB nominal net with bus); `unit_size=55`, `max_distance=260` m; timer remains 16–28 seconds after initial randomized delay |

The wind WAV is 10 seconds, with measured RMS around -36 dBFS and peak around -24 dBFS. The artillery stream, position, and cadence are unchanged; attenuation settings are the targeted adjustment. The project remains on Godot’s Compatibility renderer and no real-time shadow or GPU effect changes were made.

## Validation performed

Checks were run sequentially. Automated checks establish scene startup and playback dispatch/state, not that a person can hear the output.

| Check | Result |
|---|---|
| Audio resource playback test (`godot --headless --path . --scene res://scenes/testing/test_audio_playback.tscn`) | Passed; player/environment streams load, routing and shortened reload resource validate |
| Main project scene CLI startup (`--path . --quit-after 180`) | Exit 0; Compatibility renderer initialized |
| Enemy test range CLI startup (`--path . --scene res://scenes/testing/enemy_test_range.tscn --quit-after 180`) | Exit 0; Compatibility renderer initialized |
| Phase 3B runtime regression | 28 checks passed, including enemy fire and reload player/stream dispatch |
| Phase 4A runtime regression | 12 checks passed |
| Phase 4B runtime regression | 39 checks passed, including player fire and reload playback state; mouse capture is not validated headlessly |
| Phase 4C runtime regression | 56 checks passed |
| Phase 5C runtime regression | 35 checks passed, including wind loop/unpause, artillery timer dispatch, and active listener |

No audio-specific Godot errors appeared in these checks. The CLI output did report that Godot could not write its `user://logs` files and could not read the Windows root certificate store. Some headless regression exits also printed object/resource leak warnings during shutdown (two or three ObjectDB instances and one resource, depending on the run). These are recorded as observed teardown/environment warnings; they do not establish an audio fault. They should be checked again during owner/editor playback. Automated `.playing` checks cannot prove audibility, correct perceived balance, or absence of clicks.

## Remaining limitations and owner verification

Editor F5 and Editor F6 were not run as editor actions in this pass. The CLI main-scene and test-range launches above are separate checks and do not verify either editor shortcut. No human listening test was performed after the changes. In particular, an owner must confirm that the selected existing Mosin recording is appropriate for enemy weapons and that artillery remains recognizably distant at gameplay positions.

### Owner listening checklist

- [ ] Run Mission 01 with Editor F5 and confirm the project starts, the briefing can be dismissed, and gameplay resumes.
- [ ] Hear Mosin and PPSH shots at normal gameplay positions.
- [ ] Hear each weapon reload; confirm Mosin audio ends naturally and stays aligned with its existing reload action.
- [ ] Hear enemy firing from nearby and at a moderate distance; verify reload audio when an enemy reloads.
- [ ] Hear subtle continuous wind after starting gameplay, with no clicks or obvious loop seam.
- [ ] Hear artillery occasionally (allow at least 30 seconds after gameplay begins); confirm it sounds distant and does not mask combat.
- [ ] Run the enemy test range with Editor F6 and confirm the editor remains free of audio errors while firing/reloading.
- [ ] Confirm combat remains readable and weapon/enemy audio remains clear relative to ambience.

## Exact editor verification steps

1. Open `D:\Stalingrad Red Front\stalingrad-red-front\project.godot` in Godot 4.7.2.
2. For **Editor F5**, select **Project → Run** or press **F5**. If prompted, select the configured main scene. Start Mission 01, dismiss the briefing, and follow the listening checklist above. Record any startup error exactly; this report does not claim F5 is verified.
3. For **Editor F6**, open `res://scenes/testing/enemy_test_range.tscn` in the editor and press **F6** (Run Current Scene). Fire/reload the available weapons, observe enemy firing/reloading, and check the debugger Output for audio errors.
4. Treat CLI startup checks as their own results; they are not substitutes for F5/F6 or listening approval.

## Recommendation

**CONDITIONAL PASS for code and automated playback-dispatch checks.** Audio acceptance remains pending owner listening approval for player reloads, enemy fire/reload, wind, and artillery, plus Editor F5/F6 verification. Do not mark the audio work fully accepted until those checks are completed.
