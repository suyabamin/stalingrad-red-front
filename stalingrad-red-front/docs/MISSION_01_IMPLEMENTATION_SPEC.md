# Mission 01: Across the Volga — Implementation Specification

## Story and background

The player is a Soviet infantry soldier entering a devastated Stalingrad industrial district after crossing the Volga. Under fire and separated from the main force, the soldier must move through the ruined street, suppress the defenders blocking the route, and reach a forward Soviet position. Keep this as a compact, fictionalized single-player mission; historical framing should avoid presenting invented events as documentary fact.

## Mission objectives

1. Reach the first covered position and receive the mission briefing.
2. Clear the enemy-held street sector.
3. Advance through the industrial district to the marked rally point.
4. Trigger mission completion at the rally point.

Objectives must be ordered, visible in the HUD, and advance only when their completion conditions are met. Mission failure occurs on player death; restart from the active checkpoint or mission start.

## Player gameplay requirements

- First-person walking, sprinting, jumping, mouse look and collision-safe movement.
- Configurable mouse sensitivity and a pause flow that releases the mouse.
- Player health with damage feedback, death state and recovery/restart path.
- Interaction support for objective triggers and checkpoint activation.
- Player scene remains reusable and owns its movement/collision/camera; mission/UI logic belongs outside the controller.

## Weapon system requirements

- One historically appropriate bolt-action rifle as the initial mission weapon, represented with original or properly licensed assets.
- Hitscan shot from camera aim with range, collision mask, hit confirmation and damage interface.
- Fire cadence, recoil/aim feedback, muzzle/audio feedback, and clear empty-ammo feedback.
- Keep weapon state in a dedicated reusable component/scene; avoid coupling enemy health to a specific rifle script.

## Enemy AI requirements

- Enemies use reusable CharacterBody3D scenes with health, collision, animation hooks and weapon interface.
- AI states: idle/patrol, suspicious, engage, take cover/reposition, and dead.
- Detection combines distance, field of view and line-of-sight ray test; hearing events may be added if performance permits.
- NavigationAgent3D movement uses a baked NavigationRegion3D. Validate reachable paths around cover; handle unreachable targets and agent completion.
- Enemy fire has readable windup, accuracy bounds, cooldown and line-of-sight checks. Enemies must not deal unavoidable damage through solid cover.
- Cap simultaneous active enemies and avoid per-frame expensive global searches.

## Player health and damage

- Define health maximum, damage source contract, invulnerability/death transition policy, and reset behavior as tunable data.
- Damage must update HUD and provide restrained visual/audio feedback.
- Death stops combat input and presents restart/checkpoint choices. Define whether mission state resets to checkpoint or objective start.

## Ammunition and reloading

- Define magazine/chamber capacity and reserve ammunition in data; display loaded and reserve counts.
- Reload is an explicit input action, disallowed while already reloading/dead, and transfers only available reserve rounds.
- Firing consumes ammunition only when a valid shot is emitted; empty fire does not damage targets.
- Reload duration and interruption rules must be consistent with selected weapon animation.

## Enemy detection and combat

- Use collision layers/masks documented for world, player, enemies, hitboxes and interaction.
- Ray-based weapon hits and enemy visibility must ignore the firing actor and respect world geometry.
- Apply damage through a small shared interface/signal; prevent duplicate hit application from overlapping hitboxes.
- Death disables combat/navigation and leaves mission objective counts consistent.

## Mission success and failure

- Mission manager owns explicit mission state and ordered objective state; emit signals on state/objective changes.
- Success requires all required objectives and final extraction/rally trigger.
- Failure includes player death; provide retry from checkpoint and full restart.
- Re-entering/restarting must clear transient enemy, ammo and objective state deterministically.

## HUD and UI

- HUD: reticle, health, loaded/reserve ammo, current objective, objective progress and interaction prompt.
- Pause screen: resume, restart/checkpoint, sensitivity and quit-to-menu/desktop behavior as appropriate.
- Mission intro, success and failure panels must capture/release mouse correctly and remain readable at 1280×720.
- Keep UI state driven by signals/state, not polling every frame.

## Sound and animation

- Provide distinct weapon fire, reload, impact, enemy alert/fire/death, footsteps, ambience and UI feedback.
- Audio must be mixed for intelligibility and support master/music/effects/voice settings if settings scope permits.
- Character animation states: idle, move, fire/aim, hit, death. Weapon animation covers fire, bolt cycle and reload.
- Configure AnimationTree only when animation resources and state transitions exist; missing animations must not block gameplay.

## Battlefield environment

- Expand the current ruined street graybox into a readable route from landing approach through combat sector to rally point.
- Provide stable ground collision, deliberate cover, combat sightlines, navigation bake, boundaries and objective markers.
- Telegraph safe route and threat positions through composition, lighting, sound and UI.
- Preserve Compatibility renderer and target integrated graphics; prioritize simple materials, static batching/resource sharing where supported, limited transparency and restrained effects.

## Save and checkpoint requirements

- Save mission ID, checkpoint ID, objective progress and required player state using a versioned save format.
- Save only at defined checkpoints or safe transitions; validate malformed/missing data and fall back to mission start.
- Checkpoint respawn restores a coherent world state (objectives, enemies, health/ammo policy) and is repeatable.
- Keep save paths platform appropriate and test Windows permissions.

## Performance requirements

- Target Intel UHD 620, 16 GB RAM, Windows 11, 1280×720 and Compatibility renderer.
- Mission target: stable 60 FPS where hardware permits; treat 30 FPS as the minimum acceptable floor during combat after profiling.
- Avoid expensive per-frame allocations, unbounded enemy counts, excessive unique materials, unnecessary dynamic lights/shadows, and overly dense collision geometry.
- Profile representative combat and worst-case view on target hardware; record frame time, memory and active object counts before final tuning.

## Acceptance criteria

- Project imports and launches on Godot 4.7.2 Compatibility renderer without parse/resource errors.
- Player can traverse the full route, fire/reload, take damage and die/restart correctly.
- Enemy detection respects visibility/cover; combat is readable and enemies can be defeated.
- Objectives update in order and mission success/failure states are reachable and repeatable.
- HUD and pause/restart flows correctly reflect state and mouse capture.
- Checkpoint save/load survives application restart and handles missing/corrupt save data safely.
- No collision/navigation blockers prevent completion; each objective has a clear success condition.
- Target hardware performance is measured in a representative build and meets the stated floor without crashes or sustained stutters.
- All acceptance checks are documented with actual results; no feature is marked verified based solely on source inspection.

